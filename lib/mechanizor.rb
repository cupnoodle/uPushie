module Mechanizor

  PORTAL_BASE_URL = "https://portal.utar.edu.my/"
  PORTAL_HEAD_LOGIN_URL = PORTAL_BASE_URL + "loginPage.jsp"
  PORTAL_LOGIN_URL = PORTAL_BASE_URL + "intranetLoginStd.jsp"
  PORTAL_INDEX_URL = PORTAL_BASE_URL + "stuIntranet/index.jsp"
  TIMETABLE_INDEX_URL = PORTAL_BASE_URL + "stuIntranet/timetable/index.jsp";
  TIMETABLE_URL = PORTAL_BASE_URL + "stuIntranet/timetable/viewTimetableV2.jsp"

  WBLE_BASE_URL = "https://wble-pk.utar.edu.my/"
  WBLE_LOGIN_URL = WBLE_BASE_URL + "login/index.php"

  #wble_base_url_array = ['pk', 'cfspk', 'pj', 'cfspj', 'kl', 'sl', 'ipsrsl', 'fmhs']
  WBLE_LOGIN_URL_HASH = {'pk' => 'https://wble-pk.utar.edu.my/login/index.php', 
                        'cfspk' => 'https://wble-pk.utar.edu.my/cfs-pk/login/index.php', 
                        'pj' => 'https://wble.utar.edu.my/pj/login/index.php', 
                        'cfspj' => 'https://wble.utar.edu.my/cfs-pj/login/index.php', 
                        'kl' => 'https://wble-kl.utar.edu.my/login/index.php', 
                        'sl' => 'https://wble-sl.utar.edu.my/login/index.php', 
                        'ipsrsl' => 'https://wble-sl.utar.edu.my/ipsr/login/index.php', 
                        'fmhs' => 'https://fmhs.utar.edu.my/wble/login/index.php'} 

  # Class function should add self. or {classname}. before method name
  def self.abc
    return "uhuhu"
  end

  def self.login_success?(utar_id, utar_password, campus = 'pk')
    page = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}.get WBLE_LOGIN_URL_HASH[campus]

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


  def self.get_subject_list(utar_id, utar_password, campus = 'pk')
    page = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}.get WBLE_LOGIN_URL_HASH[campus]

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
  

  def self.get_subject_hash(utar_id, utar_password, subject_url, subject_code, campus = 'pk')
    page = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}.get WBLE_LOGIN_URL_HASH[campus]

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

    # click the url of the subject link if link with the url exist
    # else search by subject code on link text
    if page.link_with(:href => subject_url)
      subpage = page.link_with(:href => subject_url).click
    else
      subpage = page.link_with(:text => /^#{subject_code}/).click
    end

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

  def self.get_subject_text(utar_id, utar_password, subject_url, subject_code, campus = 'pk')
    page = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}.get WBLE_LOGIN_URL_HASH[campus]

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

    # click the url of the subject link if link with the url exist
    # else search by subject code on link text
    if page.link_with(:href => subject_url)
      subpage = page.link_with(:href => subject_url).click
    else
      subpage = page.link_with(:text => /^#{subject_code}/).click
    end

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

  def self.get_subject_html(utar_id, utar_password, subject_url, subject_code, campus = 'pk')
    page = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}.get WBLE_LOGIN_URL_HASH[campus]

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

    # click the url of the subject link if link with the url exist
    # else search by subject code on link text
    if page.link_with(:href => subject_url)
      subpage = page.link_with(:href => subject_url).click
    else
      subpage = page.link_with(:text => /^#{subject_code}/).click
    end

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
        #summarytext = subpage.at("#section-" + nn.to_s + " .summary").text.strip
        summarytext = subpage.at("#section-" + nn.to_s + " .summary").inner_html.strip
      else
        summarytext =""
      end

      #if there exist section span label
      #process label text, each section can have many labeltext
      if(subpage.at("#section-" + nn.to_s + " span.label"))
        labeltexts = ""

        subpage.search("#section-" + nn.to_s + " span.label").each do |ltext|
          #replace multiple underscore with one new line
          #labeltext = ltext.text.strip
          labeltext = ltext.inner_html.strip
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
  # end get_subject_html

  def self.get_subject_file(utar_id, utar_password, subject_url, subject_code, campus = 'pk')
    agent = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}
    page = agent.get WBLE_LOGIN_URL_HASH[campus]

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

    # click the url of the subject link if link with the url exist
    # else search by subject code on link text
    if page.link_with(:href => subject_url)
      subpage = page.link_with(:href => subject_url).click
    else
      subpage = page.link_with(:text => /^#{subject_code}/).click
    end

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

        #if the file hash type is zip file then click inside it and get the link
        if(file_hash['type'] == "zip")
          filepage = agent.get(file_hash['source'] + "&inpopup=true")

          # if the file page is not the direct zip link file, i.e : the file page has a link to the direct zip file
          # check if the filepage is a page object that has the method "at"
          if(filepage.respond_to?('at'))
            tmp_download_link = filepage.at(".resourcepdf a")['href']
            file_hash['source'] = tmp_download_link
          end
          
        end

        week_file << file_hash.dup
      end
      weeks_file << week_file.dup

    end

    return weeks_file

  end
  # end get_subject_file

  def self.get_subject_data(utar_id, utar_password, subject_url, subject_code, campus = 'pk')
    agent = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}
    page = agent.get WBLE_LOGIN_URL_HASH[campus]

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

    # click the url of the subject link if link with the url exist
    # else search by subject code on link text
    if page.link_with(:href => subject_url)
      subpage = page.link_with(:href => subject_url).click
    else
      subpage = page.link_with(:text => /^#{subject_code}/).click
    end

    #no subject page exist
    if(!subpage)
      return false
    end

    weeks_file = Array.new
    week_file = Array.new
    file_hash = Hash.new

    weeks_text = Array.new

    numOfWeeks = 14
    #if now is between oct and dec, then is short sem
    if(Time.now.month >= 10)
      numOfWeeks = 7
    end

    #short sem/ long sem week
    (0..numOfWeeks).each do |nn|

      ## get text part

      #if there exist section summary
      if(subpage.at("#section-" + nn.to_s + " .summary"))
        #summarytext = subpage.at("#section-" + nn.to_s + " .summary").text.strip
        summarytext = subpage.at("#section-" + nn.to_s + " .summary").inner_html.strip
      else
        summarytext =""
      end

      #if there exist section span label
      #process label text, each section can have many labeltext
      if(subpage.at("#section-" + nn.to_s + " span.label"))
        labeltexts = ""

        subpage.search("#section-" + nn.to_s + " span.label").each do |ltext|
          #replace multiple underscore with one new line
          #labeltext = ltext.text.strip
          labeltext = ltext.inner_html.strip
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

      ## get file part
      week_file.clear
      subpage.search("#section-" + nn.to_s + " .resource").each do |resourcestring|
        file_hash['title'] = resourcestring.at("span:not(.accesshide)").text
        file_hash['source'] = resourcestring.at("a")['href']
        file_hash['type'] = File.basename(resourcestring.at(".activityicon")['src'], ".*")
        #dup method makes a copy, else the pointer is still the same

        #if the file hash type is zip file then click inside it and get the link
        if(file_hash['type'] == "zip")
          filepage = agent.get(file_hash['source'] + "&inpopup=true")

          # if the file page is not the direct zip link file, i.e : the file page has a link to the direct zip file
          # check if the filepage is a page object that has the method "at"
          if(filepage.respond_to?('at'))
            tmp_download_link = filepage.at(".resourcepdf a")['href']
            file_hash['source'] = tmp_download_link
          end
        end

        week_file << file_hash.dup
      end
      weeks_file << week_file.dup

    end
    # end iteration of weeks

    return {:html => weeks_text, :file => weeks_file}

  end
  # end get_subject_data

  def self.get_timetable(utar_id, utar_password)

    head_agent = Mechanize.new
    header_content = head_agent.head(PORTAL_HEAD_LOGIN_URL)

    #head_agent.cookie_jar.save_as 'portal_cookies', :session => true, :format => :yaml

    portal_page = head_agent.post(PORTAL_LOGIN_URL, {
      "UserName" => utar_id,
      "Password" => utar_password,
      "kaptchafield" => "xxx",
      "submit" => "Sign In"
    })

    head_agent.head(PORTAL_INDEX_URL)

    #if login failed , i.e detected the existence of login form or invalid status code
    if portal_page.code!='200' || portal_page.at('#loginwrap')
      return false
    end

    redirect_script_body = portal_page.body
    # 15 is the length of 'location.href=' 
    redirect_script_href_start_index = redirect_script_body.index("location.href='") + 15
    redirect_script_href_end_index = redirect_script_body.index("'</sc")
    redirect_script_href = redirect_script_body[redirect_script_href_start_index..(redirect_script_href_end_index-1)]

    head_agent.head(redirect_script_href)
    head_agent.head(PORTAL_INDEX_URL)
    
    timetable_index_page = head_agent.get(TIMETABLE_INDEX_URL)
    view_timetable_form = timetable_index_page.forms.first
    view_timetable_button = view_timetable_form.buttons_with(:id => "button").last
    view_timetable_button_params_string = view_timetable_button.node["onclick"]

    # 14 is the length of 'onEnterClick('
    # 1 is the length of '('
    tmp_start_index = view_timetable_button_params_string.index("onEnterClick(") + 14
    tmp_end_index = view_timetable_button_params_string.index(")") - 1
    # equivalent to substring with start index to end index
    tmp_string = view_timetable_button_params_string[tmp_start_index..tmp_end_index]
    # greedy substitute string
    tmp_string.gsub!("'", "")
    tmp_array = tmp_string.split(",")

    timetable_page = head_agent.post(TIMETABLE_URL, {
      "reqSid" => tmp_array[0],
      "reqSession" => tmp_array[1],
      "reqLevel" => tmp_array[2],
      "reqFpartcd" => tmp_array[3],
      "reqSchool" => tmp_array[4],
      "reqFbrncd" => tmp_array[5],
      "reqStartDate" => tmp_array[6],
      "reqEndDate" => tmp_array[7],
      "reqTotalWeek" => tmp_array[8],
      "reqInterval" => tmp_array[9]
    })

    return_array = Array.new

    # store top and bottom table to tables
    tables = timetable_page.search(".tbltimetable")
    top_table = tables.first.to_s
    bottom_table = tables.last.to_s

    # create hash to store classrooms of a subject which will be used when parsing bottom table
    subject_venue = Hash.new

    # parsing html to data
    while top_table.match('"unit"') do 
      top_table = top_table[top_table.index('class="unit"') + 13, top_table.size]
      classroom = top_table[0, top_table.index('<br>')]
      top_table = top_table[top_table.index('id="unit"') + 10, top_table.size]
      subject_code = top_table[0, top_table.index('</span>')]
      
      if subject_venue[subject_code].nil?
        subject_venue[subject_code] = Array.new
      end
      
      subject_venue[subject_code] << classroom
    end

    bottom_table = bottom_table[bottom_table.index('<tr>') + 4, bottom_table.size]
    bottom_table = bottom_table[bottom_table.index('<tr>') + 4, bottom_table.size]

    while bottom_table.match("<tr>") do
      bottom_table = bottom_table[bottom_table.index('">') + 2, bottom_table.size]
      
      if !bottom_table.match('</td>')
        break;
      end
      
      number = bottom_table[0, bottom_table.index('</td>')]
      
      # if number is an integer, means same subject, different time (i.e: one subject with multiple lecture classes)
      if number =~ /\A\d+\z/ ? true : false
        bottom_table = bottom_table[bottom_table.index('">') + 2, bottom_table.size]
        bottom_table = bottom_table[bottom_table.index('">') + 2, bottom_table.size]
        subject_code = bottom_table[0, bottom_table.index('</a>')]
        bottom_table = bottom_table[bottom_table.index('">') + 2, bottom_table.size]
        subject_name = bottom_table[0, bottom_table.index('</td>')]
        bottom_table = bottom_table[bottom_table.index('">') + 2, bottom_table.size]
        class_type = bottom_table[0, bottom_table.index('</td>')]
        bottom_table = bottom_table[bottom_table.index('">') + 2, bottom_table.size]
        class_group = bottom_table[0, bottom_table.index('</td>')]
        bottom_table = bottom_table[bottom_table.index('</td>') + 5, bottom_table.size]
        bottom_table = bottom_table[bottom_table.index('</td>') + 5, bottom_table.size]
        bottom_table = bottom_table[bottom_table.index('">') + 2, bottom_table.size]
        class_day = bottom_table[0, bottom_table.index('</td>')]
        bottom_table = bottom_table[bottom_table.index('">') + 2, bottom_table.size]
        class_time = bottom_table[0, bottom_table.index('</td>')]
        bottom_table = bottom_table[bottom_table.index('">') + 2, bottom_table.size]
        class_duration = bottom_table[0, bottom_table.index('</td>')]
        bottom_table = bottom_table[bottom_table.index('tr') + 2, bottom_table.size]
        # look for the correct classroom
        class_venue = subject_venue["%s(%s)(%s)" % [subject_code, class_type, class_group]].first
        return_array << { 
          "code" => subject_code,
          "name" => subject_name,
          "type" => class_type,
          "group" => class_group,
          "venue" => class_venue,
          "day" => class_day,
          "time" => class_time,
          "duration" => class_duration
        }
      else
        class_day = number
        bottom_table = bottom_table[bottom_table.index('">') + 2, bottom_table.size]
        class_time = bottom_table[0, bottom_table.index('</td>')]
        bottom_table = bottom_table[bottom_table.index('">') + 2, bottom_table.size]
        class_duration = bottom_table[0, bottom_table.index('</td>')]
        bottom_table = bottom_table[bottom_table.index('</tr>') + 5, bottom_table.size]
        # look for the correct classroom
        class_venue = subject_venue["%s(%s)(%s)" % [subject_code, class_type, class_group]].last
        return_array << { 
          "code" => subject_code,
          "name" => subject_name,
          "type" => class_type,
          "group" => class_group,
          "venue" => class_venue,
          "day" => class_day,
          "time" => class_time,
          "duration" => class_duration
        }
      end
      
    end

    return return_array

  end

  # end get_timetable

  ### PRAGMA - MARK campus
  def self.is_campus_valid?(inputcampus)
    if ['pk', 'cfspk', 'pj', 'cfspj', 'kl', 'sl', 'ipsrsl', 'fmhs'].include?(inputcampus.downcase)
      return true
    end

    return false
  end

  # end is_campus_valid?
end
# end module