Rails.application.routes.draw do
  class AmosConstraints
    def self.matches?(request)
      request.xhr? and not request.params[:model].blank? and request.params[:format] == "json"
    end
  end

  match ":model/:id(.:format)" => "amos#show", :constraints => AmosConstraints, :via => :get, :format => "json"
  match ":model/:id(.:format)" => "amos#destroy", :constraints => AmosConstraints, :via => :delete, :format => "json"
  match ":model/:id(.:format)" => "amos#update", :constraints => AmosConstraints, :via => :put, :format => "json"
  match ":model(.:format)" => "amos#create", :constraints => AmosConstraints, :via => :post, :format => "json"
  match ":model(.:format)" => "amos#index", :constraints => AmosConstraints, :format => "json"

  match ":parent_model/:parent_id/:model/:id(.:format)" => "amos#show", :constraints => AmosConstraints, :via => :get, :format => "json"
  match ":parent_model/:parent_id/:model/:id(.:format)" => "amos#destroy", :constraints => AmosConstraints, :via => :delete, :format => "json"
  match ":parent_model/:parent_id/:model/:id(.:format)" => "amos#update", :constraints => AmosConstraints, :via => :put, :format => "json"
  match ":parent_model/:parent_id/:model(.:format)" => "amos#create", :constraints => AmosConstraints, :via => :post, :format => "json"
  match ":parent_model/:parent_id/:model(.:format)" => "amos#index", :constraints => AmosConstraints, :format => "json"

end