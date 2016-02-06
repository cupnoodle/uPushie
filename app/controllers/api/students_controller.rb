module Api

  class StudentsController < ApiController
    
    require 'Mechanizor'

    def index
      #self.response_body = "Helloooo " + params[:name] + " !"
      @result = {message: "hello inside api" }
      #respond_with(@result)
      render :json => @result
    end
  
    def authenticate
      
      ### Parameters validation

      # insufficient parameters
      if !params.has_key?(:utar_id) || !params.has_key?(:utar_password) || !params.has_key?(:os)
        @result = {:message => 'no utar credential or operating system specified'}
        render json: @result, :status => 400
        return
      end

      # blank parameter lel
      if params[:utar_id].blank? || params[:utar_password].blank? || !%w(ios iOS Android android).include?(params[:os])
        @result = {:message => 'Blank input or invalid operating system specified'}
        render json: @result
        return
      end

      @result = {message: Mechanizor.abc }
      #respond_with(@result)
      render :json => @result

    end
    
  end

end