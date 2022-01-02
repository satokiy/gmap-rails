Rails.application.routes.draw do
  resources :maps
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root :to => 'geocode#index'
  get '/geocode' => "geocode#top"
  post '/geocode' => "geocode#search"
  get '/chart' => "chart#top"
  post '/geocode/import' => "geocode#import"
  post '/geocode/s3_upload'  => "geocode#s3_upload"
  get '/geocode/s3_upload'  => "geocode#top"
  get '/geocode/download' => "geocode#download"
  
end
