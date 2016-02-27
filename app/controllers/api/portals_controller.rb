require 'mechanizor'
require 'digest/md5'

module Api

  class PortalsController < ApiController
     
    before_action :verify_api_key, :verify_app_version

    def timetable
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

      timetable = Mechanizor.get_timetable(params[:utar_id], params[:utar_password])

      if timetable
        @result = {:message => 'Successfully retrieve timetable', :timetable => timetable}
        render json: @result
        return
      end

      @result = {:message => 'Unable to retrieve timetable'}
      render json: @result, :status => 500
      return

    end
    # end timetable
 	end
 	# end class
end
# end module
