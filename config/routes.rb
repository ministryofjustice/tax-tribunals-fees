Rails.application.routes.draw do
  get '/pages/*id' => 'pages#show', as: :page, format: false

  root to: 'pages#show', id: 'start'

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
