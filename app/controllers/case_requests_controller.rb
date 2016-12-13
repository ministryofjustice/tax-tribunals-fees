class CaseRequestsController < ApplicationController
  def new
    @case_request = CaseRequest.new
  end

  def create
    @case_request = CaseRequest.new(case_request_params)

    respond_to do |format|
      if @case_request.valid?
        @case_request.process!
        format.html { render 'show' }
      else
        format.html { render 'new' }
      end
    end
  end

  private

  def case_request_params
    params.require(:case_request).permit(:case_reference, :confirmation_code)
  end
end
