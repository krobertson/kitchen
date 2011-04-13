require 'spec_helper'

describe Api::EnvironmentsController do
  before :each do
    @controller.stub(:authenticate_request)
  end

  describe '#create' do
    it 'should create an environment' do
      admin = Factory(:admin_client)
      @controller.stub(:current_client).and_return(admin)

      expect {
        request.stub(:body).and_return(StringIO.new({:name => 'Sample1'}.to_json))
        post :create, nil, :content_type => 'application/json'
      }.to change { Environment.count }.by(1)

      response.code.should == "201"

      c = JSON.parse(response.body)
      c['uri'].should == 'http://test.host/api/environments/Sample1'
    end

    it 'should not create a duplicate' do
      admin = Factory(:admin_client)
      @controller.stub(:current_client).and_return(admin)

      env = Factory(:environment)

      expect {
        request.stub(:body).and_return(StringIO.new({:name => env.name}.to_json))
        post :create, nil, :content_type => 'application/json'
      }.to_not change { Environment.count }

      response.code.should == "409"
    end

    it 'should allow you to set arbitruary values' do
      admin = Factory(:admin_client)
      @controller.stub(:current_client).and_return(admin)

      request.stub(:body).and_return(StringIO.new({:name => 'Sample1', :branch => 'awesome', :foo => 'bar'}.to_json))
      post :create, nil, :content_type => 'application/json'

      response.code.should == "201"

      env = Environment.where(:name => 'Sample1').first
      env.should_not be_nil
      env.properties['branch'].should == 'awesome'
      env.properties['foo'].should == 'bar'
    end
  end

  describe '#update' do
    it 'should update an existing environment' do
      admin = Factory(:admin_client)
      @controller.stub(:current_client).and_return(admin)

      env = Factory(:environment, :properties => { 'foo' => 'bar' })
      env.properties['foo'].should == 'bar'

      request.stub(:body).and_return(StringIO.new({:name => env.name, :foo => 'baz'}.to_json))
      put :update, :id => env.name, :content_type => 'application/json'

      response.code.should == "200"

      env.reload
      env.properties['foo'].should == 'baz'
    end
  end

  describe '#show' do
    it 'should return an environment' do
      admin = Factory(:admin_client)
      @controller.stub(:current_client).and_return(admin)

      env = Factory(:environment, :properties => { 'foo' => 'bar' })

      get :show, :id => env.name

      response.code.should == "200"

      e = JSON.parse(response.body)
      e.should be_a Chef::Environment
      e.name.should == env.name
    end
  end

  describe '#destroy' do
    it 'should remove an environment' do
      admin = Factory(:admin_client)
      @controller.stub(:current_client).and_return(admin)

      env = Factory(:environment)

      expect {
        delete :destroy, { :id => env.name }
      }.to change { Environment.count }.by(-1)

      response.code.should == "200"
    end
  end
end