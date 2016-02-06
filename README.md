# uPushie API

API Base URL : **http://upushie.vul.io/api/**

# Student objects
### Authenticate
**POST** http://upushie.vul.io/api/student/authenticate

|Parameter|Optional?|Description|Sample value|
|---|---|---|---|
|utar_id|Mandatory|UTAR ID of the student| 1206225 |
|utar_password|Mandatory|UTAR password of the student| password123 |
|os|Mandatory|Operating system of the student (either **ios** or **android** )| android|
|device_token|Required if OS is iOS| Device token of the iOS device | [64 characters] |
|registration_id| Required if OS is Android | Registration ID of the Android device | [some string] |

**Response JSON on failure**  
HTTP response status code is either 400 (bad request/parameters) or 403 (wrong utar login)
JSON object  *{:message => 'Blank input or invalid operating system specified'}*

**Response JSON on success**  
HTTP response status code is 200  
JSON object  *{:message => 'Login successful for student 1206225'}*  
<br>
___