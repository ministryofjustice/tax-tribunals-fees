class CaseRequest
  include ActiveModel::Model

  attr_accessor :case_reference,
    :confirmation_code,
    :fees

  def initialize(case_reference, confirmation_code)
    @case_reference    = case_reference
    @confirmation_code = confirmation_code
    @fees              = []
  end

  validates :case_reference, presence: true
  validates :confirmation_code, presence: true

  def process!
    unless glimr_case_request.error?
      fee_liabilities.each do |fee|
        prepare_fee(fee)
      end
    end
  end

  def all_fees_paid?
    fees.all?(&:paid?)
  end

  def fees?
    fees.present?
  end

  private

  def prepare_fee(fee)
    Fee.create(
      case_reference: case_reference,
      case_title: title,
      description: fee.description,
      amount: fee.amount,
      glimr_id: fee.glimr_id
    ).tap { |f|
      fees << f
      # Because it is stored as a BCrypt digest.
      f.update_attributes(confirmation_code: confirmation_code)
    }
  end

  def glimr_case_request
    @glimr_case_request ||= Glimr.find_case(case_reference, confirmation_code)
  end

  delegate :fee_liabilities, :title, to: :glimr_case_request
end
