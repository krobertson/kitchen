class Api::DataBagsController < Api::ApiController

  def index
    DataBag.all.inject({}) { |s,c| s[c.name] = "#{base_url}/api/data/#{c.name}"; s }
  end

  def create
    data = DataBag.new(:name => params[:name])
    if data.save
      render :json => { 'uri' => api_data_bagss_url(data.name) }.to_json
    else
      render :status => 409, :text => "Data bag with name #{data.name} is already taken"
    end
  end

  def update
    data = DataBag.find(:first, :conditions => { :name => params[:id] })

    if data.save
      render :status => 200
    else
      render :status => 409
    end
  end

  def show
    data = DataBag.find(:first, :conditions => { :name => params[:id] })
    api_data = Chef::ApiData.json_create(data.attributes)
    render :json => api_data.to_json
  end

  def destroy
    data = DataBag.find(:first, :conditions => { :name => params[:id] })
    data.destroy
    render :status => 200
  end

end
