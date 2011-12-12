require File.expand_path(File.dirname(__FILE__) + '/../../test/spec_helper')

describe "AMOS " do
  it "routes /user to the index action"  do
    { :get => "/user" }.
      should route_to(:controller => "amos", :action => "index", :model => 'user', :format => "json")
  end

  it "routes /user.json to the index action" do
    { :get => "/user.json" }.
      should route_to(:controller => "amos", :action => "index", :model => 'user', :format => "json")
  end

  # it "routes /user/query to the query action" do
  #   { :get => "/user/find/by_name" }.
  #     should route_to(:controller => "amos", :action => "find", :model => 'user', :query => 'by_name')
  # end

  it "routes show /user/1 to the show action" do
    { :get => "/users/1" }.
      should route_to(:controller => "amos", :action => "show", :model => 'users', :id => '1', :format => "json")
  end

  it "routes delete /user/1 to the destroy action" do
    { :delete => "/users/1" }.
      should route_to(:controller => "amos", :action => "destroy", :model => 'users', :id => '1', :format => "json")
  end

  it "routes put /user/1 to the update action" do
    { :put => "/users/1" }.
      should route_to(:controller => "amos", :action => "update", :model => 'users', :id => '1', :format => "json")
  end

  it "routes post /user to the create action" do
    { :post => "/users" }.
      should route_to(:controller => "amos", :action => "create", :model => 'users', :format => "json")
  end

end

describe "Nested AMOS" do

  it "routes /users/1/recipes.json to the index action"  do
    { :get => "/users/1/recipes" }.
      should route_to(:controller => "amos", :action => "index", :parent_model => "users", :model => 'recipes', :parent_id => "1", :format => "json")
  end

  it "routes /users/1/recipes/1 to the show action"  do
    { :get => "/users/1/recipes/1" }.
      should route_to(:controller => "amos", :action => "show", :parent_model => "users", :model => 'recipes', :parent_id => "1", :id => "1", :format => "json")
  end

  it "routes delete /users/1/recipes/1 to the destroy action" do
    { :delete => "/users/1/recipes/1" }.
      should route_to(:controller => "amos", :action => "destroy", :parent_model => "users", :model => 'recipes', :id => "1", :parent_id => "1", :format => "json")
  end

  it "routes put /users/1/recipes/1 to the update action" do
    { :put => "/users/1/recipes/1" }.
      should route_to(:controller => "amos", :action => "update", :parent_model => "users", :model => 'recipes', :id => "1", :parent_id => "1", :format => "json")
  end

  it "routes post /users/1/recipes to the create action" do
    { :post => "/users/1/recipes" }.
      should route_to(:controller => "amos", :action => "create", :parent_model => "users", :model => 'recipes', :parent_id => "1", :format => "json")
  end

end