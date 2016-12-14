Rails.application.routes.draw do
  resources :case_requests,
    only: [:new, :create, :show],
    path_names: { new: '' } do
      collection do
        post :help_with_fees
      end
    end

  resources :payments, only: [:show, :update]
  resources :help_with_fees, only: [:show, :update]
  resources :pay_by_account, only: [:show, :update]

  resources :fees, only: [] do
    member do
      get :pay
      get :post_pay
    end
  end
end
