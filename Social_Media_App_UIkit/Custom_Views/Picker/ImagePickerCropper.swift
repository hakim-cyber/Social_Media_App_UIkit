//
//  ImagePickerCropper.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/12/25.
//


import UIKit
import TOCropViewController
import CropViewController

final class ImagePickerCropper: NSObject {
    // MARK: - Singleton
    static let shared = ImagePickerCropper()

    private override init() {}

    // MARK: - Stored callback
    private var completion: ((UIImage) -> Void)?
    private var aspectRatio: CGSize = CGSize(width: 1, height: 1)
    private var croppingStyle: CropViewCroppingStyle = .default

    private weak var presentingVC: UIViewController?

    // MARK: - Present picker
    func present(from viewController: UIViewController,
                 aspectRatio: CGSize = CGSize(width: 1, height: 1),
                 croppingStyle:CropViewCroppingStyle = .default
                 ,
                 sourceType: UIImagePickerController.SourceType = .photoLibrary,
                 
                 completion: @escaping (UIImage) -> Void) {

        self.presentingVC = viewController
        self.aspectRatio = aspectRatio
        self.completion = completion
        self.croppingStyle = croppingStyle

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = false

        viewController.present(picker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ImagePickerCropper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }

        // Present crop controller
        let vc = CropViewController(croppingStyle: croppingStyle, image: image)
        vc.delegate = self
        
        vc.aspectRatioLockEnabled = true
        
        vc.aspectRatioPickerButtonHidden = true
        vc.resetButtonHidden = true
        vc.aspectRatioPreset  = aspectRatio
        vc.toolbarPosition = .bottom
        presentingVC?.present(vc, animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - TOCropViewControllerDelegate
extension ImagePickerCropper: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        completion?(image)
        completion = nil
    }


    func cropViewController(_ cropViewController: CropViewController,
                            didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
}
