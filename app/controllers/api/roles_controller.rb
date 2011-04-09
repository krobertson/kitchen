class Api::RolesController < Api::ApiController

  def index
    render :json => Repository.roles('master').inject({}) { |s,r| s[r] = api_role_url(r); s }
  end

  def show
    role = Repository.role('master', params[:id])
    role_json = role.to_hash
    role_json['run_list'] = role.run_list.to_a.map(&:to_s)
    render :json => role_json
  end

end
