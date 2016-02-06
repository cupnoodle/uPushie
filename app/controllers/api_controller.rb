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
end