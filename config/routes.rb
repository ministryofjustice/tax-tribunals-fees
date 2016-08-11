Rails.application.routes.draw do
  resources :case_requests,
    only: [:new, :create],
    path_names: { new: '' }

  resources :fees, only: [] do
    member do
      get :pay
      get :post_pay
    end
  end
end
