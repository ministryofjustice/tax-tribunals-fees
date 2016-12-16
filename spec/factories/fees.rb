FactoryGirl.define do
  factory :fee do
    sequence(:glimr_id) { |n| sprintf('TT/%d/%05d', Time.zone.now.year, n) }
    sequence(:case_reference) { |n| sprintf('TC/2016/%05d', n) }
    confirmation_code { 'ABC123' }
    case_title { 'You vs HMRC' }

    description { 'You vs HMRC' }
    amount { 2000 }
    case_request
    factory :paid_fee do
      govpay_payment_status { 'success' }
    end
  end
end
