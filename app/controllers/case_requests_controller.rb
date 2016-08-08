class CaseRequestsController < ApplicationController
  def new
    @case_request = CaseRequest.new
  end

  def create
    @case_request = CaseRequest.find_or_initialize_by(case_request_params)

    if @case_request.save
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
