class Api::ClientsController < Api::ApiController

  before_filter :authenticate_request
  before_filter :ensure_admin, :only => [ :index, :update, :destroy ]
  before_filter :ensure_admin_or_validator, :only => [ :create ]
  before_filter :ensure_admin_or_requestor, :only => [ :show ]

  def index
    render :json => Client.all.inject({}) { |s,c| s[c.name] = api_client_url(c.name); s }
  end

  def create
    client = Client.where(:name => params[:name]).first
    render :status => 409, :text => "Client with name #{client.name} is already taken" and return if client

    client = Client.new({ :name => params[:name], :admin => current_client.admin? ? params[:admin] : false })
    client.create_keys

    if client.save
      headers['Location'] = api_client_url(client.name)
      render :json => { 'uri' => api_client_url(client.name), 'private_key' => client.private_key }, :status => 201
    else
      render :status => 409, :text => "Client with name #{client.name} is already taken"
    end
  end

  def update
    client = Client.where(:name => params[:id]).first
    client.admin = params[:admin] if current_client.admin?

    response = { 'name' => client.name, 'admin' => client.admin }
    
    if params[:private_key] == true
      client.create_keys
      response['private_key'] = client.private_key
    end

    if client.save
      render :json => response
    else
      render :status => 409, :nothing => true
    end
  end

  def show
    client = Client.where(:name => params[:id]).first
    api_client = Chef::ApiClient.json_create('name' => client.name, 'admin' => client.admin, 'public_key' => client.public_key)
    render :json => api_client
  end

  def destroy
    client = Client.where(:name => params[:id]).first
    client.destroy
    render :status => 200, :nothing => true
  end

end
