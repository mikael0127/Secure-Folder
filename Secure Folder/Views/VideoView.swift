//
//  DocumentView.swift
//  Secure Folder
//
//  Created by Bryan Loh on 15/6/23.
//

import SwiftUI
import AVKit
import MediaPicker

struct VideoView: View {
    @EnvironmentObject var inactivityTimerManager: InactivityTimerManager

    @State var urls: [URL] = []
    @State var isShowingMediaPicker = false

    @State private var isSelecting: Bool = false
    @State private var selected: [URL] = []

    var selectButton: some View {
        Button {
            isShowingMediaPicker = true
        } label: {
            HStack {
                Text("Add New Video(s)")
                Image(systemName: "video")
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .mediaImporter(
            isPresented: $isShowingMediaPicker,
            allowedMediaTypes: .videos,
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                save(urls: urls)
            case .failure(let error):
                print(error)
            }
        }
    }

    var body: some View {

        List {
            Section {
                ForEach(urls, id: \.absoluteString) { url in
                    ZStack(alignment: .topTrailing) {
                        switch try! url.resourceValues(forKeys: [.contentTypeKey]).contentType! {
                        case let contentType where contentType.conforms(to: .audiovisualContent):
                            VideoPlayer(player: AVPlayer(url: url))
                                .scaledToFit()
                        default:
                            Text("Can't display \(url.lastPathComponent)")
                        }

                        if isSelecting {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)

                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.green)
                            }
                            .opacity(selected.contains(url) ? 1 : 0)
                        }
                    }
                    .onTapGesture {
                        guard isSelecting else { return }
                        if selected.contains(url) {
                            selected.removeAll(where: { $0 == url })
                        } else {
                            selected.append(url)
                        }
                    }
                }
            } header: {
                selectButton
            }
        }
        .onAppear {
            read()
        }

        .navigationTitle("Videos")
        .toolbar {
            if !urls.isEmpty {
                if isSelecting {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button {
                                FileSharing.shared.message(selected)
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)

                                    Text("Share")
                                }
                            }

                            Button {
                                delete(urls: selected)
                            } label: {
                                Image(systemName: "trash")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.red)
                                    .frame(width: 20, height: 20)
                            }

                        }

                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if isSelecting { selected.removeAll() }
                        isSelecting.toggle()
                    } label: {
                        Text(isSelecting ? "Cancel" : "Select")
                    }
                }
            }
        }
        .onTapGesture {
            // Reset the inactivity timer whenever there is user interaction
            inactivityTimerManager.resetTimer()
        }

    }

    private func save(urls: [URL]) {
        for url in urls {
            save(url: url)
        }
        read()
    }

    private let directoryName = "MainFolder/Videos"

    private func save(url: URL) {
        let fileURLComponents = FileURLComponents(
            fileName: url.lastPathComponent,
            directoryName: directoryName,
            directoryPath: .documentDirectory
        )
        do {
            let data = try Data(contentsOf: url)
            let savedAtURL = try File.write(data, to: fileURLComponents)
            print("saved at: \(savedAtURL)")
        } catch {
            print("error saving url: \(error.localizedDescription)")
        }
    }

    private func read() {
        let items = File.read(from: directoryName, at: .documentDirectory)
        self.urls = items
        print("read: \(items)")
    }

    private func delete(urls: [URL]) {
        for url in urls {
            let fileURLComponents = FileURLComponents(
                fileName: url.lastPathComponent,
                directoryName: directoryName,
                directoryPath: .documentDirectory
            )
            _ = try? File.delete(fileURLComponents)
        }
        read()
    }

}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView()
            .environmentObject(InactivityTimerManager())
    }
}



