//
//  VCXConfrenceViewController.swift
//  sampleTextApp
//
//  Created by smartflomeet on 08/04/2025.
//  Copyright © 2018 VideoChat. All rights reserved.
//

import UIKit
import EnxRTCiOS
import SVProgressHUD
class VCXConfrenceViewController: UIViewController {

    
    @IBOutlet weak var sendLogBtn: UIButton!
    
    @IBOutlet weak var publisherNameLBL: UILabel!
    @IBOutlet weak var subscriberNameLBL: UILabel!
    @IBOutlet weak var messageLBL: UILabel!
    @IBOutlet weak var localPlayerView: EnxPlayerView!
    @IBOutlet weak var cameraBTN: UIButton!
    @IBOutlet weak var speakerBTN: UIButton!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var optionsContainerView: UIView!
    
    @IBOutlet weak var optionViewButtonlayout: NSLayoutConstraint!
    var roomInfo : VCXRoomInfoModel!
    var param : [String : Any] = [:]
    var remoteRoom : EnxRoom!
    var objectJoin : EnxRtc!
    var localStream : EnxStream!
    var listOfParticipantInRoom  = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        localPlayerView.layer.cornerRadius = 8.0
        localPlayerView.layer.borderWidth = 2.0
        localPlayerView.layer.borderColor = UIColor.lightGray.cgColor
        localPlayerView.layer.masksToBounds = true
        optionsView.layer.cornerRadius = 8.0
        //optionViewButtonlayout.constant = -100
//        let tapGuester = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
//        tapGuester.numberOfTapsRequired = 1
//        self.view.addGestureRecognizer(tapGuester)
    
