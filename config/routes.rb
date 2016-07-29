Rails.application.routes.draw do
  resources :case_requests,
    only: [:new, :create],
    path_names: { new: '' }

  resources :liabilities, only: [] do
    member do
      get :pay
      get :post_pay
    end
  end
end
