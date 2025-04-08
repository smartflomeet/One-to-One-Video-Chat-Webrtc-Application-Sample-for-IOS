# Building a 1-to-1 Real-Time Communication iOS App with SmartfloMeet iOS Toolkit: A Comprehensive Guide

1-to-1 RTC: A Hands-On Guide to RTC Development Using SmartfloMeet iOS Toolkit
This Sample iOS App demonstrates the power and efficiency of SmartfloMeet platform Video APIs and iOS Toolkit.  It allows developers to ramp up on app development by hosting on their own devices.

Key Features
Virtual Room Creation: Seamlessly set up virtual rooms on the SmartfloMeet platform using REST calls.
Room Credentials: Take control of your RTC session by using Room IDs to connect as either a Moderator or Participant.
Flexibility: The app provides a unique "try" mode to use SmartfloMeet's hosted Application Server, allowing for quick testing without setting up your own server.

> SmartfloMeet Developer Center: https://doc.smartflomeet.ttns.in/

## 1. How to get started

### 1.1 Prerequisites

#### 1.1.1 App Id and App Key 


#### 1.1.2 Sample iOS Client 

* Clone or download this Repository [https://github.com/smartflomeet/One-to-One-Video-Chat-Webrtc-Application-Sample-for-IOS.git] 


#### 1.1.3 Test Application Server

You need to set up an Application Server to provision Web Service API for your iOS Application to enable Video Session. 

To help you to try our iOS Application quickly, without having to set up Applciation Server, this Application is shipped pre-configured to work in a "try" mode with SmartfloMeet hosted Application Server i.e. https://demo.smartflomeet.ttns.in/. 

Our Application Server restricts a single Session Duations to 10 minutes, and allows 1 moderator and not more than 1 Participant in a Session.

Once you tried SmartfloMeet iOS Sample Application, you may need to set up your own  Application Server and verify your Application to work with your Application Server.  Refer to point 2 for more details on this.


#### 1.1.4 Configure IOS Client 

* Open the App
* Go to VCXConstant.swift, it's reads- 

``` 
/* To try the App with SmartfloMeet Hosted Service you need to set the kTry = true
When you setup your own Application Service, set kTry = false */
let kTry = true

/* Your Web Service Host URL. Keet the defined host when kTry = true */
let kBasedURL = "https://demo.smartflomeet.ttns.in/"
    
/* Your Application Credential required to try with SmartfloMeet Hosted Service
When you setup your own Application Service, remove these */
let kAppId    = ""
let kAppkey   = ""

```
 
### 1.2 Test

#### 1.2.1 Open the App

* Open the App in your Device. You get a form to enter Credentials i.e. Name & Room Id.
* You need to create a Room by clicking the "Create Room" button.
* Once the Room Id is created, you can use it and share with others to connect to the Virtual Room to carry out an RTC Session either as a Moderator or a Participant (Choose applicable Role in the Form).

Note: Only one user with Moderator Role allowed to connect to a Virtual Room while trying with SmartfloMeet Hosted Service. Your Own Application Server can allow upto 5 Moderators.

Note:- In case of emulator/simulator your local stream will not create. It will create only on real device.

## 2. Set up Your Own Application Server

You can set up your own Application Server after you tried the Sample Application with SmartfloMeet hosted Server. We have differnt variants of Appliciation Server Sample Code. Pick the one in your preferred language and follow instructions given in respective README.md file.

* NodeJS: [https://github.com/smartflomeet/Video-Conferencing-Open-Source-Web-Application-Sample.git]<br/>
* PHP: [https://github.com/smartflomeet/Group-Video-Call-Conferencing-Sample-Application-in-PHP]

Note the following:

* You need to use App ID and App Key to run this Service.
* Your iOS Client EndPoint needs to connect to this Service to create Virtual Room and Create Token to join the session.
* Application Server is created using EnableX Server API while Rest API Service helps in provisioning, session access and post-session reporting.  

## 3. IOS Toolkit

This Sample Application uses SmartfloMeet iOS Toolkit to communicate with SmartfloMeet Servers to initiate and manage Real-Time Communications. Please update your Application with latest version of SmartfloMeet IOS Toolkit as and when a new release is available.

* Documentation: https://doc.smartflomeet.ttns.in/docs/references/sdks/video-sdk/ios-sdk/index
* Download Toolkit: https://doc.smartflomeet.ttns.in/developer/video-api/client-api/ios-toolkit/


