module PaidLiabilityDefinitions
  def no_fee
    {
      'jurisdictionId' => 8,
      'tribunalCaseId' => 60_029,
      'caseTitle' => 'You vs HM Revenue & Customs',
      'feeLiabilities' => []
    }.to_json
  end

  def twenty_pound_fee
    {
      'jurisdictionId' => 8,
      'tribunalCaseId' => 60_029,
      'caseTitle' => 'You vs HM Revenue & Customs',
      'feeLiabilities' =>
      [{ 'feeLiabilityId' => 7,
         'onlineFeeTypeDescription' => 'Lodgement Fee',
         'payableWithUnclearedInPence' => 2000 }]
    }.to_json
  end

  def case_request
    binding.pry
    @case_request ||= create(:case_request)
  end

  def make_a_case_request
    visit '/'
    click_on 'Start now'
    fill_in 'Case reference', with: case_request.case_reference
    fill_in 'Confirmation code', with: case_request.case_confirmation
    click_on 'Find case'
  end
end

RSpec.shared_examples 'a £20 fee followed by no new fees' do
  include PaidLiabilityDefinitions

  before do
    stub_request(:post, 'https://glimr-test.dsd.io/requestpayablecasefees').
      with(body: "jurisdictionId=8&caseNumber=#{case_request.case_references}&caseConfirmationCode=#{case_request.case_confirmation}",
           headers: {'Accept' => 'application/json'} ).
      to_return({ body: twenty_pound_fee }, { body: no_fee })
  end
end

RSpec.shared_examples 'no new fees' do
  before do
    stub_request(:post, "https://glimr-test.dsd.io/requestpayablecasefees").
      to_return({ body: no_fee }, { body: no_fee })
  end
end


RSpec.shared_examples 'no fee followed by a £20 fee' do
  before do
    stub_request(:post, "https://glimr-test.dsd.io/requestpayablecasefees").
      to_return({ body: no_fee }, { body: twenty_pound_fee })
  end
end

RSpec.shared_examples 'a £20 fee followed by the same fee' do
  before do
    stub_request(:post, "https://glimr-test.dsd.io/requestpayablecasefees").
      to_return({ body: twenty_pound_fee }, { body: twenty_pound_fee })
  end
end
