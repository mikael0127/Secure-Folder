//
//  PhotosView.swift
//  Secure Folder
//
//  Created by Bryan Loh on 4/8/23.
//

import Foundation
import SwiftUI
import MediaPicker

struct PhotosView: View {
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
                Text("Add New Photo(s)")
                Image(systemName: "photo.artframe")
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .mediaImporter(
            isPresented: $isShowingMediaPicker,
            allowedMediaTypes: .images,
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
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .center, spacing: 4) {
                    ForEach(urls, id: \.absoluteString) { url in
                        ZStack(alignment: .topTrailing) {
                            switch try! url.resourceValues(forKeys: [.contentTypeKey]).contentType! {
                            case let contentType where contentType.conforms(to: .image):
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 150)
                                        .aspectRatio(1, contentMode: .fill)
                                        .clipped()
                                        .cornerRadius(12)
                                } placeholder: {
                                    ProgressView()
                                }
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
                                .padding(5)
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
                }
                .animation(.default, value: urls)
                
            } header: {
                selectButton
            }
        }
        .onAppear {
            read()
        }
                
        .navigationTitle("Photos")
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
    
    private let directoryName = "MainFolder/Photos"
    
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

struct PhotosView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosView()
            .environmentObject(InactivityTimerManager())
    }
}
