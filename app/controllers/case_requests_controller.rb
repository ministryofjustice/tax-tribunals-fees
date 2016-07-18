class CaseRequestsController < ApplicationController
  def new
    @case_request_form = Forms::NewCaseRequest.new
  end

  def create
    @case_request_form = Forms::NewCaseRequest.new(case_request_params)

    if @case_request_form.save
      @case_request = @case_request_form.case_request
      render 'show'
    else
      render 'new'
    end
  end

  private

  def case_request_params
    params.require(:forms_new_case_request).
      permit(:case_reference, :confirmation_code).to_h
  end
end
