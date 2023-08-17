    //
//  VideoPlayerViewModel.swift
//  Secure Folder
//
//  Created by Bryan Loh on 15/08/2023.
//

import SwiftUI
import AVKit

class VideoPlayerViewModel : ObservableObject {
    @Published var url : URL? {
        didSet {
            guard let url = url else { return }
            player = AVPlayer(url: url)
            player.seek(to: .zero)
            player.play()
        }
    }
    var player = AVPlayer()
}
