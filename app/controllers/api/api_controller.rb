require "mixlib/authentication/signatureverification"

class Api::ApiController < ApplicationController

  before_filter :authenticate_every


  class NotFound < Exception
  end

  rescue_from NotFound do |ex|
    if request.accept =~ /application\/json/
      render :json => { "error" => ex.message }, :status => 404
    else
      render :nothing => true, :status => 404
    end
  end


  protected

  def parsed_object
    return @parsed_object if @parsed_object

    @parsed_object = JSON.parse(request.body.read).to_hash
  end

  def ensure_admin
    head 401 unless @auth_user.admin?
  end

  def authenticate_every
    begin
      # Raises an error if required auth headers are missing
      authenticator = Mixlib::Authentication::SignatureVerification.new(request)

      username = authenticator.user_id
      puts "Authenticating client #{username}"

      user = Client.find(:first, :conditions => { :name => username })
      user_key = OpenSSL::PKey::RSA.new(user.public_key)

      # Store this for later..
      @auth_user = user
      authenticator.authenticate_request(user_key)
    rescue Mixlib::Authentication::MissingAuthenticationHeader => e
      puts "Authentication failed: #{e.class.name}: #{e.message}\n#{e.backtrace.join("\n")}"
      raise "#{e.class.name}: #{e.message}"
    rescue StandardError => se
      puts "Authentication failed: #{se}, #{se.backtrace.join("\n")}"
      raise "Failed to authenticate. Ensure that your client key is valid."
    end

    unless authenticator.valid_request?
      if authenticator.valid_timestamp?
        raise "Failed to authenticate. Ensure that your client key is valid."
      else
        raise "Failed to authenticate. Please synchronize the clock on your client"
      end
    end
    true
  end

end
