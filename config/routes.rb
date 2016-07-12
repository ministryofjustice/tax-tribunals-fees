Rails.application.routes.draw do
  # Root route is handled by the high_voltage gem.  See
  # config/initializers/high_voltage.rb

  resources :liabilities, only: [] do
    member do
      get :pay
      get :post_pay
    end
  end
end
