FactoryGirl.define do
  factory :liability do
    sequence(:glimr_id) { |n| sprintf('TT/%d/%05d', Time.zone.now.year, n) }
    description { 'You vs HMRC' }
    amount { 2000 }
    case_request
    factory :paid_liability do
      govpay_payment_status { 'success' }
    end
  end
end
