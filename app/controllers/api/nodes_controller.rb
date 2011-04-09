class Api::NodesController < Api::ApiController

  def index
    render :json => Node.collection.find.inject({}) { |s,c| s[c['name']] = api_node_url(c['name']); s }
  end

  def create
    if Node.collection.insert(parsed_object)
      render :json => { 'uri' => api_node_url(parsed_object['name']) }, :status => 201
    else
      render :status => 409, :text => "Node with name #{parsed_object['name']} is already taken"
    end
  end

  def update
    node = Node.collection.find_one(:name => params[:id])
    raise NotFound.new('Node not found') unless node

    if Node.collection.update({:name => params[:id]}, parsed_object, :upsert => true)
      render :json => Chef::Node.json_create(node)
    else
      render :status => 409, :nothing => true
    end
  end

  def show
    node = Node.collection.find_one(:name => params[:id])
    raise NotFound.new('Node not found') unless node
    render :json => Chef::Node.json_create(node)
  end

  def destroy
    node = Node.find(:first, :conditions => { :name => params[:id] })
    node.destroy
    render :status => 200, :nothing => true
  end

end
