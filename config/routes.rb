Rails.application.routes.draw do
  devise_for :users, controllers: {registrations: 'users/registrations'}

  scope :document_analyses, controller: 'analysis', as: 'analyses' do
    get :task_page
    post :execute_task
  end

  post '/ajax_api' => 'ajax#multiplex'
  get '/ajax_api' => 'ajax#multiplex'
  
  scope :twitter, as: 'twitter', controller: 'twitters' do
    get :authorize_twitter
    get :set_twitter_token    

    get :schedule
    post :schedule
    
    get :index
    get :input_handle
    post :twitter_call
    post :batch_call
    
    get "/analysis(/:handle)", action: :analyze, as: :profile_analysis
    get '/feed(/:handle)', action: :feed, as: :feed
  end
  
  resources 'redirect_maps', path: 'r', only: [:show]
  
  # Admin
  require 'sidekiq/web'
  #authenticate :admin, lambda { |u| u.is_a? Admin } do
  mount Sidekiq::Web => '/sidekiq_ui'
  #end
end
