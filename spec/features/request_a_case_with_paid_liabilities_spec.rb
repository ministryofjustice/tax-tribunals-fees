require 'rails_helper'

RSpec.feature 'Request a case that has already been paid for' do
  let(:fees) { [] }

  let(:glimr_case) {
    instance_double(
      GlimrApiClient::Case,
      title: 'You vs HM Revenue & Customs',
      fees: fees
    )
  }

  let(:api_available) { instance_double(GlimrApiClient::Available, available?: true) }

  before do
    allow(GlimrApiClient::Available).to receive(:call).and_return(api_available)
    allow(GlimrApiClient::Case).to receive(:find).and_return(glimr_case)
  end

  # Because let blocks cannot be passes as arguments to shared examples.
  case_number = 'TC/2012/00001'
  confirmation_code = 'ABC123'

  # Because let blocks are memoized and subsequent calls to not execute the
  # workflow again.
  def make_a_case_request(case_number, confirmation_code)
    visit '/'
    click_on 'Start now'
    fill_in 'Case reference', with: case_number
    fill_in 'Confirmation code', with: confirmation_code
    click_on 'Find case'
  end

  describe 'and there are no new fees' do
    let(:fees) { [] }

    scenario 'No new fees are recorded locally' do
      expect {
        make_a_case_request(case_number, confirmation_code)
      }.not_to change { Fee.count }
    end

    scenario 'we explain that there are no outstanding fees' do
      make_a_case_request(case_number, confirmation_code)
      expect(page).to have_text('There are currently no outstanding fees on your case')
    end
  end

  describe 'and there is an unpaid fee' do
    let(:fees) {
      [
        OpenStruct.new(
          glimr_id: 7,
          description: 'Lodgement Fee',
          amount: 2000
        )
      ]
    }

    scenario 'One new fee is recorded locally' do
      expect {
        make_a_case_request(case_number, confirmation_code)
      }.to change { Fee.count }.by(1)
    end

    scenario 'we explain that there is an outstanding fee' do
      make_a_case_request(case_number, confirmation_code)
      expect(page).to have_text('£20.00')
    end
  end
end
