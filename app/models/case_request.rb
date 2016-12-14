class CaseRequest < ApplicationRecord
  attr_accessor :case_fees

  validates :case_reference, presence: true
  validates :confirmation_code, presence: true

  # Overriding initialize either did not work as expected, or was subject to
  # difficult-to-kill mutations.
  after_initialize :init_case_fees

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

  def init_case_fees
    @case_fees = []
  end

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
    @glimr_case_request ||= GlimrApiClient::Case.find(
      case_reference,
      confirmation_code
    )
  end

  delegate :fees, :title, to: :glimr_case_request
end
