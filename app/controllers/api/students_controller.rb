require 'mechanizor'

module Api

  class StudentsController < ApiController
     
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
      if params[:utar_id].blank? || params[:utar_password].blank? || !%w(ios android).include?(params[:os].downcase)
        @result = {:message => 'Blank input or invalid operating system specified'}
        render json: @result, :status => 400
        return
      end

      # see if device_token/registration_id is provided for ios/android
      if params[:os].downcase == 'ios' && !params.has_key?(:device_token)
        @result = {:message => 'No device token supplied for ios'}
        render json: @result, :status => 400
        return
      end

      if params[:os].downcase == 'android' && !params.has_key?(:registration_id)
        @result = {:message => 'No registration_id supplied for android'}
        render json: @result, :status => 400
        return
      end
        

      ### Login to WBLE

      if Mechanizor.login_success?(params[:utar_id], params[:utar_password])
        @student = Student.find_by(:utar_id => params[:utar_id])

        #found the user then update the os/device token/registration id
        if @student
          @student.os = params[:os].downcase
          @student.last_login = Time.now

        else
          #student not found, create a new one
          @student = Student.new(:utar_id => params[:utar_id], :device_token => params[:device_token], :last_login => Time.now)
        end

        # update os/device token/registration id accordingly
        if(params[:os].downcase == 'ios')
          @student.device_token = params[:device_token]
          @student.registration_id = nil
        end

        if(params[:os].downcase == 'android')
          @student.registration_id = params[:registration_id]
          @student.device_token = nil
        end

        @student.save
        @result = {message: 'Login successful for student ' + params[:utar_id] }
        render :json => @result
        return
      end
      
      # login failed
      @result = {message: 'Login failed for student ' + params[:utar_id] }
      render :json => @result, :status => 403

    end
    
  end

end