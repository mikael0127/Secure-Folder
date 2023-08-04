//
//  VideoView.swift
//  Secure Folder
//
//  Created by Bryan Loh on 15/6/23.
//

import SwiftUI
import AVKit
import MediaPicker

struct VideoView: View {
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
            if isSelecting {
                ToolbarItem(placement: .navigationBarTrailing) {
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
    
    private func save(urls: [URL]) {
        for url in urls {
            save(url: url)
        }
        read()
    }
    
    private func save(url: URL) {
        let fileURLComponents = FileURLComponents(
            fileName: url.lastPathComponent,
            directoryName: "MainFolder/Videos",
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
        let items = File.read(from: "MainFolder/Videos", at: .documentDirectory)
        self.urls = items
        print("read: \(items)")
    }
    
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView()
    }
}


