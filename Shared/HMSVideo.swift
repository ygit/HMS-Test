//
//  HMSVideo.swift
//  Test-iOS
//
//  Created by Yogesh Singh on 22/02/21.
//

import Foundation
import HMSVideo

class HMSVideo {
    
    let notification = "HMSVideoUpdateNotification"
    
    let client: HMSClient
    
    var room: HMSRoom?
    
    var peers = [String: HMSPeer]()
    
    
    init() {
        //Create an HMSPeer instance for local peer
        let peer = HMSPeer(name: "Yogesh", authToken: "")

        let config = HMSClientConfig()
        //config.endpoint = "Override endpoint URL if needed"

        //Create a 100ms video client
        client = HMSClient(peer: peer, config: config)
        
        client.onPeerJoin = { [unowned self] room, peer in
            
            NotificationCenter.default.post(name: Notification.Name(self.notification), object: nil)
            
        }
        
        client.onPeerLeave = { room, peer in
            // Update UI if needed
        }

        client.onStreamAdd = { [weak self] room, peer, streamInfo  in
            // Subscribe to the stream if needed
            // peer contains peerId (assigned by 100ms) and customerUserId (assigned by you)
            // streamInfo contains screen to identify it as a screen-share
            
            self?.client.subscribe(streamInfo, room: room) { stream, error in
                //Handle error if any, update UI if needed
            }
        }

        client.onStreamRemove = { room, peer, streamInfo  in
            // Remove remote stream view if needed
        }

        client.onBroadcast = { room, peer, message in
            // update UI if needed
        }

        client.onConnect = {
                // Client connected, this is a good place to call join(room)
        }

        client.onDisconnect = { error in
                // Connection lost or could not be established.
                // Good place to retry or show an error to the user.
        }
        
        client.connect()
    }
    
    func join(room id: String) {
        
        room = HMSRoom(roomId: id)
        client.join(room!) { (success, error) in
            //check for error and publish a local stream
        }
    }
    
    func getLocalCameraStream() {
        let constraints = HMSMediaStreamConstraints()
        constraints.shouldPublishAudio = true
        constraints.shouldPublishVideo = true
        constraints.codec = .VP8
        constraints.bitrate = 256 //Maximum bitrate consumed for the video
        constraints.audioBitrate = 30
        constraints.frameRate = 20
        constraints.resolution = .QVGA //This determines video width and height. Possible values - qqvga, qvga, shd, hd

        if let stream = try? client.getLocalStream(constraints) {
            
            //Get the video capturer and video track
            let videoCapturer = stream.videoCapturer
            let localVideoTrack = stream.videoTracks?.first

            //Begin capturing video from the camera
            videoCapturer?.startCapture()

            //Create a view for rendering video track and add to the UI hierarchy
            if let track = localVideoTrack {
                let videoView = HMSVideoView()
                    videoView.setVideoTrack(track)
//                    view.addSubview(videoView)
            }
            
            client.publish(stream, room: room!) { stream, error in
                //Handle error if any, update UI if needed
            }
        }
    }
    
    
    func broadcast(message: [AnyHashable: Any]) {
        
        client.broadcast(message, room: room!) { stream, error in
            //Handle error if any, update UI if needed
        }
    }
    
    func unpublish(stream: HMSStream) {
        
        client.unpublish(stream, room: room!) { stream, error in
            //Handle error if any, update UI if needed
        }
    }
    
    func unsubscribe(stream: HMSStream) {
        client.unsubscribe(stream, room: room!) { stream, error in
            //Handle error if any, update UI if needed
        }
    }
    
    func disconnect() {
        client.disconnect()
    }
    
    
}
