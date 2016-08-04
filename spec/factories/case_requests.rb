FactoryGirl.define do
  factory :case_request do
    sequence(:case_reference) { |n| sprintf('TC/2016/%05d', n) }
    confirmation_code { 'ABC123' }
    case_title { 'You vs HMRC' }
    glimr_jurisdiction 8

    factory :case_request_with_paid_liabilities do
      after(:create) do |case_request|
        create(:paid_liability, case_request: case_request)
      end
    end
  end
end
