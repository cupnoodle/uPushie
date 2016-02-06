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
  
end