require 'spec_helper'

describe Api::NodesController do
  before :each do
    @controller.stub(:authenticate_request)

    admin = Factory(:admin_client)
    @controller.stub(:current_client).and_return(admin)
  end

  describe '#create' do
    it 'should create anode' do
      expect {
        request.stub(:body).and_return(StringIO.new({:name => 'Sample1'}.to_json))
        post :create, nil, :content_type => 'application/json'
      }.to change { Node.count }.by(1)

      response.code.should == "201"

      c = JSON.parse(response.body)
      c['uri'].should == 'http://test.host/api/nodes/Sample1'
    end

    it 'should not create a duplicate' do
      node = Factory(:node)

      expect {
        request.stub(:body).and_return(StringIO.new({:name => node.name}.to_json))
        post :create, nil, :content_type => 'application/json'
      }.to_not change { Node.count }

      response.code.should == "409"
    end

    it 'should allow you to set arbitruary values' do
      request.stub(:body).and_return(StringIO.new({:name => 'Sample1', :branch => 'awesome', :foo => 'bar'}.to_json))
      post :create, nil, :content_type => 'application/json'

      response.code.should == "201"

      node = Node.where(:name => 'Sample1').first
      node.should_not be_nil
      node.properties['branch'].should == 'awesome'
      node.properties['foo'].should == 'bar'
    end
  end

  describe '#update' do
    it 'should update an existing node' do
      node = Factory(:node, :properties => { 'foo' => 'bar' })
      node.properties['foo'].should == 'bar'

      request.stub(:body).and_return(StringIO.new({:name => node.name, :foo => 'baz'}.to_json))
      put :update, :id => node.name, :content_type => 'application/json'

      response.code.should == "200"

      node.reload
      node.properties['foo'].should == 'baz'
    end
  end

  describe '#show' do
    it 'should return a node' do
      node = Factory(:node, :properties => { 'foo' => 'bar' })

      get :show, :id => node.name

      response.code.should == "200"

      n = JSON.parse(response.body)
      n.should be_a Chef::Node
      n.name.should == node.name
    end
  end

  describe '#destroy' do
    it 'should remove a node' do
      node = Factory(:node)

      expect {
        delete :destroy, { :id => node.name }
      }.to change { Node.count }.by(-1)

      response.code.should == "200"
    end
  end
end