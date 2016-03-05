module Api

  class VersionsController < ApiController
     
    #before_action :verify_api_key, :verify_api_version
    # no need to verify api version
    before_action :verify_api_key

    def android

      @result = {:version => (Figaro.env.ANDROID_VERSION).to_i }
      render json: @result
      return

    end
    # end android

    def ios

      @result = {:version => (Figaro.env.IOS_VERSION).to_i }
      render json: @result
      return

    end
    #end ios

 	end
 	# end class
end
# end module