FactoryGirl.define do
  factory :fee_liability do
    sequence(:glimr_id) { |n| sprintf('TT/%d/%05d', Time.zone.now.year, n) }
    description { 'You vs HM Revenue & Customs' }
    amount { 2000 }
    case_request
  end
end
