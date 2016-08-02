require 'glimr'

module Forms
  class NewCaseRequest
    include ActiveModel::Model
    include Virtus.model

    attr_reader :case_request

    attribute :case_reference, String
    attribute :confirmation_code, String

    validates :case_reference,
      presence: true,
      format: { with: %r{\A[a-z]+\/\d+\/\d+\z}i }
    validates :confirmation_code,
      presence: true

    # Skip if there are already errors to save ourselves a roundtrip to GLiMR
    validate :case_must_exist_on_glimr, if: -> { errors.empty? }

    def save
      if valid?
        create_case_request!
        create_liabilities!
        true
      else
        false
      end
    end

    private

    def create_case_request!
      @case_request = CaseRequest.create(
        case_reference: case_reference,
        case_title: glimr_case_request.title,
        glimr_jurisdiction: glimr_case_request.jurisdiction
      )
    end

    def create_liabilities!
      glimr_case_request.fee_liabilities.each do |liability|
        @case_request.liabilities.create(
          description: liability.description,
          amount: liability.amount,
          glimr_id: liability.glimr_id
        )
      end
    end

    def case_must_exist_on_glimr
      if glimr_case_request.error?
        errors.add(:base, I18n.t('case_requests.could_not_find_case'))
        Rails.logger.warn({ at: :api_error,
                            service: :glimr,
                            reference: case_reference,
                            error_code: glimr_case_request.error_code,
                            message: glimr_case_request.error_message }.
                            map { |k, v| "#{k}=#{v}" }.join(' '))
      end
    end

    def glimr_case_request
      @glimr_case_request ||= Glimr.find_case(case_reference, confirmation_code)
    end
  end
end
