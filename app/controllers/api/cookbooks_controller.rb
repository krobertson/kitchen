class Api::CookbooksController < Api::ApiController

  def index
    cookbooks = {}

    ChefGit.branches.each do |branch|
      ChefGit::Cookbooks.get_cookbooks(branch).each do |cookbook|
        cookbooks[cookbook] ||= { :url => api_cookbook_url(cookbook), :versions => [] }
        cookbooks[cookbook][:versions] << { :url => version_api_cookbook_url(cookbook, branch), :version => branch }
      end
    end

    render :json => cookbooks
  end

  def show
    cookbook = { :url => api_cookbook_url(params[:id]), :versions => [] }

    ChefGit.branches.each do |branch|
      next unless ChefGit::Cookbooks.get_cookbooks(branch).include?(params[:id])
      cookbook[:versions] << { :url => version_api_cookbook_url(params[:id], branch), :version => branch }
    end

    render :json => { params[:id] => cookbook }
  end

  def version
    cookbook = ChefGit::Cookbook.new(params[:version], params[:id])

    manifest = cookbook.generate_manifest_with_urls do |path|
      file_api_cookbook_url(:path => path)
    end

    render :json => manifest
  end

  def file
    blob = ChefGit::Cookbooks.get_cookbook_file(params[:version], params[:id], params[:path])
    render :nothing => true, :status => 404 and return unless blob.is_a?(Grit::Blob)
    send_data blob.data, :filename => blob.name
  end

end
