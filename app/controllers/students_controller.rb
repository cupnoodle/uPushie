class StudentsController < ApiController

  def index
    #self.response_body = "Helloooo " + params[:name] + " !"
    @result = {message: "hello " }
    #respond_with(@result)
    render :json => @result
  end
end
