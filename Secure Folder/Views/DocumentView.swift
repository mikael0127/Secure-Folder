//
//  DocumentView.swift
//  Secure Folder
//
//  Created by Bryan Loh on 15/6/23.
//

import Foundation
import SwiftUI

struct DocumentView: View {
    
    @State var urls: [URL] = []
    @State var isShowingDocumentsPicker = false
    
    @State private var isSelecting: Bool = false
    @State private var selected: [URL] = []
    
    var selectButton: some View {
        Button {
            isShowingDocumentsPicker = true
        } label: {
            HStack {
                Text("Add New Document(s)")
                Image(systemName: "doc")
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .fileImporter(
            isPresented: $isShowingDocumentsPicker,
//            allowedContentTypes: [.text, .pdf, .audio, .epub, ],
            allowedContentTypes: [.item],
            allowsMultipleSelection: true)
        { result in
            do {
                let urls = try result.get()
                save(urls: urls)
            } catch {
                print("failed to select docs: \(error.localizedDescription)")
            }
            
        }
    }
    
    var body: some View {
        
        List {
            Section {
                ForEach(urls, id: \.absoluteString) { url in
                    ZStack(alignment: .trailing) {
                        Text(url.lastPathComponent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
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
                    .contentShape(Rectangle())
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
                
        .navigationTitle("Documents")
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
        guard url.startAccessingSecurityScopedResource() else { return }
        // We have to stop accessing the resource no matter what
        defer { url.stopAccessingSecurityScopedResource() }
        let fileURLComponents = FileURLComponents(
            fileName: url.lastPathComponent,
            directoryName: "MainFolder/Documents",
            directoryPath: .documentDirectory
        )
        do {
            let data = try Data(contentsOf: url)
            let savedAtURL = try File.write(data, to: fileURLComponents)
            print("Saved at: \(savedAtURL)")
        } catch {
            print("Error saving URL: \(error.localizedDescription)")
        }
    }
    
    private func read() {
        let items = File.read(from: "MainFolder/Documents", at: .documentDirectory)
        self.urls = items
        print("read: \(items)")
    }
    
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView()
    }
}
