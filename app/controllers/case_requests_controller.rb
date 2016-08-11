class CaseRequestsController < ApplicationController
  def new
    @case_request = CaseRequest.new
  end

  def create
    @case_request = CaseRequest.new(case_request_params)

    if @case_request.valid?
      @case_request.process!
      render 'show'
    else
      render 'new'
    end
  end

  private

  def case_request_params
    params.require(:case_request).
      permit(:case_reference, :confirmation_code).to_h
  end
end
