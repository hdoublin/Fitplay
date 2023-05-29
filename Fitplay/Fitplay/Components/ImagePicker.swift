//
//  ImagePicker.swift
//  Fitplay
//
//  Created by Samuel Vulakh on 4/27/23.
//

import Foundation
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    
    @Binding var type: UIImagePickerController.SourceType
    
    init(image: Binding<UIImage?>, type: Binding<UIImagePickerController.SourceType> = .constant(.photoLibrary)) {
        self._image = image
        self._type = type
    }
    
    func makeCoordinator() -> ImagePickerCoordinator {
        ImagePickerCoordinator(image: $image)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = context.coordinator
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return pickerController }
        
        pickerController.sourceType = type
        pickerController.allowsEditing = true
        return pickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    final class ImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        @Binding var image: UIImage?
        
        init(image: Binding<UIImage?>) {
            _image = image
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            guard let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            
            self.image = uiImage
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("Canceled")
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
