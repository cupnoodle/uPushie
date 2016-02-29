class ApiController < ActionController::Metal
  abstract!

  # http://www.ostinelli.net/how-to-build-a-rails-api-server-optimizing-the-framework/
  
  # which allows you to set callbacks such as 'before_action' in your controllers.
  include AbstractController::Callbacks

  # which is needed to set the 'response_body'  (called in the 'render'  method).
  include ActionController::RackDelegation
  include ActionController::StrongParameters

  private

  def render(options={})
    self.status = options[:status] || 200
    self.content_type = 'application/json'
    body = Oj.dump(options[:json], mode: :compat)
    self.headers['Content-Length'] = body.bytesize.to_s
    self.response_body = body
  end

  ActiveSupport.run_load_hooks(:action_controller, self)

  private 

  def verify_api_key
    if !params.has_key?(:api_key)
      @result = {message: 'No api key supplied' }
      render :json => @result, :status => 403
      return false
    end

    if params[:api_key] != Figaro.env.UPUSHIE_API_KEY
      @result = {message: 'Invalid api key supplied' }
      render :json => @result, :status => 403
      return false
    end

  end


  def verify_api_version
    # 426 code means upgrade required in HTTP status code
    if !params.has_key?(:api_version)
      @result = {message: 'Please update the uPush App.' }
      render :json => @result, :status => 426
      return false
    end

    user_app_version = (params[:api_version]).to_i
    latest_app_version = (Figaro.env.API_VERSION).to_i

    if user_app_version < latest_app_version
      @result = {message: 'Please update the uPush App.' }
      render :json => @result, :status => 426
      return false
    end

  end

  
end