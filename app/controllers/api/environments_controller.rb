class Api::EnvironmentsController < Api::ApiController

  def index
    render :json => Environment.collection.find.inject({}) { |s,c| s[c['name']] = api_environment_url(c['name']); s }
  end

  def create
    environment = Environment.new(parsed_object)
    if environment.save
      render :json => { 'uri' => api_environment_url(environment.name) }, :status => 201
    else
      render :status => 409, :text => "Environment with name #{environment.name} is already taken"
    end
  end

  def update
    environment = Environment.find(:first, :conditions => { :name => params[:id] })

    if environment.save
      render :status => 200, :nothing => true
    else
      render :status => 409, :nothing => true
    end
  end

  def show
    environment = Environment.find(:first, :conditions => { :name => params[:id] })
    render :json => environment
  end

  def destroy
    environment = Environment.find(:first, :conditions => { :name => params[:id] })
    environment.destroy
    render :status => 200, :nothing => true
  end

  def cookbook_versions
    environment = Environment.find(:first, :conditions => { :name => params[:id] })

#    run_list = Chef::RunList.new
#    params[:run_list].each do |run_list_item_string|
#      run_list << run_list_item_string
#    end

#    expanded_run_list = RunListExpansionFromGit.new(environment.name, run_list.run_list_items, environment.branch)
#    expanded_run_list.expand

#    versions = expanded_run_list.recipes.inject({}) do |res, name|
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
