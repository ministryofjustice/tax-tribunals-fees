require 'rails_helper'

RSpec.describe CaseRequest do
  let(:case_reference) { "TC/2016/04512" }
  let(:confirmation_code) { 'confcode' }
  subject(:case_request) {
    build(:case_request,
          case_reference: case_reference,
          confirmation_code: confirmation_code)
  }

  let(:fee) {
    object_double(
      OpenStruct.new(description: 'desc', amount: 0, glimr_id: '1'),
      description: 'Fee liability',
      amount: 10_000,
      glimr_id: '12345'
    )
  }

  let(:fees) { [fee] }

  let(:glimr_case_request) {
    instance_double(
      GlimrApiClient::Case,
      title: 'Glimr Case Request',
      fees: fees
    )
  }

  describe '#all_fees_paid?' do
    it "knows all fees are paid" do
      case_request.case_fees << instance_double(Fee, paid?: true)
      expect(case_request.all_fees_paid?).to be_truthy
    end

    it "knows not all fees are paid" do
      case_request.case_fees << instance_double(Fee, paid?: true)
      case_request.case_fees << instance_double(Fee, paid?: false)
      expect(case_request.all_fees_paid?).to be_falsey
    end
  end

  describe '#fees' do
    it "has no fees" do
      expect(case_request.fees?).to be_falsey
    end

    it "has fees" do
      case_request.case_fees << 1
      expect(case_request.fees?).to be_truthy
    end
  end

  describe '#process!' do
    context "when case does not exist in glimr" do
      before do
        allow(Fee).to receive(:create!).and_return(fee)
        allow(GlimrApiClient::Case).to receive(:find).and_raise(GlimrApiClient::Case::InvalidCaseNumber)
      end

      it "raises an error" do
        expect {
          case_request.process!
        }.to raise_error(GlimrApiClient::Case::InvalidCaseNumber)
      end
    end

    context "when case exists in glimr" do
      before do
        allow(Fee).to receive(:create!).and_return(fee)
        allow(GlimrApiClient::Case).to receive(:find).and_return(glimr_case_request)
      end

      let(:fee_params) {
        {
          case_reference: case_reference,
          case_title: "Glimr Case Request",
          description: "Fee liability",
          amount: 10_000,
          glimr_id: '12345',
          confirmation_code: 'confcode'
        }
      }

      it "is valid" do
        case_request.process!
        expect(case_request).to be_valid
      end

      it "finds the case in glimr" do
        expect(GlimrApiClient::Case).to receive(:find).with(case_reference, confirmation_code)
        case_request.process!
      end

      it "creates a fee" do
        expect(Fee).to receive(:create!).exactly(:once)
        case_request.process!
      end

      it "creates fee with correct parameters" do
        expect(Fee).to receive(:create!).with(fee_params)
        case_request.process!
      end

      it "returns the fees created" do
        expect {
          case_request.process!
        }.to change(case_request, :case_fees).from([]).to([fee])
      end
    end
  end
end
