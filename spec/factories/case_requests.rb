FactoryGirl.define do
  factory :case_request do
    sequence(:case_reference) { |n| sprintf('TC/2016/%05d', n) }
    sequence(:confirmation_code) { |n| sprintf('XYZ%03d', n) }
    factory :case_request_with_fee do
      case_fees { build_list :fee, 1 }
    end
  end
end
