require 'bcrypt'

class Fee < ApplicationRecord
  include BCrypt

  attr_accessor :confirmation_code

  validates :case_reference,
    :glimr_id,
    :description,
    :amount,
    presence: true

  before_save :crypt_confirmation_code, if: :confirmation_code
  after_create :set_govpay_reference!

  def govpay_description
    "#{case_reference} - #{description}"
  end

  def amount_in_pounds
    amount / 100.0
  end

  def status_known?
    govpay_payment_status.present?
  end

  def paid?
    govpay_payment_status.eql?('success')
  end

  def failed?
    status_known? && !paid?
  end

  private

  def crypt_confirmation_code
    self.confirmation_code_digest = Password.create(confirmation_code)
  end

  def set_govpay_reference!
    update(govpay_reference: "#{glimr_id}G#{timestamp}")
  end

  def timestamp
    Time.zone.now.strftime('%Y%m%d%H%M%S')
  end
end
