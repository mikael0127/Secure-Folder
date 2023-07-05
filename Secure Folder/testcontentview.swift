//
//  testcontentview.swift
//  Secure Folder
//
//  Created by Bryan Loh on 17/6/23.
//
import SwiftUI
import PhotosUI

struct testcontentview: View {
    @ObservedObject var viewModel: TestView
    let imageSaver = ImageSaver()

    var body: some View {
        VStack {
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images, photoLibrary: .shared()) {
                switch viewModel.imageState {
                case .empty:
                    Image(uiImage: UIImage(contentsOfFile: FileManager.documentsDirectory.appendingPathComponent("Untitled_design_8.jpg").path()) ?? Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue) as! UIImage).resizable().scaledToFit()
                case .loading:
                    ProgressView()//to create progress view if this works
                case let .success(image):
                    image.resizable().scaledToFit()
                case .failure:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                }
            }
            Button {
                imageSaver.writeToDisk(image: viewModel.uiImageToSave!, imageName: "myImage")
            } label: {
                Text("Save Me!").bold()
            }.padding(.top, 100)
        }
    }
}

/*struct testcontentview_Previews: PreviewProvider {
    static var previews: some View {
        testview()
        
    }
}*/
