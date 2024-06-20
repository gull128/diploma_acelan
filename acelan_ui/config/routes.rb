Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html


  get '/fds', to: "fds#index"
  post '/fds_params', to: "fds#solve"
  get '/fds/result/:id', to: "fds#result"
  get '/fds/error', to: "fds#error"
end
