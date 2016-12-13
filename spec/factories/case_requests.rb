FactoryGirl.define do
  factory :case_request do
    sequence(:case_reference) { |n| sprintf('TC/2016/%05d', n) }
    confirmation_code { 'X1-Y2-Z3' }
  end
end
