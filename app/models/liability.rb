class Liability < ApplicationRecord
  belongs_to :case_request

  validates :glimr_id, :description, :amount, presence: true

  after_create :set_govpay_reference!

  def govpay_description
    "#{case_request.case_reference} - #{description}"
  end

  def amount_in_pounds
    amount / 100.0
  end

  def status_known?
    govpay_payment_status.present?
  end

  def paid?
    govpay_payment_status == 'success'
  end

  def failed?
    status_known? && !paid?
  end

  private

  def set_govpay_reference!
    update(govpay_reference: "#{glimr_id}G#{timestamp}")
  end

  def timestamp
    Time.zone.now.strftime('%Y%m%d%H%M%S')
  end
end
