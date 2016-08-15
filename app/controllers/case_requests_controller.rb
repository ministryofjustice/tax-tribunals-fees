class CaseRequestsController < ApplicationController
  def new
    @case_request = CaseRequest.new(nil, nil)
  end

  def create
    case_reference, confirmation_code = case_request_params
    @case_request = CaseRequest.new(case_reference, confirmation_code)

    if @case_request.valid?
      @case_request.process!
      render 'show'
    else
      render 'new'
    end
  end

  private

  def case_request_params
    p = params.
        require(:case_request).
        permit(:case_reference, :confirmation_code).
        to_h
    [p.fetch(:case_reference), p.fetch(:confirmation_code)]
  end
end
