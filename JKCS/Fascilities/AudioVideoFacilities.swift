//
//  AudioVideoFacilities.swift
//  TemplateApp
//
//  Created by John Kuang on 2018-12-06.
//  Copyright © 2018 JandJ. All rights reserved.
//

import Foundation
import AVKit

public class AudioVideoFacilities: NSObject {
    var player: AVPlayer?

    func playSound(sURL: String) {
        let url = URL(string: sURL)
        guard url != nil else {
            return
        }
        let playerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)
        if player != nil {
            player!.play()
        }
        
        /*
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        self.contentView.layoutSublayers(of: playerLayer)
         */
    }
}
