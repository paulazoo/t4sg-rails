Rails.application.routes.draw do
  post 'signin' => 'users#signin'
  post 'tokens/refresh' => 'tokens#refresh'

  resources :users, only: %i[show create index]
  
  post 'emails/mail' => 'emails#mail'

end
