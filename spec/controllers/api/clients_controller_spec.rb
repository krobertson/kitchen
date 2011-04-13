require 'spec_helper'

# params_in = {:http_method => :GET, :path => "/clients", :body => "", :host => "localhost"}
#request_params             = request_params.dup
#request_params[:timestamp] = Time.now.utc.iso8601
#request_params[:user_id]   = client_name
#host = request_params.delete(:host) || "localhost"

#sign_obj = Mixlib::Authentication::SignedHeaderAuth.signing_object(request_params)
#signed =  sign_obj.sign(key).merge({:host => host})

#sign_request("POST", request_path, OpenSSL::PKey::RSA.new(IO.read("#{tmpdir}/client.pem")), "bobo")


describe Api::ClientsController do
  before :each do
    @controller.stub(:authenticate_request)
  end

  describe '#create' do
    it 'should create a client' do
      validator = Factory(:validator_client)
      @controller.stub(:current_client).and_return(validator)

      expect {
        post :create, { :name => 'Sample1', :admin => false }
      }.to change { Client.count }.by(1)

      c = JSON.parse(response.body)
      c['private_key'].should_not be_nil
    end

    it 'should change a client to be not an admin if the client isn\'t an admin' do
      validator = Factory(:validator_client)
      @controller.stub(:current_client).and_return(validator)

      expect {
        post :create, { :name => 'Sample1', :admin => true }
      }.to change { Client.count }.by(1)

      Client.where(:name => 'Sample1').first.admin.should == false
    end

    it 'should let an admin create an admin' do
      admin = Factory(:admin_client)
      @controller.stub(:current_client).and_return(admin)

      expect {
        post :create, { :name => 'Sample1', :admin => true }
      }.to change { Client.count }.by(1)

      Client.where(:name => 'Sample1').first.admin.should == true
    end

    it 'should reject duplicate names' do
      validator = Factory(:validator_client)
      @controller.stub(:current_client).and_return(validator)

      client = Factory(:client)

      expect {
        post :create, { :name => client.name, :admin => false }
      }.to_not change { Client.count }

      response.code.should == "409"
    end
  end

  describe '#update' do
    it 'should let an admin update the admin status' do
      admin = Factory(:admin_client)
      @controller.stub(:current_client).and_return(admin)

      client = Factory(:client)

      put :update, { :id => client.name, :admin => true }

      response.code.should == "200"

      client.reload
      client.admin.should == true
    end

    it 'should regenerate a private key when requested' do
      admin = Factory(:admin_client)
      @controller.stub(:current_client).and_return(admin)

      client = Factory(:client)
      client.create_keys
      client.save!
      pub_key = client.public_key.dup

      put :update, { :id => client.name, :private_key => true }

      response.code.should == "200"

      client.reload
      client.public_key.should_not == pub_key

      c = JSON.parse(response.body)
      c['private_key'].should_not be_nil
    end

    it 'should not normally regenerate a private key' do
      admin = Factory(:admin_client)
      @controller.stub(:current_client).and_return(admin)

      client = Factory(:client)
      client.create_keys
      client.save!

      put :update, { :id => client.name, :admin => true }

      response.code.should == "200"

      c = JSON.parse(response.body)
      c['private_key'].should be_nil
    end
  end

  describe '#show' do
    it 'should return a client' do
      client = Factory(:client)
      @controller.stub(:current_client).and_return(client)

      get :show, :id => client.name

      response.code.should == "200"

      c = JSON.parse(response.body)
      c.should be_a Chef::ApiClient
      c.name.should == client.name
    end
  end

  describe '#destroy' do
    it 'should remove a user' do
      admin = Factory(:admin_client)
      @controller.stub(:current_client).and_return(admin)

      client = Factory(:client)

      expect {
        delete :destroy, { :id => client.name }
      }.to change { Client.count }.by(-1)

      response.code.should == "200"
    end
  end
end