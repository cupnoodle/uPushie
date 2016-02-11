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
  

  def self.get_subject_hash(utar_id, utar_password, subject_url)
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

    # click the url of the subject link
    subpage = page.link_with(:href => subject_url).click
    #no subject page exist
    if(!subpage)
      return false
    end

    if(subpage.at('table .weeks'))
      subhash = Digest::MD5.hexdigest(subpage.at('table .weeks').text)
      #puts ' ' + subname + ' text is ' +  subpage.at('table .weeks').text
    else
      #some subject may dont have week row, eg: industrial training
      subhash = Digest::MD5.hexdigest(subpage.at('table .topics').text)
    end

    return subhash

  end
  # end get_subject_hash

  def self.get_subject_text(utar_id, utar_password, subject_url)
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

    subpage = page.link_with(:href => subject_url).click
    #no subject page exist
    if(!subpage)
      return false
    end

    weeks_text = Array.new

    numOfWeeks = 14
    #if now is between oct and dec, then is short sem
    if(Time.now.month >= 10)
      numOfWeeks = 7
    end
    #short sem/ long sem week
    (0..numOfWeeks).each do |nn|

      #if there exist section summary
      if(subpage.at("#section-" + nn.to_s + " .summary"))
        summarytext = subpage.at("#section-" + nn.to_s + " .summary").text.strip
      else
        summarytext =""
      end

      #if there exist section span label
      #process label text, each section can have many labeltext
      if(subpage.at("#section-" + nn.to_s + " span.label"))
        labeltexts = ""

        subpage.search("#section-" + nn.to_s + " span.label").each do |ltext|
          #replace multiple underscore with one new line
          labeltext = ltext.text.strip
          labeltext.gsub!(/_{3,}/, "\r")
          labeltexts = labeltexts + labeltext + " "
        end

        labeltexts.gsub!("\n", "")
        labeltexts.gsub!(/\r+/, "\r\r")
        labeltexts = "\r\r" + labeltexts
      else
        labeltexts = ""
      end

      summarytext.gsub!("\n", "")
      summarytext.gsub!(/\r+/, "\r\r")
      
      weeks_text << summarytext + labeltexts
    end

    return weeks_text
  end
  # end get_subject_text

  def self.get_subject_file(utar_id, utar_password, subject_url)
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

    subpage = page.link_with(:href => subject_url).click
    #no subject page exist
    if(!subpage)
      return false
    end

    weeks_file = Array.new
    week_file = Array.new
    file_hash = Hash.new

    numOfWeeks = 14
    #if now is between oct and dec, then is short sem
    if(Time.now.month >= 10)
      numOfWeeks = 7
    end

    #short sem/ long sem week
    (0..numOfWeeks).each do |nn|
      #puts "week " + nn.to_s
      #puts " "
      
     week_file.clear
      subpage.search("#section-" + nn.to_s + " .resource").each do |resourcestring|
        file_hash['title'] = resourcestring.at("span:not(.accesshide)").text
        file_hash['source'] = resourcestring.at("a")['href']
        file_hash['type'] = File.basename(resourcestring.at(".activityicon")['src'], ".*")
        #dup method makes a copy, else the pointer is still the same
        week_file << file_hash.dup
      end
      weeks_file << week_file.dup

    end

    return weeks_file

  end
  # end get_subject_file

end
# end module