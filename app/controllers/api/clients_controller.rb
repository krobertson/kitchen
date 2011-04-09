class Api::ClientsController < Api::ApiController

  def index
    render :json => Client.all.inject({}) { |s,c| s[c.name] = api_client_url(c.name); s }
  end

  def create
    client = Client.create({ :name => params[:name], :admin => params[:admin] })
    client.create_keys

    if client.save
      headers['Location'] = api_client_url(client.name)
      render :json => { 'uri' => api_client_url(client.name), 'private_key' => client.private_key }, :status => 201
    else
      render :status => 409, :text => "Client with name #{client.name} is already taken"
    end
  end

  def update
    client = Client.find(:first, :conditions => { :name => params[:id] })
    client.admin = params[:admin]

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
    client = Client.find(:first, :conditions => { :name => params[:id] })
    api_client = Chef::ApiClient.json_create(client.attributes)
    render :json => api_client
  end

  def destroy
    client = Client.find(:first, :conditions => { :name => params[:id] })
    client.destroy
    render :status => 200, :nothing => true
  end

end
