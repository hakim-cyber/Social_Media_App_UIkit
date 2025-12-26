//
//  ImagePickerCropper.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/12/25.
//


import UIKit
import TOCropViewController
import CropViewController

enum ImagePickerResult {
    case picked(UIImage)
    case deleted
    case cancelled
}
final class ImagePickerCropper: NSObject {

    private weak var presentingVC: UIViewController?
    private var onResult: ((ImagePickerResult) -> Void)?

    private var aspectRatio: CGSize = .init(width: 1, height: 1)
    private var croppingStyle: CropViewCroppingStyle = .default
    private var allowsDelete: Bool = true

    // MARK: - Public API

    func presentMenu(
        from viewController: UIViewController,
        sourceView: UIView? = nil,
        aspectRatio: CGSize = .init(width: 1, height: 1),
        croppingStyle: CropViewCroppingStyle = .default,
        allowsDelete: Bool = true,
        onResult: @escaping (ImagePickerResult) -> Void
    ) {
        self.presentingVC = viewController
        self.aspectRatio = aspectRatio
        self.croppingStyle = croppingStyle
        self.allowsDelete = allowsDelete
        self.onResult = onResult

        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.presentPicker(.photoLibrary)
        })

        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.presentPicker(.camera)
        })

        if allowsDelete {
            sheet.addAction(UIAlertAction(title: "Delete Image", style: .destructive) { [weak self] _ in
                self?.finish(.deleted)
            })
        }

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.finish(.cancelled)
        })

        if let pop = sheet.popoverPresentationController {
            pop.sourceView = sourceView ?? viewController.view
            pop.sourceRect = (sourceView ?? viewController.view).bounds
        }

        viewController.present(sheet, animated: true)
    }

    // MARK: - Picker

    private func presentPicker(_ sourceType: UIImagePickerController.SourceType) {
        guard let vc = presentingVC,
              UIImagePickerController.isSourceTypeAvailable(sourceType)
        else {
            finish(.cancelled)
            return
        }

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = false
        vc.present(picker, animated: true)
    }

    private func presentCropper(image: UIImage) {
        guard let vc = presentingVC else { return }

        let cropVC = CropViewController(croppingStyle: croppingStyle, image: image)
        cropVC.delegate = self

        cropVC.aspectRatioLockEnabled = true
        cropVC.aspectRatioPickerButtonHidden = true
        cropVC.resetButtonHidden = true
        
        cropVC.aspectRatioPreset = aspectRatio

        vc.present(cropVC, animated: true)
    }

    private func finish(_ result: ImagePickerResult) {
        onResult?(result)
        onResult = nil
    }
}

extension ImagePickerCropper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            finish(.cancelled)
            return
        }

        presentCropper(image: image)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        finish(.cancelled)
    }
}

extension ImagePickerCropper: CropViewControllerDelegate {

    func cropViewController(_ cropViewController: CropViewController,
                            didCropToImage image: UIImage,
                            withRect cropRect: CGRect,
                            angle: Int) {
        cropViewController.dismiss(animated: true)
        finish(.picked(image))
    }

    func cropViewController(_ cropViewController: CropViewController,
                            didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
        finish(.cancelled)
    }
}
