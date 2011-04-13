class Api::EnvironmentsController < Api::ApiController

  before_filter :authenticate_request
  before_filter :ensure_admin, :only => [ :create, :update, :destroy ]

  def index
    render :json => Environment.all.inject({}) { |s,e| s[e.name] = api_environment_url(e.name); s }
  end

  def create
    environment = Environment.new(:name => parsed_object['name'], :properties => parsed_object)
    if environment.save
      render :json => { 'uri' => api_environment_url(environment.name) }, :status => 201
    else
      render :status => 409, :text => "Environment with name #{environment.name} is already taken"
    end
  end

  def update
    raise MethodNotAllowed if params[:id] == "_default"
    environment = Environment.where(:name => params[:id]).first

    if environment.update_attributes(:properties => parsed_object)
      render :status => 200, :nothing => true
    else
      render :status => 409, :nothing => true
    end
  end

  def show
    environment = Environment.where(:name => params[:id]).first
    render :json => Chef::Environment.json_create(environment.properties.merge('name' => environment.name))
  end

  def destroy
    raise MethodNotAllowed if params[:id] == "_default"
    environment = Environment.where(:name => params[:id]).first
    environment.destroy
    render :status => 200, :nothing => true
  end

  def cookbook_versions
    environment = Environment.where(:name => params[:id]).first

    versions = Repository.cookbooks(environment.branch).inject({}) do |res, name|
      name = name.split('::',2).first
      cookbook = Cookbook.new(environment.branch, name)
      manifest = cookbook.manifest

      manifest.generate_manifest_with_urls do |o|
        path = Chef::CookbookVersion.cookbook_file_for_checksum(o[:checksum])
        path.gsub!(/^\/#{environment.branch}\/#{name}\//, '')
        file_api_cookbook_url(:path => path, :version => environment.branch, :id => name)
      end

      res[name] = manifest.to_hash
      res[name]['json_class'] = manifest.class.to_s
      res
    end

    render :json => versions
  end

end
