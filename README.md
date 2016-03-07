# uPushie API

Last updated : 7 March 2016  , **api_version** updated to **2** , **android version** updated to **4**, **ios version** updated to **2**   

API Base URL : **https://upushie.vul.io/api/**

All API call must include the **api_key** parameter, the value for **api_key** is **upushie_correcthorsebatterystaple**

All API call (except logout and check mobile app version) must include the **api_version** parameter, the latest value for **api_version** is **2** , make sure the value you send to server is this value. The HTTP response code is **426** if the api version from the mobile app is smaller than the latest app version in server, the mobile app should show a popup that forces/suggest user to update the app if the version is older than current version.  

# Student objects
### Authenticate

Try to login to UTAR wble using the ID and password provided  

List of accepted campus parameter : **pk**, **cfspk**, **pj**, **cfspj**, **kl**, **sl**, **ipsrsl**, **fmhs**  

**POST** https://upushie.vul.io/api/student/authenticate

|Parameter|Optional?|Description|Sample value|
|---|---|---|---|
|utar_id|Mandatory|UTAR ID of the student| 1206225 |
|utar_password|Mandatory|UTAR password of the student| password123 |
|campus|Optional| Campus of the student, see the accepted list above, if campus is not provided, 'pk' will be used as default | pj |

**Response JSON on failure**  
HTTP response status code is either 400 (bad request/parameters) or 403 (wrong utar login)  
JSON object  *{'message' => 'Blank input '}*

**Response JSON on success**  
HTTP response status code is 200  
The 'new' attribute means if the user is first time login into the upush system. If true means the user is a new user, false means the user has logged in before.  The 'wble' is the login link for the wble, to use for manually login before downloading the file.

JSON object  *{'message' => 'Login successful for student 1206225', 'new' => false, 'wble' => 'https://wble-pk.utar.edu.my/cfs-pk/login/index.php'}*  
<br>
___

### Update

Updates student's OS and device token / registration id.

**PUT** https://upushie.vul.io/api/student

|Parameter|Optional?|Description|Sample value|
|---|---|---|---|
|utar_id|Mandatory|UTAR ID of the student| 1206225 |
|utar_password|Mandatory|UTAR password of the student| password123 |
|os|Mandatory|Operating system of the student (either **ios** or **android** )| android|
|device_token|Required if OS is iOS| Device token of the iOS device | [64 characters] |
|registration_id| Required if OS is Android | Registration ID of the Android device | [some string] |

