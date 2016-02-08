# uPushie API

Last updated : 9 February 2016  

API Base URL : **https://upushie.vul.io/api/**

All API call must include the **api_key** parameter, the value for **api_key** is **upushie_correcthorsebatterystaple**

# Student objects
### Authenticate

Try to login to UTAR wble using the ID and password provided

**POST** https://upushie.vul.io/api/student/authenticate

|Parameter|Optional?|Description|Sample value|
|---|---|---|---|
|utar_id|Mandatory|UTAR ID of the student| 1206225 |
|utar_password|Mandatory|UTAR password of the student| password123 |

**Response JSON on failure**  
HTTP response status code is either 400 (bad request/parameters) or 403 (wrong utar login)  
JSON object  *{'message' => 'Blank input '}*

**Response JSON on success**  
HTTP response status code is 200  
JSON object  *{'message' => 'Login successful for student 1206225'}*  
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