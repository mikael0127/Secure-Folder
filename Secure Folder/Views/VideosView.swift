//
//  VideosView.swift
//  Secure Folder
//
//  Created by Bryan Loh on 15/6/23.
//  Editted by Mikael Denys Widjaja
//


import SwiftUI
import AVKit
import MediaPicker

struct VideosView: View {
    @EnvironmentObject var inactivityTimerManager: InactivityTimerManager

    @State var urls: [URL] = []
    @State var isShowingMediaPicker = false

    @State private var isSelecting: Bool = false
    @State private var selected: Set<URL> = []

    @State private var videoURL: URL?

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
                                .onTapGesture {
                                    if isSelecting {
                                        if selected.contains(url) {
                                            selected.remove(url)
                                        } else {
                                            selected.insert(url)
                                        }
                                    } else {
                                        videoURL = url
                                    }
                                }
                        default:
                            Text("Can't display \(url.lastPathComponent)")
                        }

                        if isSelecting {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)

                                if selected.contains(url) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.green)
                                }
                            }
                            .opacity(isSelecting ? 1 : 0)
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
        .sheet(isPresented: Binding(get: {
            videoURL != nil
        }, set: { value in
            if value == false { videoURL = nil }
        })) {
            VideoPlayerView(url: videoURL)
        }

        .navigationTitle("Videos")
        .toolbar {
            if !urls.isEmpty {
                if isSelecting {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button {
                                FileSharing.shared.message(Array(selected))
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
                                delete(urls: Array(selected))
                                selected.removeAll()
                                isSelecting = false
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
                        if isSelecting {
                            selected.removeAll()
                        }
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

struct VideosView_Previews: PreviewProvider {
    static var previews: some View {
        VideosView()
            .environmentObject(InactivityTimerManager())
    }
}