**Response JSON on failure**  
HTTP response status code is either 400 (bad request/parameters) , 403 (wrong utar login)  , 404 (student doesn't exist in  uPushie database yet, please call the authenticate API first)  
JSON object  *{'message' => 'Student not found in database '}*

**Response JSON on success**  
HTTP response status code is 200  
JSON object  *{'message' => 'Update successful for student 1206225'}*  
<br>
___

### Logout

Logout student by setting OS, device token and registration id to _NULL_

**POST** https://upushie.vul.io/api/student/logout

|Parameter|Optional?|Description|Sample value|
|---|---|---|---|
|utar_id|Mandatory|UTAR ID of the student| 1206225 |
|utar_password|Mandatory|UTAR password of the student| password123 |

**Response JSON on failure**  
HTTP response status code is either 400 (bad request/parameters) , 403 (wrong utar login)  , 404 (student doesn't exist in  uPushie database yet, please call the authenticate API first)  
JSON object  *{'message' => 'Credential does not match, unable to update '}*

**Response JSON on success**  
HTTP response status code is 200  
JSON object  *{'message' => 'Student 1206225 successfully logout'}*  
<br>
___
  
# Subject objects
### List

Get a list of subjects taken by the specified student, return a list of subject on success.

**POST** https://upushie.vul.io/api/student/subjects  

|Parameter|Optional?|Description|Sample value|
|---|---|---|---|
|utar_id|Mandatory|UTAR ID of the student| 1206225 |
|utar_password|Mandatory|UTAR password of the student| password123 |

**Response JSON on failure**  
HTTP response status code is either 400 (bad request/parameters), 403 (wrong utar login)  or 404 (student not found in upushie DB)  
    
JSON object  *{'message' => 'No utar credential specified '}*

**Response JSON on success**  
HTTP response status code is 200  
JSON object  : [Click here](https://gist.github.com/cupnoodle/99b63cbc1df0516f58f1)
<br>
___

### Text

Get texts of  a subject taken by the specified student, return an array of text ordered by weeks (ascending) on success.

**POST** https://upushie.vul.io/api/subject/[subject code]/text  
  
eg : https://upushie.vul.io/api/subject/UCCD2203/text  

|Parameter|Optional?|Description|Sample value|
|---|---|---|---|
|utar_id|Mandatory|UTAR ID of the student| 1206225 |
|utar_password|Mandatory|UTAR password of the student| password123 |

**Response JSON on failure**  
HTTP response status code is either 400 (bad request/parameters), 403 (wrong utar login)  or 404 (student not found in upushie DB)  
    
JSON object  *{"message":"Error accessing WBLE or student does not have this subject"}*
  
**Response JSON on success**  
HTTP response status code is 200  
JSON object  : [Click here](https://gist.github.com/cupnoodle/db292006764dc9b882ec)  
<br>
___

### File

Get files of  a subject taken by the specified student, return an array of array of hashes ordered by weeks (ascending) on success.

**POST** https://upushie.vul.io/api/subject/[subject code]/file  
  
eg : https://upushie.vul.io/api/subject/UCCD2203/file  

|Parameter|Optional?|Description|Sample value|
|---|---|---|---|
|utar_id|Mandatory|UTAR ID of the student| 1206225 |
|utar_password|Mandatory|UTAR password of the student| password123 |

**Response JSON on failure**  
HTTP response status code is either 400 (bad request/parameters), 403 (wrong utar login)  or 404 (student not found in upushie DB)  
    
JSON object  *{"message":"Error accessing WBLE or student does not have this subject"}*
  
**Response JSON on success**  
HTTP response status code is 200  
JSON object  : [Click here](https://gist.github.com/cupnoodle/64519c32e9fb8f5ca84c)  
<br>
___

### Check hash

Compute md5 hash on the current subject page and compare it to the hash stored previously in database, if the hash is different then send notification to user.

**POST** https://upushie.vul.io/api/subject/[subject code]/check  
  
eg : https://upushie.vul.io/api/subject/UCCD2203/check

|Parameter|Optional?|Description|Sample value|
|---|---|---|---|
|utar_id|Mandatory|UTAR ID of the student| 1206225 |
|utar_password|Mandatory|UTAR password of the student| password123 |

**Response JSON on failure**  
HTTP response status code is either 400 (bad request/parameters), 403 (wrong utar login)  or 404 (student not found in upushie DB)  
    
JSON object  *{"message":"Subject not found in Database"}*
  
**Response JSON on success**  
HTTP response status code is 200  
JSON object  : *{"message" : "UCCD2203 Database Systems has been updated", "updated":"true"}*  
<br>
___
  
# Portal objects
### Timetable

Get timetable the specified student, return a list of schedules on success.

**POST** https://upushie.vul.io/api/portal/timetable  

|Parameter|Optional?|Description|Sample value|
|---|---|---|---|
|utar_id|Mandatory|UTAR ID of the student| 1206225 |
|utar_password|Mandatory|UTAR password of the student| password123 |

**Response JSON on failure**  
HTTP response status code is either 400 (bad request/parameters), 500 (utar portal down)  or 404 (student not found in upushie DB)   
JSON object  *{'message' => 'No utar credential specified '}*

**Response JSON on success**  
HTTP response status code is 200  
JSON object  : [Click here](https://gist.github.com/cupnoodle/2e7c84081ebaf4eff2f7)
<br>
___

# App Version
### Android

Get current Android app version 
 
**POST** https://upushie.vul.io/api/version/android

(No parameter is needed except for api_key)  
  
|Parameter|Optional?|Description|Sample value|
|---|---|---|---|
| | | | |  

**Response JSON on failure**  
HTTP response status code is 403 ( invalid api key) 
JSON object  *{'message' => 'Invalid api key supplied'}*

**Response JSON on success**  
HTTP response status code is 200  

JSON object  *{'version' => 2 }*  
<br>
___

### iOS

Get current iOS app version 
 
**POST** https://upushie.vul.io/api/version/ios

(No parameter is needed except for api_key)  

|Parameter|Optional?|Description|Sample value|
|---|---|---|---|
| | | | |

**Response JSON on failure**  
HTTP response status code is 403 ( invalid api key) 
JSON object  *{'message' => 'Invalid api key supplied'}*

**Response JSON on success**  
HTTP response status code is 200  

JSON object  *{'version' => 1 }*  
<br>
___
