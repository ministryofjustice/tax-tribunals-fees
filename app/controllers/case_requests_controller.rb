class CaseRequestsController < ApplicationController
  rescue_from GlimrApiClient::Case::InvalidCaseNumber, with: :case_not_found
  include SimplifiedLogging

  protect_from_forgery unless: -> { request.format.json? }

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

  def show
    @case_request = CaseRequest.find_by(id: params[:id])
    unless @case_request
      log_error(self.class.name,
        'N/A',
        'case_not_found',
        case_request_id: params[:id])
      flash[:alert] = t('.case_not_found')
      redirect_to new_case_request_url
    end
  end

  private

  def case_not_found(exception)
    log_error(self.class.name, 'N/A', exception, case_request_id: params[:id])
    respond_to do |format|
      format.html do
        flash[:notice] = t('case_requests.could_not_find_case_html')
        redirect_to case_requests_url
      end
      format.json do
        render json: { error: t('.case_not_found') }
      end
    end
  end

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
      case_request.process!

      render json: { return_url: redirect_url }
    else
      render json: { error: case_request.errors }
    end
  end

  def redirect_url
    if ENV['EXTERNAL_URL']
      ENV['EXTERNAL_URL'] + case_request_path(@case_request.id)
    else
      case_request_url(@case_request.id)
    end
  end

  def case_request_params
    params.require(:case_request).permit(:case_reference, :confirmation_code)
  end
end
