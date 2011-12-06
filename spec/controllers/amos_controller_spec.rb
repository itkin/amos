require File.expand_path(File.dirname(__FILE__) + '/../../test/spec_helper')
require 'factory_girl'

describe AmosController do

  let(:user) {FactoryGirl.build(:user)}
  let(:recipe) {Factory.build(:recipe, :name => 'Boiled eggs', :description => 'Grab an egg', :user => user)}
  let(:user_list) {mock(ActiveRecord::Relation)}
  let(:recipe_list) {mock(ActiveRecord::Relation)}

   
  context "simple" do

    describe 'GET /user'  do

      context 'successful operation' do

         before(:each) do
          setAbilityAuthorized
          User.stub('where'){user_list}
          user_list.stub('limit'){user_list}
          user_list.stub('offset'){[user]}
          user_list.stub('count'){1}
          @params = {:model => 'user', :limit => 1, :offset => 0}
          end

        it "selects the correct model" do
          get :index, @params
          assigns[:model].should == User
        end

        it "calls the correct method" do
          User.should_receive('where'){user_list}
          get :index, :model => 'user'
        end

        it "returns the correct json data" do
          get :index, :model => 'user'

          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(
              {"data"=>[
                        {"id"=> nil, "name"=>"J Smith", "email"=>"smith@smith.com"}
                       ],
                "count"=>1, "limit"=>nil, "offset"=>nil}.to_json)
        end
      end


      context 'failed authorization' do
        before(:each) do
          setAbilityUnauthorized
         end

         it "returns a 401 error code" do
           get :index, :model => 'user'
           response.status.should == 401
         end

        it "returns the correct json data" do
          get :index, :model => 'user'
          response.body.should == "You are not authorized to access this data"
        end
      end
    end

    describe 'GET /user/?name=' do

      context 'successful operation : single term' do
        before(:each) do
          setAbilityAuthorized
          User.stub('where').with('name' => 'J Smith'){user_list}
          user_list.stub('limit'){user_list}
          user_list.stub('offset'){[user]}
          user_list.stub('count'){1}
          @params = {:model => 'user', :limit => 1, :offset => 0, :name => 'J Smith'}

         end

        it "selects the correct model" do
          get :index, @params
          assigns[:model].should == User
        end

        it "calls the correct method with no field filter" do
          User.stub('where').with(:name => 'J Smith'){user_list}
          get :index, @params
        end

        it "returns the correct json data with no field filter" do
          get :index, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(
          {"data"=>[
              {"id" => nil, "name"=>"J Smith", "email"=>"smith@smith.com"}
            ],
           "count"=>1, "limit"=>1, "offset"=>0}.to_json)
        end

        it "returns the correct json data with field filter" do
          @params.merge!({:fields =>{:only => [ :email ]}})
          get :index, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode({"data"=>[{"email"=>"smith@smith.com"}], "count"=>1, "limit"=>1, "offset"=>0}.to_json)
        end

      end

      context 'successful operation : multiple terms' do
        before(:each) do
          setAbilityAuthorized
          User.stub('where').with('name' => 'J Smith', 'email' => 'smith@smith.com'){user_list}
          user_list.stub('limit'){user_list}
          user_list.stub('offset'){[user]}
          user_list.stub('count'){1}
          @params = {:model => 'user', :limit => 1, :offset => 0, :name => 'J Smith', :email => 'smith@smith.com'}
         end

        it "calls the correct method with no field filter" do
          User.should_receive('where').with('name' => 'J Smith', 'email' => 'smith@smith.com'){user_list}
          get :index, @params
        end

        it "returns the correct json data with no field filter" do
          get :index, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode({"data" =>
          [
              {"id" => nil, "name" => "J Smith", "email"=>"smith@smith.com"}
          ],
          "count" => 1, "limit" => 1, "offset" => 0 }.to_json)
        end
      end


      context 'failed authorization' do
        before(:each) do
          setAbilityUnauthorized
          @params = {:model => 'user', :limit => 1, :offset => 0, :name => 'J Smith'}
         end

         it "returns a 401 error code" do
           get :index, @params
           response.status.should == 401
         end

        it "returns the correct json data" do
          get :index, @params
          response.body.should == "You are not authorized to access this data"
        end
      end
    end


    describe 'GET /user?fields=' do

      context 'successful operation' do
        before(:each) do
          setAbilityAuthorized
          User.stub('where'){user_list}
          user_list.stub('limit'){user_list}
          user_list.stub('offset'){[user, user]}
          user_list.stub('count'){1}
          @params = {:model => 'user', :limit => 1, :offset => 0, :fields => {:only => [:email]}}
         end

        it "selects the correct model" do
          get :index, @params
          assigns[:model].should == User
        end

        it "calls the correct method" do
          User.stub('where'){user_list}
          get :index, @params
        end

        it "returns the correct json data" do
          get :index, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode({ "data" =>
          [
            {"email"=>"smith@smith.com"},
            {"email"=>"smith@smith.com"}
          ], "count" => 1, "limit" => 1, "offset" => 0}.to_json)
        end
      end
    end


    describe 'GET /user/:id' do
      context 'successful operation' do
        before(:each) do
          setAbilityAuthorized
          User.stub('find').with('1'){user}
        end

        it "selects the correct model" do
          get :show, :model => 'users', :id => '1'
          assigns[:model].should == User
        end

        it "calls the correct method" do
          User.should_receive('find').with("1"){user}
          get :show, :model => 'users', :id => '1'
        end

        it "returns the correct json data" do
          get :show, :model => 'users', :id => '1'
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(
              {"id" => nil, "name"=>"J Smith", "email"=>"smith@smith.com"}.to_json)
        end
      end

      context 'failed operation' do
        before(:each) do
          setAbilityAuthorized
          User.stub('find').with('1').and_raise(ActiveRecord::RecordNotFound)
          @params = {:model => 'users', :id => '1'}
        end

        it "returns the correct json data" do
          get :show, @params
          response.body.should == "Record 1 not found"
        end

        it "returns a 400 error code" do
          get :show, @params
          response.status.should == 400
        end
      end
    end

    describe 'GET /user/:id?fields=' do

      context 'successful operation' do
        before(:each) do
          setAbilityAuthorized
          User.stub('find').with("1"){user}
          @params = {:model => 'users', :id => '1', :fields => {:only => [:email]}}
         end

        it "selects the correct model" do
          get  :show, @params
          assigns[:model].should == User
        end

        it "calls the correct method" do
          User.should_receive('find').with("1"){user}
          get  :show, @params
        end

        it "returns the correct json data" do
          get  :show, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode({"email"=>"smith@smith.com"}.to_json)
        end
      end
    end

    describe 'DELETE /user/:id' do

      context 'successful operation' do
        before(:each) do
          setAbilityAuthorized
          User.stub('find').with("1"){user}
          @params = {:model => 'users', :id => '1'}
        end

        it "selects the correct model" do
          delete :destroy, @params
          assigns[:model].should == User
        end

        it "calls the correct method" do
          user.should_receive('destroy')
          delete :destroy, @params
        end

        it "returns a success response" do
          delete :destroy, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(
              {"success"=>"true"}.to_json)
        end
      end

      context 'failed operation' do
        before(:each) do
          setAbilityAuthorized
          @params = {:model => 'users', :id => '1'}
          User.stub('find').with("1").and_raise(ActiveRecord::RecordNotFound)
         end

        it "returns a fail response"  do
          delete :destroy, @params
          response.body.should == "Record 1 not found"
        end

        it "returns a 400 error code" do
           delete :destroy, :model => 'users', :id => '1'
          response.status.should == 400
        end
      end

      context 'failed authorization' do
        before(:each) do
          setAbilityUnauthorizedUser
          User.stub('find').with("1"){user}
         end

         it "returns a 401 error code" do
           delete :destroy, :model => 'users', :id => '1'
           response.status.should == 401
         end

        it "returns the correct json data" do
          delete :destroy, :model => 'users', :id => '1'
          response.body.should  == "You are not authorized to access this data"
        end
      end

    end

    describe 'PUT /user/:id' do
      context 'successful  operation' do
        before(:each) do
          setAbilityAuthorized
          User.should_receive('find').with("1"){user}
          @params = {:model => 'users', :id => '1', :name => 'fred', :email => 'smith'}
        end

        it "selects the correct model" do
          user.stub('update_attributes').with('name' => 'fred', 'email' => 'smith'){true}
          put :update, @params
          assigns[:model].should == User
        end

        it "calls the correct method"  do
          user.should_receive('attributes=').with('name' => 'fred', 'email' => 'smith'){true}
          user.should_receive('save')
          put :update, @params
        end

        it "returns a success response" do
          put :update, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(
              {'name' => 'fred', 'email' => 'smith', "id" => 1}.to_json)
        end
      end

      context 'failed operation' do
        before(:each) do
          setAbilityAuthorized
          User.stub('find').with("1"){user}
          user.stub('save'){false}
          user.stub('errors'){{:email => ["can't be blank"]}}
          @params = {:model => 'users', :id => '1', :name => '', :email => ''}
        end

        it "returns a fail response" do
          put :update, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(
              {"email"=>["can't be blank"]}.to_json)
        end

        it "returns a 400 error code" do
          put :update, @params
          response.status.should == 400
        end

      end
      context 'failed authorization' do
        before(:each) do
          setAbilityUnauthorizedUser
          User.stub('find').with("1"){user}
          @params = { :model => 'users', :id => '1', :name => 'fred', :email => ''}
         end

         it "returns a 401 error code" do
           put :update, @params
           response.status.should == 401
         end

        it "returns the correct json data" do
          put :update, @params
          response.body.should == "You are not authorized to access this data"
        end
      end
    end

    describe 'POST /user' do

      context 'successful operation' do
        before(:each) do
          setAbilityAuthorized
          @auser = User.new(:name => 'J Smith', :email => 'smith@smith.com')
          User.stub(:new){@auser}
          user.stub('save'){true}
          @params = {:model => 'users', :name => 'J Smith', :email => 'smith@smith.com'}
        end

        it "selects the correct model" do
          post :create, @params
          assigns[:model].should == User
        end

        it "calls the correct method" do
          User.should_receive(:new).with("name" => "J Smith", 'email' => 'smith@smith.com' ).and_return(user)
          post :create, @params
        end

        it "returns a success response" do
          post :create, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(
              {"id" => nil, "name"=>"J Smith", "email"=>"smith@smith.com"}.to_json)
        end
      end

      context 'failed operation' do
        before(:each) do
          @params = {:model => 'users', :name => 'J Smith'}
        end

        it "returns a fail response" do
          post :create, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(
              {"email"=>["can't be blank"]}.to_json)
        end

        it "returns a 400 error code" do
          post :create, @params
          response.status.should == 400
        end

      end

      context 'failed authorization' do
        before(:each) do
          setAbilityUnauthorizedUser
          User.stub('find').with(1){user}
          @params = {:model => 'users', :name => 'J Smith'}
         end

         it "returns a 401 error code" do
           post :create, @params
           response.status.should == 401
         end

        it "returns the correct json data" do
          post :create, @params
          response.body.should == "You are not authorized to access this data"
        end
      end

    end

    describe 'handling associations' do

      describe 'single association' do
        before(:each) do
          setAbilityAuthorized
          User.should_receive('find').with('1'){user}
          user.stub('recipes'){[recipe, recipe]}
          @params = {
                      :model => 'users', :id => '1',
                      :fields => { :only => [:name], :include => :recipes }
                }
        end

         it 'fetches the correct association' do
          user.should_receive('recipes')
          get :show, @params
        end

        it "returns the correct json data"  do
          get :show, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(
              {"name"=>"J Smith",
                "recipes" => [
                  {"id" => nil, 'name' => 'Boiled eggs', 'description' => 'Grab an egg', "userId" => nil},
                  {"id" => nil, 'name' => 'Boiled eggs', 'description' => 'Grab an egg', "userId" => nil}
                ]
              }.to_json)
        end
      end

      describe 'multiple associations' do
        before(:each) do
          setAbilityAuthorized
          User.should_receive('find').with('1'){user}
          user.stub('recipes'){[recipe, recipe]}
          user.stub('shops'){[recipe, recipe]}
          @params = {
                      :model => 'users', :id => '1',
                      :fields => { :only => [:name, :email], :include => [:recipes, :shops] }
                }
        end

        it 'fetches the correct associations' do
          user.should_receive('recipes')
          user.should_receive('shops')
          get :show, @params
        end

        it "returns the correct json data" do
          get :show, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(
              {"name"=>"J Smith", "email"=>"smith@smith.com",
                "recipes" => [
                  {"id" => nil, 'name' => 'Boiled eggs', 'description' => 'Grab an egg', "userId"=>nil},
                  {"id" => nil, 'name' => 'Boiled eggs', 'description' => 'Grab an egg', "userId"=>nil}
                ],
                "shops" => [
                  {"id" => nil, 'name' => 'Boiled eggs', 'description' => 'Grab an egg', "userId"=>nil},
                  {"id" => nil, 'name' => 'Boiled eggs', 'description' => 'Grab an egg', "userId"=>nil}
                ]
              }.to_json)
        end
      end

   end
 end
  context "nested" do

    describe 'GET /users/1/recipes' do
      before do
        @params = {:parent_model => "users", :parent_id => "1", :model => 'recipes', :limit => 1, :offset => 0}
      end
      context 'successful operation'  do
        before(:each) do
          setAbilityAuthorized
          User.stub('find'){user}
          user.stub(:recipes){recipe_list}
          recipe_list.stub(:list){recipe_list}
          recipe_list.stub('limit'){recipe_list}
          recipe_list.stub('offset'){[recipe]}
          recipe_list.stub('count'){1}
        end

        it "selects the correct model" do
          get :index, @params
          assigns[:model].should == Recipe
        end

        it "calls the correct method" do
          User.should_receive('find'){user}
          user.should_receive("recipes"){recipe_list}
          recipe_list.should_receive('list'){recipe_list}
          get :index,  @params
        end

        it "returns the correct json data"  do
          get :index,  @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(
              {"data"=>[{"id"=> nil, "name"=>"Boiled eggs", "description"=>"Grab an egg", "userId" => nil}],
              "count"=>1, "limit"=>1, "offset"=>0}.to_json
          )
        end
      end


      context 'failed authorization'  do
        before(:each) do
          setAbilityUnauthorized
          User.stub('find'){user}
         end

         it "returns a 401 error code" do
           get :index, @params
           response.status.should == 401
         end

        it "returns the correct json data" do
          get :index, @params
          response.body.should == "You are not authorized to access this data"
        end
      end
    end

    describe 'GET /users/1/recipes/:id' do
      before do
        @params = { :parent_model => 'users',  :parent_id =>"1", :model => "recipes", :id => '1' }
      end
      context 'successful operation'  do
        before(:each) do
          setAbilityAuthorized
          User.stub(:find).with("1"){user}
          user.stub(:recipes){recipe_list}
          recipe_list.stub(:find){recipe}

        end

        it "selects the correct model"   do
          get :show, @params
          assigns[:model].should == Recipe
        end

        it "selects the correct parent model" do
          get :show, @params
          assigns[:parent_model].should == User
        end

        it "calls the correct method" do
          User.should_receive(:find).with("1"){user}
          user.should_receive(:recipes){recipe_list}
          recipe_list.should_receive(:find).with("1"){recipe}
          get :show, @params
        end

        it "returns the correct json data" do
          get :show, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(
              {"id"=> nil, "name"=>"Boiled eggs", "description"=>"Grab an egg", "userId" => nil}.to_json)
        end
      end

      context 'failed operation' do
        before(:each) do
          setAbilityAuthorized
          User.stub('find').with('1').and_raise(ActiveRecord::RecordNotFound)
        end

        it "returns the correct json data" do
          get :show, @params
          response.body.should == "Parent record users 1 not found"
        end

        it "returns a 400 error code" do
          get :show, @params
          response.status.should == 400
        end
      end
    end

    describe 'DELETE /user/:id' do
      before do
        @params = { :parent_model => 'users',  :parent_id =>"1", :model => "recipes", :id => '1' }
      end
      context 'successful operation'  do
        before(:each) do
          setAbilityAuthorized
          User.stub('find').with("1"){user}
          user.should_receive(:recipes){recipe_list}
          recipe_list.should_receive(:find).with("1"){recipe}
        end

        it "selects the correct model" do
          delete :destroy, @params
          assigns[:model].should == Recipe
        end

        it "calls the correct method" do
          recipe.should_receive('destroy')
          delete :destroy, @params
        end

        it "returns a success response" do
          delete :destroy, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(
              {"success"=>"true"}.to_json)
        end
      end

      context 'failed operation' do
        before(:each) do
          setAbilityAuthorized
          User.stub('find').with("1"){user}
          user.stub(:recipes){recipe_list}
          recipe_list.stub(:find).and_raise(ActiveRecord::RecordNotFound)
         end

        it "returns a 400 error code" do
          delete :destroy, @params
          response.status.should == 400
        end
      end

      context 'failed authorization' do
        before(:each) do
          setAbilityUnauthorized
          User.stub('find').with("1"){user}
          user.stub(:recipes){recipe_list}
          recipe_list.should_receive(:find).with("1"){recipe}
         end

         it "returns a 401 error code" do
           delete :destroy, @params
           response.status.should == 401
         end

        it "returns the correct json data" do
          delete :destroy, @params
          response.body.should == "You are not authorized to access this data"
        end
      end

    end

    describe 'PUT /users/1/recipes/:id'  do
      before do

      end
      context 'successful  operation' do
        before(:each) do
          setAbilityAuthorized
          User.stub('find').with("1"){user}
          user.stub(:recipes){recipe_list}
          recipe_list.should_receive(:find).with("1"){recipe}
          @params = { :parent_model => 'users',  :parent_id =>"1", :model => "recipes", :id => '1', 'name' => 'fred', 'description' => 'smith' }
        end

        it "selects the correct model" do
          put :update, @params
          assigns[:parent_model].should == User
          assigns[:model].should == Recipe
        end

        it "calls the correct method"  do
          recipe.should_receive('attributes=').with('name' => 'fred', 'description' => 'smith')
          user.should_receive('save'){true}
          put :update, @params
        end

        it "returns a success response" do
          recipe.stub('attributes=').with('name' => 'fred', 'description' => 'smith')
          user.stub('save'){true}
          put :update, @params
          response.body.should == recipe.to_json
        end
      end

      context 'failed operation' do
        before(:each) do
          setAbilityAuthorized
          User.stub('find').with("1"){user}
          user.stub('recipes'){recipe_list}
          recipe_list.stub('find').with("1"){recipe}
          user.stub('save'){false}
          recipe.stub('errors'){{:name => ["can't be blank"]}}
          @params = { :parent_model => 'users',  :parent_id =>"1", :model => "recipes", :id => '1', 'name' => '' }
        end

        it "returns a fail response" do
          put :update, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(
              {"name"=>["can't be blank"]}.to_json)
        end

        it "returns a 400 error code" do
          put :update, @params
          response.status.should == 400
        end

      end


    end

    describe 'POST /users/1/recipes' do

      context 'successful operation' do
        before(:each) do
          setAbilityAuthorized
          @attrs = {:name => "test", :description => "description" }
          @params = { :parent_model => 'users',  :parent_id =>"1", :model => "recipes",  :recipe => @attrs }
        end

        it "calls the correct method" do
          User.should_receive(:find).with("1"){ user }
          user.should_receive(:recipes){ recipe_list }
          recipe_list.should_receive(:new).with(@attrs.stringify_keys){ Recipe.new(@attrs) }
          post :create, @params
        end

        it "returns a success response" do
          User.should_receive(:find).with("1"){ user }
          user.should_receive(:recipes){ recipe_list }
          recipe_list.should_receive(:new).with(@attrs.stringify_keys){ Recipe.new(@attrs) }
          post :create, @params
          ActiveSupport::JSON.decode(response.body).should ==
          ActiveSupport::JSON.decode(@attrs.stringify_keys.update("id" =>nil, "userId"=>nil).to_json)
        end
      end
    end
  end

  def setAbilityAuthorized
    eval <<-eos
  	class Ability
  	  include CanCan::Ability

  	  def initialize(user)
  	    can :manage, :all
  	  end
  	end

    class ApplicationController < ActionController::Base
      def current_user
        nil
      end
    end

    eos

  end

  def setAbilityUnauthorized
    eval <<-eos
  	class Ability
  	  include CanCan::Ability

  	  def initialize(user)
  	    cannot :manage, :all
  	  end
  	end

    class ApplicationController < ActionController::Base
      def current_user
        nil
      end
    end

    eos

  end

  def setAbilityUnauthorizedUser
    eval <<-eos
  	class Ability
  	  include CanCan::Ability

  	  def initialize(user)
  	    can :read, User
  	    cannot :delete, User
  	    cannot :update, User
  	    cannot :create, User
  	  end
  	end

    class ApplicationController < ActionController::Base
      def current_user
        nil
      end
    end

    eos

  end

end
