require File.expand_path(File.dirname(__FILE__) + '/../../test/spec_helper')

describe "routes" do

  it "routes /user to the index action" , :focus do
    xhr :get, "/users"
  end

  it "should not route http request" do
    get "/users"
    response.status.should eql(404)
  end



end