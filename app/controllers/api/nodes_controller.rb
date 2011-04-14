class Api::NodesController < Api::ApiController

  before_filter :authenticate_request
  before_filter :ensure_admin_or_requestor, :only => [ :update, :destroy, :cookbooks ]

  def index
    render :json => Node.all.inject({}) { |s,n| s[n.name] = api_node_url(n.name); s }
  end

  def create
    node = Node.new(:name => parsed_object['name'], :properties => parsed_object)
    if node.save
      render :json => { 'uri' => api_node_url(node.name) }, :status => 201
    else
      render :status => 409, :text => "Node with name #{node.name} is already taken"
    end
  end

  def update
    node = Node.where(:name => params[:id]).first
    raise NotFound.new('Node not found') unless node

    puts "...#{parsed_object.inspect}.."

    if node.update_attributes(:properties => parsed_object)
      render :json => Chef::Node.json_create(node.properties.merge('name' => node.name))
    else
      render :status => 409, :nothing => true
    end
  end

  def show
    node = Node.where(:name => params[:id]).first
    raise NotFound.new('Node not found') unless node
    render :json => Chef::Node.json_create(node.properties.merge('name' => node.name))
  end

  def destroy
    node = Node.where(:name => params[:id]).first
    node.destroy
    render :status => 200, :nothing => true
  end

end
