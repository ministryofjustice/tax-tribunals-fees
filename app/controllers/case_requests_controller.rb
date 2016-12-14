class CaseRequestsController < ApplicationController
  def new
    @case_request = CaseRequest.new
  end

  def create
    @case_request = CaseRequest.new(case_request_params)

    respond_to do |format|
      format.html do
        process_html(@case_request)
      end
      format.json do
        process_json(@case_request)
      end
    end
  end

  private

  def process_html(case_request)
    if case_request.save
      case_request.process!
      render 'show'
    else
      render 'new'
    end
  end

  def process_json(case_request)
    if case_request.save
      render json: { return_url: case_request_url(@case_request.id) }
    end
  end

  def case_request_params
    params.require(:case_request).permit(:case_reference, :confirmation_code)
  end
end
