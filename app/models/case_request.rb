class CaseRequest
  include ActiveModel::Model

  attr_accessor :case_reference,
    :confirmation_code,
    :case_fees

  def initialize(case_reference, confirmation_code)
    @case_reference = case_reference
    @confirmation_code = confirmation_code
    @case_fees = []
  end

  validates :case_reference, presence: true
  validates :confirmation_code, presence: true

  def process!
    fees.each do |fee|
      prepare_case_fee(fee)
    end
  end

  def all_fees_paid?
    case_fees.all?(&:paid?)
  end

  def fees?
    case_fees.present?
  end

  private

  def prepare_case_fee(fee)
    case_fees << Fee.create!(
      case_reference: case_reference,
      case_title: title,
      description: fee.description,
      amount: fee.amount,
      glimr_id: fee.glimr_id,
      confirmation_code: confirmation_code
    )
  end

  def glimr_case_request
    @glimr_case_request ||= GlimrApiClient::Case.find(case_reference, confirmation_code)
  end

  delegate :fees, :title, to: :glimr_case_request
end
