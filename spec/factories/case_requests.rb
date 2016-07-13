FactoryGirl.define do
  factory :case_request do
    sequence(:case_reference) { |n| sprintf('ABC%03d', n) }
    case_title { 'You vs HM Revenue & Customs' }
    glimr_jurisdiction 8
  end
end
