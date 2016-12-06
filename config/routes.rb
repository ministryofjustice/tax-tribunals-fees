Rails.application.routes.draw do
  resources :case_requests, only: [:new, :create], path_names: { new: '' } do
    collection do
      post :help_with_fees
    end
  end

  resources :payment_methods, only: [:update]

  resources :fees, only: [] do
    member do
      get :pay
      get :post_pay
    end
  end
end
