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
    
  end
  # end class
end
# end module