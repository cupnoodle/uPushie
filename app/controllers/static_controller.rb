class StaticController < ActionController::Metal
  def index
    self.response_body = "Nothing to see here, carry on =w=/."
  end
end
