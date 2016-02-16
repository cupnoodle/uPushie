require 'mechanizor'
require 'digest/md5'

module Api

  class StudentsController < ApiController
     
    before_action :verify_api_key

    def index
      #self.response_body = "Helloooo " + params[:name] + " !"
      @result = {message: "hello inside api" }
      #respond_with(@result)
      render :json => @result
    end
  
    def authenticate
      
      ### Parameters validation

      # insufficient parameters
      if !params.has_key?(:utar_id) || !params.has_key?(:utar_password)
        @result = {:message => 'No utar credential specified'}
        render json: @result, :status => 400
        return
      end

      # blank parameter lel
      if params[:utar_id].blank? || params[:utar_password].blank?
        @result = {:message => 'Blank input'}
        render json: @result, :status => 400
        return
      end

      # see if device_token/registration_id is provided for ios/android
      # if params[:os].downcase == 'ios' && !params.has_key?(:device_token)
      #   @result = {:message => 'No device token supplied for ios'}
      #   render json: @result, :status => 400
      #   return
      # end
      # 
      # if params[:os].downcase == 'android' && !params.has_key?(:registration_id)
      #   @result = {:message => 'No registration_id supplied for android'}
      #   render json: @result, :status => 400
      #   return
      # end
        

      ### Login to WBLE

      if Mechanizor.login_success?(params[:utar_id], params[:utar_password])
        @student = Student.find_by(:utar_id => params[:utar_id])

        #found the user then update the os/device token/registration id
        if @student
          md5_hashed_password = Digest::MD5.hexdigest(params[:utar_password])

          @student.utar_password_hash = md5_hashed_password
          @student.last_login = Time.now

        else
          #student not found, create a new one
          md5_hashed_password = Digest::MD5.hexdigest(params[:utar_password])
          @student = Student.new(:utar_id => params[:utar_id], :utar_password_hash => md5_hashed_password, :last_login => Time.now)
        end

        # update os/device token/registration id accordingly
        # if(params[:os].downcase == 'ios')
        #   @student.device_token = params[:device_token]
        #   @student.registration_id = nil
        # end
        # 
        # if(params[:os].downcase == 'android')
        #   @student.registration_id = params[:registration_id]
        #   @student.device_token = nil
        # end

        @student.save

        @result = {message: 'Login successful for student ' + params[:utar_id] }
        render :json => @result
        return
      end
      
      # login failed
      @result = {message: 'Login failed for student ' + params[:utar_id] }
      render :json => @result, :status => 403

    end
    
    # update device token/registration id
    def update

      ### Parameters validation

      # insufficient parameters
      if !params.has_key?(:utar_id) || !params.has_key?(:utar_password) || !params.has_key?(:os)
        @result = {:message => 'No utar credential or operating system specified'}
        render json: @result, :status => 400
        return
      end

      # blank parameter lel
      if params[:utar_id].blank? || params[:utar_password].blank? || params[:os].blank?
        @result = {:message => 'Blank input'}
        render json: @result, :status => 400
        return
      end

      # check valid os
      if !%w(ios android).include?(params[:os].downcase)
        @result = {:message => 'Invalid operating system specified'}
        render json: @result, :status => 400
        return
      end

      # see if device_token/registration_id is provided for ios/android
      if params[:os].downcase == 'ios' && !params.has_key?(:device_token)
        @result = {:message => 'No device_token supplied for ios'}
        render json: @result, :status => 400
        return
      end
      
      if params[:os].downcase == 'android' && !params.has_key?(:registration_id)
        @result = {:message => 'No registration_id supplied for android'}
        render json: @result, :status => 400
        return
      end

      @student = Student.find_by(:utar_id => params[:utar_id])

      # student found
      if @student

        md5_hashed_password = Digest::MD5.hexdigest(params[:utar_password])

        # password is same then update the os / device token / registration id
        if @student.utar_password_hash == md5_hashed_password

          @student.os = params[:os].downcase

          case params[:os].downcase
          when "android"
            @student.registration_id = params[:registration_id]
            @student.device_token = nil
          when "ios"
            @student.device_token = params[:device_token]
            @student.registration_id = nil
          else
            puts "not possible lel"
          end
            
          if @student.save
            @result = {message: 'Update successful for student ' + params[:utar_id] }
            render :json => @result
            return
          end

          @result = {message: 'Unable to update info for student ' + params[:utar_id] }
          render :json => @result, :status => 500
          return

        end

        # wrong password, i.e. unauthorized
        @result = {:message => 'Credential does not match, unable to update'}
        render json: @result, :status => 403
        return

      end

      @result = {:message => 'Student not found in Database'}
      render json: @result, :status => 404
      return

    end

    def logout

      # insufficient parameters
      if !params.has_key?(:utar_id) || !params.has_key?(:utar_password)
        @result = {:message => 'No utar credential specified'}
        render json: @result, :status => 400
        return
      end

      @student = Student.find_by(:utar_id => params[:utar_id])

      # student found
      if @student

        md5_hashed_password = Digest::MD5.hexdigest(params[:utar_password])

        # password is same then update the os / device token / registration id
        if @student.utar_password_hash == md5_hashed_password

          @student.os = nil
          @student.device_token = nil
          @student.registration_id = nil
            
          @student.save

          @result = {message: 'Student ' + params[:utar_id] + ' successfully logout' }
          render :json => @result
          return
        end

        # wrong password, i.e. unauthorized
        @result = {:message => 'Credential does not match, unable to update'}
        render json: @result, :status => 403
        return

      end

      @result = {:message => 'Student not found in Database'}
      render json: @result, :status => 404
      return

    end

  end
  # end class
end
# end module