        // Adding Pan Gesture for localPlayerView
        let localViewGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didChangePosition))
        localPlayerView.addGestureRecognizer(localViewGestureRecognizer)
        
        objectJoin = EnxRtc()
        self.createToken()
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }
    // MARK: - didChangePosition
    /**
        This method will change the position of localPlayerView
     Input parameter :- UIPanGestureRecognizer
     **/
   @objc func didChangePosition(sender: UIPanGestureRecognizer) {
        let location = sender.location(in: view)
        if sender.state == .began {
        } else if sender.state == .changed {
            if(location.x <= (UIScreen.main.bounds.width - (self.localPlayerView.bounds.width/2)) && location.x >= self.localPlayerView.bounds.width/2) {
                self.localPlayerView.frame.origin.x = location.x
                localPlayerView.center.x = location.x
            }
            if(location.y <= (UIScreen.main.bounds.height - (self.localPlayerView.bounds.height + 40)) && location.y >= (self.localPlayerView.bounds.height/2)+20){
                self.localPlayerView.frame.origin.y = location.y
                localPlayerView.center.y = location.y
            }
           
        } else if sender.state == .ended {
            print("Gesture ended")
        }
    }
    // MARK: - sendLogtoServerEvent
    /**
     input parameter - Any
     Return  - Nil
     This method will Save all Socket Event logs to server
     **/
    @IBAction func sendLogtoServerEvent(_ sender: Any) {
        guard remoteRoom != nil else {
            return
        }
        remoteRoom.postClientLogs()
        print("Send Logs")
    }
    
    // MARK: - createTokrn
    /**
     input parameter - Nil
     Return  - Nil
     This method will initiate the Room for stream
     **/
    private func createToken(){
        guard VCXNetworkManager.isReachable() else {
            self.showAleartView(message:"Kindly check your Network Connection", andTitles: "OK")
            return
        }
        let inputParam : [String : String] = ["name" :roomInfo.participantName , "role" :  roomInfo.role ,"roomId" : roomInfo.room_id, "user_ref" : "2236"]
        SVProgressHUD.show()
        VCXServicesClass.featchToken(requestParam: inputParam, completion:{tokenInfo  in
            DispatchQueue.main.async {
              //  Success Response from server
                if let token = tokenInfo.token {
                    
                    let videoSize : [String : Any] =  ["minWidth" : 320 , "minHeight" : 180 , "maxWidth" : 1280, "maxHeight" :720]
                    
                    let localStreamInfo : [String : Any] = ["video" : self.param["video"]! ,"audio" : self.param["audio"]! ,"data" :self.param["chat"]! ,"name" :self.roomInfo.participantName!,"type" : "public","audio_only": false ,"maxVideoBW" : 120 ,"minVideoBW" : 80 , "videoSize" : videoSize]
                    
                    let playerConfiguration : [String : Any] = ["avatar":true,"audiomute":true, "videomute":true,"bandwidht":true, "screenshot":true,"iconColor":"#0000FF","iconWidth":25,"iconHeight":25]
                    
                   let roomInfo : [String : Any]  = ["allow_reconnect" : true , "number_of_attempts" : 3, "timeout_interval" : 20,"playerConfiguration":playerConfiguration,"activeviews" : "view"]
                    guard let steam = self.objectJoin.joinRoom(token, delegate: self, publishStreamInfo: localStreamInfo, roomInfo: roomInfo , advanceOptions: nil) else{
                        SVProgressHUD.dismiss()
                        return
                    }
                    self.localStream = steam
                    self.localStream.delegate = self as EnxStreamDelegate
                }
                //Handel if Room is full
                else if (tokenInfo.token == nil && tokenInfo.error == nil){
                    self.showAleartView(message:"Token Denied. Room is full.", andTitles: "OK")
                }
                //Handeling server error
                else{
                    print(tokenInfo.error)
                    self.showAleartView(message:tokenInfo.error, andTitles: "OK")
                }
                SVProgressHUD.dismiss()
            }
        })
        
    }
    // MARK: - Show Alert
    /**
     Show Alert Based in requirement.
     Input parameter :- Message and Event name for Alert
     **/
    private func showAleartView(message : String, andTitles : String){
        let alert = UIAlertController(title: " ", message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: andTitles, style: .default) { (action:UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
  /*  // MARK: - View Tap Event
    /**
     Its method will hide/unhide option View
     **/
  @objc func handleSingleTap(sender : UITapGestureRecognizer){
    if optionViewButtonlayout.constant >= 0{
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
            self.optionViewButtonlayout.constant = -100
        }, completion: nil)
    }
    else{
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.optionViewButtonlayout.constant = 10
        }, completion: nil)
        }
    }*/
    // MARK: - Mute/Unmute
    /**
     Input parameter : - Button Property
     OutPut : - Nil
     Its method will Mute/Unmute sound and change Button Property.
     **/
    @IBAction func muteUnMuteEvent(_ sender: UIButton) {
        guard remoteRoom != nil else {
            return
        }
        if sender.isSelected {
            localStream.muteSelfAudio(false)
            sender.isSelected = false
        }
        else{
            localStream.muteSelfAudio(true)
            sender.isSelected = true
        }
    }
    // MARK: - Camera On/Off
    /**
     Input parameter : - Button Property
     OutPut : - Nil
     Its method will On/Off Camera and change Button Property.
     **/
    @IBAction func cameraOnOffEvent(_ sender: UIButton) {
        guard remoteRoom != nil else {
            return
        }
        if sender.isSelected {
            localStream.muteSelfVideo(false)
            sender.isSelected = false
            cameraBTN.isEnabled = true
        }
        else{
            localStream.muteSelfVideo(true)
            sender.isSelected = true
            cameraBTN.isEnabled = false
        }
    }
    // MARK: - Camera Angle
    /**
     Input parameter : - Button Property
     OutPut : - Nil
     Its method will change Camera Angle and change Button Property.
     **/
    @IBAction func changeCameraAngle(_ sender: UIButton) {
        _ = localStream.switchCamera()
    }
    @IBAction func startChatEvent(_ sender: UIButton) {
    }
    // MARK: - Speaker On/Off
    /**
     Input parameter : - Button Property
     OutPut : - Nil
     Its method will On/Off Speaker and change Button Property.
     **/
    @IBAction func speakerOnOffEvent(_ sender: UIButton) {
        guard remoteRoom != nil else {
            return
        }
        if sender.isSelected {
            remoteRoom.switchMediaDevice("EARPIECE")
            sender.isSelected = false
        }
        else{
            remoteRoom.switchMediaDevice("Speaker")
            sender.isSelected = true
        }

    }
    // MARK: - End Call
    /**
     Input parameter : - Any
     OutPut : - Nil
     Its method will Closed Call and exist from Room
     **/
    @IBAction func endCallEvent(_ sender: Any) {
        self.leaveRoom()
        
    }
    // MARK: - Leave Room
    /**
     Input parameter : - Nil
     OutPut : - Nil
     Its method will exist from Room
     **/
    private func leaveRoom(){
        UIApplication.shared.isIdleTimerDisabled = false
        remoteRoom?.disconnect()
        //self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
/*
 // MARK: - Extension
 Delegates Methods
 */
extension VCXConfrenceViewController : EnxRoomDelegate, EnxStreamDelegate {
    //Mark - EnxRoom Delegates
    /*
     This Delegate will notify to User Once he got succes full join Room
     */
    func room(_ room: EnxRoom?, didConnect roomMetadata: [String : Any]?) {
        remoteRoom = room
        remoteRoom.publish(localStream)
        if remoteRoom.isRoomActiveTalker{
            if let name = remoteRoom.whoami()!["name"] {
                publisherNameLBL.text = (name as! String)
                localPlayerView.bringSubviewToFront(publisherNameLBL)                
            }
            localStream.attachRenderer(localPlayerView)
            localPlayerView.contentMode = UIView.ContentMode.scaleAspectFill
        }
        if listOfParticipantInRoom.count >= 1 {
            listOfParticipantInRoom.removeAll()
        }
        listOfParticipantInRoom.append(roomMetadata!["userList"] as! [Any])
        print(listOfParticipantInRoom);
    }
    /*
     This Delegate will notify to User Once he Getting error in joining room
     */
    func room(_ room: EnxRoom?, didError reason: [Any]?) {
        self.showAleartView(message:"Room error", andTitles: "OK")
    }
    /*
     This Delegate will notify to  User Once he/she Publisg Stream
     */
    func room(_ room: EnxRoom?, didPublishStream stream: EnxStream?) {
        //To Do
        remoteRoom.switchMediaDevice("Speaker")
        speakerBTN.isSelected = true
    }
    /*
     This Delegate will notify to  User Once he/she will Unpublisg Stream
     */
    func room(_ room: EnxRoom?, didUnpublishStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User if any new person added to room
     */
    func room(_ room: EnxRoom?, didAddedStream stream: EnxStream?) {
      _ =  room!.subscribe(stream!)
    }
    /*
     This Delegate will notify to User to subscribe other user stream
     */
    func room(_ room: EnxRoom?, didSubscribeStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User to Unsubscribe other user stream
     */
    func room(_ room: EnxRoom?, didUnSubscribeStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User if Room Got discunnected
     */
    func didRoomDisconnect(_ response: [Any]?) {
       self.navigationController?.popViewController(animated: true)
    }
    /*
     This Delegate will notify to User if any person join room
     */
    func room(_ room: EnxRoom?, userDidJoined Data: [Any]?) {
        //listOfParticipantInRoom.append(Data!)
    }
    /*
     This Delegate will notify to User if any person got discunnected
     */
    func room(_ room: EnxRoom?, userDidDisconnected Data: [Any]?) {
        //self.leaveRoom()
    }
    /*
     This Delegate will notify to end User if Room connecton status changed
     */
    func room(_ room : EnxRoom? , didChangeStatus status : EnxRoomStatus) {
        //To Do
    }
    /*
     This Delegate will notify to User if any participant will send chat data
     */
    func room(_ room: EnxRoom, didMessageReceived data: [Any]?) {
        //TO DO
    }
    /*
    This Delegate will notify to User if any participant will send message over custome signaling
    */
    func room(_ room: EnxRoom, didUserDataReceived data: [Any]?) {
        //TO Do
    }
    /*
    This Delegate will notify to User if any participant will start sharing files
    */
    func room(_ room: EnxRoom, didFileUploadStarted data: [Any]?) {
        //TO Do
    }
    /*
    This Delegate will notify to self  if he/she will start sharing files
    */
    func room(_ room: EnxRoom, didInitFileUpload data: [Any]?) {
        //To Do
    }
    /*
    This Delegate will notify to self  if file sharing success
    */
    func room(_ room: EnxRoom, didFileUploaded data: [Any]?) {
        //To DO
    }
    /*
    This Delegate will notify to self  if file sharing failed
    */
    func room(_ room: EnxRoom, didFileUploadFailed data: [Any]?) {
        //To DO
    }
    /*
    This Delegate will notify to end user  if file available
    */
    func room(_ room: EnxRoom, didFileAvailable data: [Any]?) {
        //TO DO
    }
    /*
    This Delegate will notify to self  if file download failed
    */
    func room(_ room: EnxRoom, didFileDownloadFailed data: [Any]?) {
        //TO Do
    }
    /*
    This Delegate will notify to self  if file download success
    */
    func room(_ room: EnxRoom, didFileDownloaded data: String?) {
        //TO DO
    }
    /*
     This Delegate will notify to User to get updated attributes of particular Stream
     */
    func room(_ room : EnxRoom? , didUpdateAttributesOfStream stream : EnxStream?) {
        //To Do
    }
    
    /*
     This Delegate will notify when internet connection lost.
     */
    func room(_ room: EnxRoom?, didConnectionLost data: [Any]?) {
      
    }
    
    /*
     This Delegate will notify on connection interuption example switching from Wifi to 4g.
     */
    func room(_ room: EnxRoom?, didConnectionInterrupted data: [Any]?) {
      
    }
    
    /*
     This Delegate will notify reconnect success.
     */
    func room(_ room: EnxRoom?, didUserReconnectSuccess data: [String : Any]?) {
       
    }
    
    /*
     This Delegate will notify to User if any new User Reconnect the room
     */
    func room(_ room:EnxRoom?, didReconnect reason: String?){
        
    }
    /*
     This Delegate will notify to User with active talker list
     */
    func room(_ room: EnxRoom?, didActiveTalkerList Data: [EnxStream]?) {
        // Handle individual stream and there player
    }
    func room(_ room: EnxRoom?, didActiveTalkerView view: UIView?) {
        self.view.addSubview(view!)
        self.view.bringSubviewToFront(localPlayerView)
        self.view.bringSubviewToFront(optionsContainerView)
        self.view.bringSubviewToFront(sendLogBtn)
    }

    
    
    func room(_ room: EnxRoom?, didEventError reason: [Any]?) {
        let resDict = reason![0] as! [String : Any]
        self.showAleartView(message:resDict["msg"] as! String, andTitles: "OK")
    }
    
    /* To Ack. moderator on switch user role.
   */
    func room(_ room: EnxRoom?, didSwitchUserRole data: [Any]?) {
        
    }
    
    /* To all participants that user role has chnaged.
    */
    func room(_ room: EnxRoom?, didUserRoleChanged data: [Any]?) {
        
    }
    
    /*
     This Delegate will Acknowledge setting advance options.
     */
    func room(_ room: EnxRoom?, didAcknowledgementAdvanceOption data: [String : Any]?) {
        
    }
    
    /*
     This Delegate will notify battery updates.
     */
    func room(_ room: EnxRoom?, didBatteryUpdates data: [String : Any]?) {
        
    }
    
    /*
     This Delegate will notify change on stream aspect ratio.
     */
    func room(_ room : EnxRoom?, didAspectRatioUpdates data : [String : Any]?) {
        
    }
    
    /*
     This Delegate will notify change video resolution.
     */
    func room(_ room: EnxRoom?, didVideoResolutionUpdates data: [Any]?) {
        
    }
    
    //Mark- EnxStreamDelegate Delegate
    /*
     This Delegate will notify to current User If any user has stoped There Video or current user Video
     */
    func didVideoEvents(_ data: [String : Any]?) {
        //To Do
    }
    /*
     This Delegate will notify to current User If any user has stoped There Audio or current user Video
     */
    func didAudioEvents(_ data: [String : Any]?) {
        //To Do
    }
}
