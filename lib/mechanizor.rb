module Mechanizor

  WBLE_BASE_URL = "https://wble-pk.utar.edu.my/"
  WBLE_LOGIN_URL = WBLE_BASE_URL + "login/index.php"
  # Class function should add self. or {classname}. before method name

  def self.abc
    return "uhuhu"
  end

  def self.login_success?(utar_id, utar_password)
    page = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}.get WBLE_LOGIN_URL

    #if wble is down, lulz
    if page.code!='200'
      return false
    end

    #Login to WBLE
    form = page.forms.first
    form['username'] = utar_id.to_s
    form['password'] = utar_password.to_s
    form['testcookies'] = '1'

    page = form.submit

    #if login failed , i.e detected the existence of login form or invalid status code
    if page.code!='200' || page.at('.loginpanel')
      return false
    end

    #no subject ,i.e wrong campus
    if page.links_with(:text => /^[A-Z]{3,4}\d{4,5}/).count == 0
      return false
    end

    return true

  end
  # end login_success?


  def self.get_subject_list(utar_id, utar_password)
    page = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}.get WBLE_LOGIN_URL

    #if wble is down, lulz
    if page.code!='200'
      return false
    end

    #Login to WBLE
    form = page.forms.first
    form['username'] = utar_id.to_s
    form['password'] = utar_password.to_s
    form['testcookies'] = '1'

    page = form.submit

    #if login failed , i.e detected the existence of login form or invalid status code
    if page.code!='200' || page.at('.loginpanel')
      return false
    end

    subjects = Array.new

    #no subject matched
    if page.links_with(:text => /^[A-Z]{3,4}\d{4,5}/).count == 0
      return false
    end

    # loop through each hyperlink with text that resemble subject code
    page.links_with(:text => /^[A-Z]{3,4}\d{4,5}/).each do |link|
      subcode = link.text.match(/^[A-Z]{3,4}\d{4,5}/).to_s

      #skip if it is industrial exposure
      next if subcode == 'UCCD2596'

      #I hate regular expression
      subcodename = link.text.match(/([A-Z]{3,4}\d{4,5}\s+[a-zA-Z-\s]+)/).to_s
      #puts 'subcodename for ' + subcode + ' is ' + subcodename
      subname = subcodename.match(/[a-zA-Z-\s]{5,}$/).to_s.strip
      #puts 'subname is ' + subname
      subhref = link.href.to_s

      subpage = link.click

      if(subpage.at('table .weeks'))
        subhash = Digest::MD5.hexdigest(subpage.at('table .weeks').text)
        #puts ' ' + subname + ' text is ' +  subpage.at('table .weeks').text
      elsif(subpage.at('table .topics'))
        #some subject may dont have week row, eg: industrial training
        subhash = Digest::MD5.hexdigest(subpage.at('table .topics').text)
      else

      end

      tmpsub = {:code => subcode, :name => subname, :url => subhref, :hash => subhash}

      subjects << tmpsub
    end

    return subjects

  end
  # end get_subject_list
  
end
# end module