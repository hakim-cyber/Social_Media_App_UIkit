//
//  AvatarZoomPresenter.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 1/2/26.
//


import UIKit

final class AvatarZoomPresenter {

    static let shared = AvatarZoomPresenter()

    private var overlay: UIView?
    private var zoomImageView: UIImageView?
    private var startFrame: CGRect = .zero

    func present(from sourceView: UIView, image: UIImage?) {
        guard let window = sourceView.window ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        guard let image else { return }

        // Convert source frame to window coords
        startFrame = sourceView.convert(sourceView.bounds, to: window)

        // Overlay
        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        overlay.alpha = 1
        window.addSubview(overlay)

        // Image view starts at avatar position
        let iv = UIImageView(image: image)
        iv.frame = startFrame
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = min(startFrame.width, startFrame.height) / 2
        window.addSubview(iv)

        // Dismiss on tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        overlay.addGestureRecognizer(tap)

        self.overlay = overlay
        self.zoomImageView = iv

        // Target frame in center (fit screen)
        let target = self.centerFitFrame(for: image.size, in: window.bounds, padding: 24)

        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.75)
            iv.frame = target
            iv.layer.cornerRadius = min(target.width, target.height) / 2
            window.layoutIfNeeded()
        }
    }

    @objc func dismiss() {
        guard let overlay, let iv = zoomImageView else { cleanup(); return }

        UIView.animate(withDuration: 0.20, delay: 0, options: [.curveEaseInOut]) {
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            iv.frame = self.startFrame
            iv.layer.cornerRadius = min(self.startFrame.width, self.startFrame.height) / 2
        } completion: { _ in
            self.cleanup()
        }
    }

    private func cleanup() {
        overlay?.removeFromSuperview()
        zoomImageView?.removeFromSuperview()
        overlay = nil
        zoomImageView = nil
    }

    private func centerFitFrame(for imageSize: CGSize, in bounds: CGRect, padding: CGFloat) -> CGRect {
        let maxW = bounds.width - padding * 2
        let maxH = bounds.height - padding * 2

        let imgW = imageSize.width
        let imgH = imageSize.height
        guard imgW > 0, imgH > 0 else {
            let side = min(maxW, maxH)
            return CGRect(x: (bounds.width - side)/2, y: (bounds.height - side)/2, width: side, height: side)
        }

        let scale = min(maxW / imgW, maxH / imgH)
        let w = imgW * scale
        let h = imgH * scale
        let x = (bounds.width - w) / 2
        let y = (bounds.height - h) / 2
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
