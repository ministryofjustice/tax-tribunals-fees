class CaseRequest < ApplicationRecord
  has_many :case_fees, foreign_key: :case_request_id, class_name: Fee

  validates :case_reference, presence: true
  validates :confirmation_code, presence: true
  before_save :upcase_case_reference

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

  def upcase_case_reference
    case_reference.upcase!
  end

  def prepare_case_fee(fee)
    case_fees << Fee.new(
      case_reference: case_reference,
      case_title: title,
      description: fee.description,
      amount: fee.amount,
      glimr_id: fee.glimr_id,
      confirmation_code: confirmation_code
    )
  end

  def glimr_case_request
    # This should raise a GlimrApiClient::Case::InvalidCaseNumber
    # exception if the case is not found. But, in the staging (but
    # not dev) environment, that exception is being swallowed, and
    # we end up with a 'case' like this;
    #
    #  <GlimrApiClient::Case:0x007f94ecfc5750
    #    @body=
    #     "{\"message\":\"Invalid CaseNumber/CaseConfirmationCode
    #     combination xxx / YYY\",\"glimrerrorcode\":213}",
    #    @case_reference="xxx",
    #    @confirmation_code="yyy">
    #
    # It's only when we try and call a method on this object that we
    # get a KeyError. So, in the staging environment, the user sees
    # a low-level application error when they search for a case with
    # incorrect reference/confirmation_code
    #
    # The call to fees and the rescue below are a nasty hack to
    # workaround this issue.  TODO: fix this properly, possibly by
    # adding a 'has_errors?' method to the Case class, or by finding
    # and fixing the underlying issue which is preventing the exception
    # from bubbling up properly.

    @glimr_case_request ||= GlimrApiClient::Case.find(
      case_reference,
      confirmation_code
    )

    # If we're looking at a failed find, this will raise a KeyError
    @glimr_case_request.fees

    @glimr_case_request
  rescue KeyError
    raise GlimrApiClient::Case::InvalidCaseNumber
  end

  delegate :fees, :title, to: :glimr_case_request
end