// attempt 2
//import SwiftUI
//import AVKit
//import MediaPicker
//
//struct VideoView: View {
//    @EnvironmentObject var inactivityTimerManager: InactivityTimerManager
//
//    @State var urls: [URL] = []
//    @State var isShowingMediaPicker = false
//
//    @State private var isSelecting: Bool = false
//    @State private var selected: [URL] = []
//
//    @State private var selectedVideoURL: URL? = nil
//    @State private var isFullScreenVideoPlayerPresented = false
//
//    var selectButton: some View {
//        Button {
//            isShowingMediaPicker = true
//        } label: {
//            HStack {
//                Text("Add New Video(s)")
//                Image(systemName: "video")
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: .center)
//        .mediaImporter(
//            isPresented: $isShowingMediaPicker,
//            allowedMediaTypes: .videos,
//            allowsMultipleSelection: true
//        ) { result in
//            switch result {
//            case .success(let urls):
//                save(urls: urls)
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//
//    var body: some View {
//
//        List {
//            Section {
//                ForEach(urls, id: \.absoluteString) { url in
//                    ZStack(alignment: .topTrailing) {
//                        switch try! url.resourceValues(forKeys: [.contentTypeKey]).contentType! {
//                        case let contentType where contentType.conforms(to: .audiovisualContent):
//                            VideoPlayer(player: AVPlayer(url: url))
//                                .scaledToFit()
//                        default:
//                            Text("Can't display \(url.lastPathComponent)")
//                        }
//
//                        if isSelecting {
//                            ZStack {
//                                Circle()
//                                    .fill(Color.white)
//                                    .frame(width: 24, height: 24)
//
//                                Image(systemName: "checkmark.circle.fill")
//                                    .resizable()
//                                    .frame(width: 24, height: 24)
//                                    .foregroundColor(.green)
//                            }
//                            .opacity(selected.contains(url) ? 1 : 0)
//                        }
//                    }
//                    .onTapGesture {
//                        guard !isSelecting else { return }
//                        selectedVideoURL = url
//                        isFullScreenVideoPlayerPresented.toggle()
//                    }
//                }
//            } header: {
//                selectButton
//            }
//        }
//        .onAppear {
//            read()
//        }
//
//        .navigationTitle("Videos")
//        .toolbar {
//            if !urls.isEmpty {
//                if isSelecting {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        HStack {
//                            Button {
//                                FileSharing.shared.message(selected)
//                            } label: {
//                                HStack {
//                                    Image(systemName: "square.and.arrow.up")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 20, height: 20)
//
//                                    Text("Share")
//                                }
//                            }
//
//                            Button {
//                                delete(urls: selected)
//                            } label: {
//                                Image(systemName: "trash")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .foregroundColor(.red)
//                                    .frame(width: 20, height: 20)
//                            }
//
//                        }
//
//                    }
//                }
//
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        if isSelecting { selected.removeAll() }
//                        isSelecting.toggle()
//                    } label: {
//                        Text(isSelecting ? "Cancel" : "Select")
//                    }
//                }
//            }
//        }
//        .onTapGesture {
//            // Reset the inactivity timer whenever there is user interaction
//            inactivityTimerManager.resetTimer()
//        }
//        .sheet(isPresented: $isFullScreenVideoPlayerPresented) {
//            if let selectedVideoURL = selectedVideoURL {
//                FullScreenVideoView(videoURL: selectedVideoURL)
//            }
//        }
//    }
//
//    private func save(urls: [URL]) {
//        for url in urls {
//            save(url: url)
//        }
//        read()
//    }
//
//    private let directoryName = "MainFolder/Videos"
//
//    private func save(url: URL) {
//        let fileURLComponents = FileURLComponents(
//            fileName: url.lastPathComponent,
//            directoryName: directoryName,
//            directoryPath: .documentDirectory
//        )
//        do {
//            let data = try Data(contentsOf: url)
//            let savedAtURL = try File.write(data, to: fileURLComponents)
//            print("saved at: \(savedAtURL)")
//        } catch {
//            print("error saving url: \(error.localizedDescription)")
//        }
//    }
//
//    private func read() {
//        let items = File.read(from: directoryName, at: .documentDirectory)
//        self.urls = items
//        print("read: \(items)")
//    }
//
//    private func delete(urls: [URL]) {
//        for url in urls {
//            let fileURLComponents = FileURLComponents(
//                fileName: url.lastPathComponent,
//                directoryName: directoryName,
//                directoryPath: .documentDirectory
//            )
//            _ = try? File.delete(fileURLComponents)
//        }
//        read()
//    }
//
//}
//
//struct VideoView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoView()
//            .environmentObject(InactivityTimerManager())
//    }
//}
//
//struct FullScreenVideoView: View {
//    var videoURL: URL
//    @State private var player = AVPlayer()
//
//    var body: some View {
//        VideoPlayer(player: player)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .edgesIgnoringSafeArea(.all)
//            .onAppear {
//                let playerItem = AVPlayerItem(url: videoURL)
//                player.replaceCurrentItem(with: playerItem)
//                player.play()
//            }
//            .onDisappear {
//                player.pause()
//            }
//    }
//}
//
