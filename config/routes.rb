Rails.application.routes.draw do
  post 'google_login' => 'users#google_login'
  post 'tokens/refresh' => 'tokens#refresh'

  put 'users/master_update' => 'users#master_update'

  resources :mentee_applicants, only: %i[index create]
  
  resources :mentor_applicants, only: %i[index create]

  resources :users, only: [] do
    get 'events', on: :member
    post 'mail', on: :member
  end

  resources :users, only: %i[show update index]

  post 'mentors/batch' => 'mentors#batch'
  post 'mentors/master' => 'mentors#master'

  resources :mentors, only: %i[index create]

  resources :mentees, only: [] do
    post 'match', on: :member
    post 'unmatch', on: :member
  end

  post 'mentees/batch' => 'mentees#batch'

  resources :mentees, only: %i[index create]

  get 'events/public' => 'events#public'

  resources :events, only: [] do
    post 'register', on: :member
    post 'unregister', on: :member
    post 'public_register', on: :member
    post 'join', on: :member
    post 'public_join', on: :member
  end

  resources :events, only: %i[index create update destroy]

  resources :newsletter_emails, only: %i[index create]
  
  post 'google_sheets/import_mentee_mentor' => 'google_sheets#import_mentee_mentor'
  post 'google_sheets/import_events' => 'google_sheets#import_events'
  post 'google_sheets/export_registered' => 'google_sheets#export_registered'
  post 'google_sheets/export_joined' => 'google_sheets#export_joined'

  post 'emails/mail' => 'emails#mail'

end
