class CaseRequestsController < ApplicationController
  def new
    @case_request_form = Forms::NewCaseRequest.new
  end

  def create
    if case_request
      render 'show'
    elsif case_request_form.save
      @case_request = case_request_form.case_request
      render 'show'
    else
      render 'new'
    end
  end

  private

  def case_request
    @case_request ||= CaseRequest.find_by(
      case_reference: case_request_params[:case_reference]
    )
  end

  def case_request_form
    @case_request_form ||= Forms::NewCaseRequest.new(case_request_params)
  end

  def case_request_params
    params.require(:forms_new_case_request).
      permit(:case_reference, :confirmation_code).to_h
  end
end
