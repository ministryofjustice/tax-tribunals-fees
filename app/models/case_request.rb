class CaseRequest < ApplicationRecord
  has_many :liabilities

  validates :case_reference,
    presence: true,
    format: { with: %r{\A[a-z]+\/\d+\/\d+\z}i }
  validates :confirmation_code,
    presence: true

  # Skip if there are already errors to save ourselves a roundtrip to GLiMR
  validate :case_must_exist_on_glimr, if: -> { errors.empty? }

  before_create :set_title_and_jurisdiction
  after_save :create_liabilities!, on: [:create, :update]

  def liabilities?
    liabilities.exists?
  end

  def all_fees_paid?
    return unless liabilities?
    liabilities.all?(&:paid?)
  end

  private

  def glimr_case_request
    @glimr_case_request ||= Glimr.find_case(case_reference, confirmation_code)
  end

  def set_title_and_jurisdiction
    self.case_title = glimr_case_request.title
    self.glimr_jurisdiction = glimr_case_request.jurisdiction
  end

  def create_liabilities!
    glimr_case_request.fee_liabilities.each do |liability|
      liabilities.create(
        description: liability.description,
        amount: liability.amount,
        glimr_id: liability.glimr_id
      )
    end
  end

  def case_must_exist_on_glimr
    if glimr_case_request.error?
      errors.add(:base, I18n.t('case_requests.could_not_find_case'))
    end
  end
end
