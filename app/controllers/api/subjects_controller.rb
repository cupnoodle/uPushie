require 'mechanizor'
require 'digest/md5'

module Api

  class SubjectsController < ApiController
     
    before_action :verify_api_key, :verify_api_version

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

      if(!Mechanizor.is_campus_valid?(student.campus))
        @result = {:message => 'Student campus error'}
        render json: @result, :status => 403
        return
      end

      @subjects = Mechanizor.get_subject_list(params[:utar_id], params[:utar_password], student.campus)

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

        # use integer value of enum on find_by, eg: student[:campus] instead of student.campus
        tmpsub = Subject.find_by(:code => subject[:code], :campus => student[:campus])

        #if subject not found in database, then create and store the subject in database
        if(!tmpsub)
          tmpsub = Subject.new(:code => subject[:code], :name => subject[:name], :url => subject[:url], :latest_hash => subject[:hash], :campus => student.campus)
          
          tmpsub.save

        #subject already exist
        else
          #if utar changed the subject url (i have no idea why they would do this)
          if(tmpsub.url != subject[:url])
            tmpsub.url = subject[:url]
            tmpsub.save
          end

        end

        # use integer value of enum on find_by, eg: student[:campus] instead of student.campus

        #if student doesn't have this subject linked then link it
        subject_student = SubjectStudent.find_by(:student_utar_id => student.utar_id, :subject_code => subject[:code], :campus => student[:campus])
        if !subject_student
          tmpsubstudent = SubjectStudent.new(:student_utar_id => student.utar_id, :subject_code => subject[:code], :campus => student.campus)
          tmpsubstudent.subject = tmpsub
          tmpsubstudent.student = student

          tmpsubstudent.save
        end

      end
      #end do

      @result = {message: 'Get subject for student ' + params[:utar_id] + ' successful', subjects: @subjects}
      render :json => @result
      return

    end
   
   ## axel continue here
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

      if(!Mechanizor.is_campus_valid?(student.campus))
        @result = {:message => 'Student campus error'}
        render json: @result, :status => 403
        return
      end

      # find the subject
      # use integer value of enum on find_by and new , eg: student[:campus] instead of student.campus
      subject = Subject.find_by(:code => params[:code], :campus => student[:campus])
      if(!subject)
        @result = {:message => 'Subject not found in Database'}
        render json: @result, :status => 404
        return
      end

      @result = {:message => subject.code + " " + subject.name + " has not updated", :updated => 'false', :hash => subject.latest_hash}

      @subject_hash = Mechanizor.get_subject_hash(params[:utar_id], params[:utar_password], subject.url, subject.code, student.campus)

      if !@subject_hash
        @result = {:message => 'Error accessing WBLE or student does not have this subject'}
        render json: @result, :status => 403
        return
      end

      #if the latest hash of subject in database is not equal to the newly grabbed subject_hash, i.e : content of wble updated
      if subject.latest_hash != @subject_hash
        subject.latest_hash = @subject_hash
        subject.save
        @result = {:message => subject.code + " " + subject.name + " has been updated", :updated => 'true', :hash => subject.latest_hash}
      
        #search device token of users who took this subject and send notification to them
        #device_tokens = subject.users.pluck(:device_token)
        #alert_message = subject.code + ' ' + subject.name + ' has been updated'

        #send_notification(device_tokens, alert_message, 0 , {:time => Time.now.strftime("%I:%M%p  %d %b %Y")})

        # ignore TITAS notification
        if subject.code != "MPU3123"
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
          android_n.data = { message: subject.code + " " + subject.name + " has been updated", subject: subject.code + " " + subject.name }
          # android_n.priority = 'high'        # Optional, can be either 'normal' or 'high'
          # android_n.content_available = true # Optional
          android_n.save!
        end

      end
      
      render json: @result
      return
    end
    # end checkhash

    # get text
    def text
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

      # check if campus is valid
      if(!Mechanizor.is_campus_valid?(student.campus))
        @result = {:message => 'Student campus error'}
        render json: @result, :status => 403
        return
      end

      # find the subject
      # use integer value of enum on find_by and new , eg: student[:campus] instead of student.campus
      subject = Subject.find_by(:code => params[:code], :campus => student[:campus])
      if(!subject)
        @result = {:message => 'Subject not found in Database'}
        render json: @result, :status => 404
        return
      end

      @subject_texts = Mechanizor.get_subject_text(params[:utar_id], params[:utar_password], subject.url, subject.code, student.campus)

      if !@subject_texts
        @result = {:message => 'Error accessing WBLE or student does not have this subject'}
        render json: @result, :status => 403
        return
      end

      @result = {:message => 'Successfully retrieved text for subject', :texts => @subject_texts}
      render json: @result
    end
    # end text

    # get html tags with text
    def html
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

      # check if campus is valid
      if(!Mechanizor.is_campus_valid?(student.campus))
        @result = {:message => 'Student campus error'}
        render json: @result, :status => 403
        return
      end

      # find the subject
      # use integer value of enum on find_by and new , eg: student[:campus] instead of student.campus
      subject = Subject.find_by(:code => params[:code], :campus => student[:campus])
      if(!subject)
        @result = {:message => 'Subject not found in Database'}
        render json: @result, :status => 404
        return
      end

      @subject_texts = Mechanizor.get_subject_html(params[:utar_id], params[:utar_password], subject.url, subject.code, student.campus)

      if !@subject_texts
        @result = {:message => 'Error accessing WBLE or student does not have this subject'}
        render json: @result, :status => 403
        return
      end

      @result = {:message => 'Successfully retrieved html for subject', :texts => @subject_texts}
      render json: @result
    end
    # end html

    # get file link
    def file
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

      # check if campus is valid
      if(!Mechanizor.is_campus_valid?(student.campus))
        @result = {:message => 'Student campus error'}
        render json: @result, :status => 403
        return
      end

      # find the subject
      # use integer value of enum on find_by and new , eg: student[:campus] instead of student.campus
      subject = Subject.find_by(:code => params[:code], :campus => student[:campus])
      if(!subject)
        @result = {:message => 'Subject not found in Database'}
        render json: @result, :status => 404
        return
      end

      @subject_files = Mechanizor.get_subject_file(params[:utar_id], params[:utar_password], subject.url, subject.code, student.campus)

      if !@subject_files
        @result = {:message => 'Error accessing WBLE or student does not have this subject'}
        render json: @result, :status => 403
        return
      end

      @result = {:message => 'Successfully retrieved files for subject', :files => @subject_files}
      render json: @result
    end
    # end file
  end
  # end class
end
# end module
