//
//  VideoPlayerView.swift
//  Secure Folder
//
//  Created by Bryan Loh on 15/08/2023.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let url: URL?
    @StateObject var viewModel = VideoPlayerViewModel()
    
    var body: some View {
        VideoPlayer(player: viewModel.player)
            .onAppear {
                viewModel.url = url
            }
    }
}

