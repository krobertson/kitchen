class Api::CookbooksController < Api::ApiController

  def index
    cookbooks = {}

    Repository.branches.each do |branch|
      Repository.cookbooks(branch).each do |cookbook|
        cookbooks[cookbook] ||= { :url => api_cookbook_url(cookbook), :versions => [] }
        cookbooks[cookbook][:versions] << { :url => version_api_cookbook_url(cookbook, branch), :version => branch }
      end
    end

    render :json => cookbooks
  end

  def show
    cookbook = { :url => api_cookbook_url(params[:id]), :versions => [] }

    Repository.branches.each do |branch|
      next unless Repository.cookbooks(branch).include?(params[:id])
      cookbook[:versions] << { :url => version_api_cookbook_url(params[:id], branch), :version => branch }
    end

    render :json => { params[:id] => cookbook }
  end

  def version
    cookbook = Cookbook.new(params[:version], params[:id])
    manifest = cookbook.manifest

    manifest.generate_manifest_with_urls do |o|
      path = Chef::CookbookVersion.cookbook_file_for_checksum(o[:checksum])
      path.gsub!(/^\/#{params[:version]}\/#{params[:id]}\//, '')
      file_api_cookbook_url(:path => path)
    end


    puts
    puts "HEY"
    puts manifest.to_json
    puts

    render :json => manifest
  end

  def file
    blob = Repository.cookbook_file(params[:version], params[:id], params[:path])
    render :nothing => true, :status => 404 and return unless blob.is_a?(Grit::Blob)
    send_data blob.data, :filename => blob.name
  end

end
