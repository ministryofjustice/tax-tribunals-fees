require 'rails_helper'

RSpec.describe CaseRequest do
  let(:case_reference)    { "TC/2016/04512" }
  let(:confirmation_code) { 'confcode'      }

  subject(:case_request) { described_class.new(case_reference, confirmation_code) }

  let(:fee_liability) {
    instance_double(
      Glimr::Responses::CaseFees::FeeLiability,
      description:  "Fee liability",
      amount:       10_000,
      glimr_id:     '12345'
    )
  }

  let(:fee_liabilities) { [fee_liability] }

  let(:glimr_case_request) {
    instance_double(
      Glimr::Responses::CaseFees,
      title:            "Glimr Case Request",
      fee_liabilities:  fee_liabilities,
      error?:           false
    )
  }

  let(:fee) { instance_double(Fee, update_attributes: nil) }

  describe '#all_fees_paid?' do
    it "knows all fees are paid" do
      case_request.fees << instance_double(Fee, paid?: true)
      expect(case_request.all_fees_paid?).to be_truthy
    end

    it "knows not all fees are paid" do
      case_request.fees << instance_double(Fee, paid?: true)
      case_request.fees << instance_double(Fee, paid?: false)
      expect(case_request.all_fees_paid?).to be_falsey
    end
  end

  describe '#fees' do
    it "has no fees" do
      expect(case_request.fees?).to be_falsey
    end

    it "has fees" do
      case_request.fees << 1
      expect(case_request.fees?).to be_truthy
    end
  end

  describe '#process!' do
    context "when case does not exist in glimr" do
      let(:glimr_case_request) {
        instance_double(
          Glimr::Responses::CaseNotFound,
          error?: true
        )
      }

      before do
        allow(Fee).to receive(:create).and_return(fee)
        allow(Glimr).to receive(:find_case).and_return(glimr_case_request)
      end

      it "adds case not found error" do
        case_request.process!
        expect(case_request).not_to be_valid
        expect(case_request.errors.to_a).to eq(["Could not find a case on our systems with these details."])
      end
    end

    context "when case exists in glimr" do
      before do
        allow(Fee).to receive(:create).and_return(fee)
        allow(Glimr).to receive(:find_case).and_return(glimr_case_request)
      end

      let(:fee_params) {
        {
          case_reference: case_reference,
          case_title: "Glimr Case Request",
          description: "Fee liability",
          amount: 10_000,
          glimr_id: '12345'
        }
      }

      it "is valid" do
        case_request.process!
        expect(case_request).to be_valid
      end

      it "finds the case in glimr" do
        expect(Glimr).to receive(:find_case).with(case_reference, "confcode")
        case_request.process!
      end

      it "creates a fee" do
        expect(Fee).to receive(:create).exactly(:once)
        case_request.process!
      end

      it "creates fee with correct parameters" do
        expect(Fee).to receive(:create).with(fee_params)
        case_request.process!
      end

      it "stores the confirmation_code in the fee" do
        expect(fee).to receive(:update_attributes).exactly(:once).with(confirmation_code: 'confcode')
        case_request.process!
      end

      it "returns the fees created" do
        expect {
          case_request.process!
        }.to change(case_request, :fees).from([]).to([fee])
      end
    end
  end
end
