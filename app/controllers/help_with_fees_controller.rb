class HelpWithFeesController < ApplicationController
  def show
    @fee = Fee.find(params[:id])
  end

  def update
    @fee = Fee.find(params[:id])
    if @fee
      @fee.update_column(:help_with_fees_reference, help_with_fees_params)
    end
    redirect_to payment_url(@fee)
  end

  private

  def help_with_fees_params
    params.require(:help_with_fees_reference)
  end
end
