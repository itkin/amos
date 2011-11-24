Rails.application.routes.draw do

  match ":model/:id.:format" => "amos#show", :constraints => { :model => /.*/ }, :via => :get
  match ":model/:id.:format" => "amos#destroy", :constraints => { :model => /.*/ }, :via => :delete
  match ":model/:id.:format" => "amos#update", :constraints => { :model => /.*/ }, :via => :put
  match ":model.:format" => "amos#create", :constraints => { :model => /.*/ }, :via => :post
  match ":model.:format" => "amos#index", :constraints => { :model => /.*/ }

  match ":parent/:parent_id/:model/:id.:format" => "amos#show", :constraints => { :model => /.*/ }, :via => :get
  match ":parent/:parent_id/:model/:id.:format" => "amos#destroy", :constraints => { :model => /.*/ }, :via => :delete
  match ":parent/:parent_id/:model/:id.:format" => "amos#update", :constraints => { :model => /.*/ }, :via => :put
  match ":parent/:parent_id/:model.:format" => "amos#create", :constraints => { :model => /.*/ }, :via => :post
  match ":parent/:parent_id/:model.:format" => "amos#index", :constraints => { :model => /.*/ }

end