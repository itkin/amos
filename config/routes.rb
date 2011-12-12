Rails.application.routes.draw do
  #class AmosConstraints
  #  def self.matches?(request)
  #    request.xhr? and not request.params[:model].blank? and request.params[:format] == "json"
  #  end
  #end

  match ":model/:id(.:format)" => "amos#show", :constraints => {:format => "json"}, :via => :get, :format => "json"
  match ":model/:id(.:format)" => "amos#destroy", :constraints => {:format => "json"}, :via => :delete, :format => "json"
  match ":model/:id(.:format)" => "amos#update", :constraints => {:format => "json"}, :via => :put, :format => "json"
  match ":model(.:format)" => "amos#create", :constraints => {:format => "json"}, :via => :post, :format => "json"
  match ":model(.:format)" => "amos#index", :constraints => {:format => "json"}, :format => "json"

  match ":parent_model/:parent_id/:model/:id(.:format)" => "amos#show", :constraints => {:format => "json"}, :via => :get, :format => "json"
  match ":parent_model/:parent_id/:model/:id(.:format)" => "amos#destroy", :constraints => {:format => "json"}, :via => :delete, :format => "json"
  match ":parent_model/:parent_id/:model/:id(.:format)" => "amos#update", :constraints => {:format => "json"}, :via => :put, :format => "json"
  match ":parent_model/:parent_id/:model(.:format)" => "amos#create", :constraints => {:format => "json"}, :via => :post, :format => "json"
  match ":parent_model/:parent_id/:model(.:format)" => "amos#index", :constraints => {:format => "json"}, :format => "json"

end