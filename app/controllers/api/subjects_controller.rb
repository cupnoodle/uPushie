require 'mechanizor'
require 'digest/md5'

module Api

  class SubjectsController < ApiController
     
    before_action :verify_api_key

    def list
      @result = {:message => ''}
      #will return this in json
      #subjects_array = Array.new

      # insufficient parameters
      if !params.has_key?(:utar_id) || !params.has_key?(:utar_password)
        @result = {:message => 'No utar credential specified'}
        render json: @result, :status => 400
        return
      end

      # find student from database
      student = Student.find_by(:utar_id => params[:utar_id])
      if(!student)
        @result = {:message => 'Student not found in Database'}
        render json: @result, :status => 404
        return
      end

      @subjects = Mechanizor.get_subject_list(params[:utar_id], params[:utar_password])

      #wble down or error accessing wble
      if !@subjects
        #revert login, set device_token as null
        
        @result = {:message => 'Error accessing WBLE or student have no active subject'}
        render json: @result, :status => 403
        return
      end

      @subjects.each do |subject|
      #save subject code into array, will be used for json return
      #subjects_hash[subject[:code]] = subject[:name]
      #subjects_array <<

        tmpsub = Subject.find_by(:code => subject[:code])

        #if subject not found in database, then create and store the subject in database
        if(!tmpsub)
          tmpsub = Subject.new(:code => subject[:code], :name => subject[:name], :url => subject[:url], :latest_hash => subject[:hash])
          
          tmpsub.save

        #subject already exist
        else
          #if utar changed the subject url (i have no idea why they would do this)
          if(tmpsub.url != subject[:url])
            tmpsub.url = subject[:url]
            tmpsub.save
          end

        end

        #if student doesn't have this subject linked then link it
        subject_student = SubjectStudent.find_by(:student_utar_id => student.utar_id, :subject_code => subject[:code])
        if !subject_student
          SubjectStudent.create(:student_utar_id => student.utar_id, :subject_code => subject[:code])
        end

      end
      #end do

      @result = {message: 'Get subject for student ' + params[:utar_id] + ' successful', subjects: @subjects}
      render :json => @result
      return

    end
   
    def checkhash
      
      #will return this in json
      #subjects_array = Array.new

      # insufficient parameters
      if !params.has_key?(:utar_id) || !params.has_key?(:utar_password)
        @result = {:message => 'No utar credential specified'}
        render json: @result, :status => 400
        return
      end

      # find student from database
      student = Student.find_by(:utar_id => params[:utar_id])
      if(!student)
        @result = {:message => 'Student not found in Database'}
        render json: @result, :status => 404
        return
      end

      # find the subject
      subject = Subject.find_by(:code => params[:code])
      if(!subject)
        @result = {:message => 'Subject not found in Database'}
        render json: @result, :status => 404
        return
      end

      @result = {:message => subject.code + " " + subject.name + " has not updated", :updated => 'false'}

      @subject_hash = Mechanizor.get_subject_hash(params[:utar_id], params[:utar_password], subject.url)

      if !@subject_hash
        @result = {:message => 'Error accessing WBLE or student does not have this subject'}
        render json: @result, :status => 403
        return
      end

      #if the latesh hash of subject in database is not equal to the newly grabbed subject_hash, i.e : content of wble updated
      if subject.latest_hash != @subject_hash
        subject.latest_hash = @subject_hash
        subject.save
        @result = {:message => subject.code + " " + subject.name + " has been updated", :updated => 'true'}
      
        #search device token of users who took this subject and send notification to them
        #device_tokens = subject.users.pluck(:device_token)
        #alert_message = subject.code + ' ' + subject.name + ' has been updated'

        #send_notification(device_tokens, alert_message, 0 , {:time => Time.now.strftime("%I:%M%p  %d %b %Y")})

        device_tokens = subject.students.pluck(:device_token)
        reg_ids = subject.students.pluck(:registration_id)

        # remove nil value in array using compact!
        reg_ids.compact!


        # send notification to ios
        # loop through each device token
        device_tokens.each do |dt|

          # skip if device token is nil
          next if !dt

          n = Rpush::Apns::Notification.new
          n.app = Rpush::Apns::App.find_by_name("ios_upush")
          n.device_token = dt # 64-character hex string
          n.alert = subject.code + " " + subject.name + " has been updated"
          n.data = { :time => Time.now.strftime("%I:%M%p  %d %b %Y") }
          n.save!

        end

        # send notification to android
        android_n = Rpush::Gcm::Notification.new
        android_n.app = Rpush::Gcm::App.find_by_name("android_upush")
        android_n.registration_ids = reg_ids
        android_n.data = { message: subject.code + " " + subject.name + " has been updated" }
        android_n.priority = 'high'        # Optional, can be either 'normal' or 'high'
        android_n.content_available = true # Optional
        android_n.save!

      end
      
      render json: @result
      return
    end
    # end checkhash

  end
  # end class
end
# end module