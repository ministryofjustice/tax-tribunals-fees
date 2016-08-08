class CaseRequest
  include ActiveModel::Model

  attr_accessor :case_reference,
    :confirmation_code,
    :liabilities

  def initialize(opts = {})
    @case_reference = opts[:case_reference]
    @confirmation_code = opts[:confirmation_code]
    @liabilities = []
  end

  validates :case_reference,
    presence: true,
    format: { with: %r{\A[a-z]+\/\d+\/\d+\z}i }
  validates :confirmation_code,
    presence: true

  # Skip if there are already errors to save ourselves a roundtrip to GLiMR
  validate :case_must_exist_on_glimr, if: -> { errors.empty? }

  def process!
    fee_liabilities.each do |liability|
      Fee.find_or_create_by(case_reference: case_reference,
                            description: liability.description,
                            amount: liability.amount,
                            glimr_id: liability.glimr_id).
        tap { |f|
          # Becaue it is stored as a BCrypt digest.
          f.update_attributes(confirmation_code: confirmation_code)
          liabilities << f
        }
    end
  end

  def all_fees_paid?
    liabilities? && liabilities.all?(&:paid?)
  end

  def liabilities?
    liabilities.present?
  end

  private

  def glimr_case_request
    @glimr_case_request ||= Glimr.find_case(case_reference, confirmation_code)
  end

  delegate :fee_liabilities, :title, to: :glimr_case_request

  def case_must_exist_on_glimr
    if glimr_case_request.error?
      errors.add(:base, I18n.t('case_requests.could_not_find_case'))
    end
  end
end
