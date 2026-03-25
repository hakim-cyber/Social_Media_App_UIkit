//
//  RoundedImage+CachingView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/12/25.
//


import UIKit

import Kingfisher

/// A reusable UIImageView subclass that loads/caches remote images with Kingfisher,
/// and supports circle/rounded presentation with border & activity indicator.
final class KFAsyncImageView: UIImageView {

    // MARK: Presentation
    enum Shape {
        case rectangle(cornerRadius: CGFloat = 0)
        case circle                         // auto: radius = min(width, height)/2
    }

    /// Set how the view should be masked.
    var shape: Shape = .rectangle() { didSet { setNeedsLayout() } }

    /// Optional border.
    var borderWidth: CGFloat = 0 { didSet { layer.borderWidth = borderWidth } }
    var borderColor: UIColor = .clear { didSet { layer.borderColor = borderColor.cgColor } }

    /// Show a small activity indicator while loading.
    var showsActivityIndicator: Bool = true

    /// Placeholder while loading / on failure.
    var placeholder: UIImage? = UIImage(systemName: "photo")

    // MARK: Internal state
    private var spinner: UIActivityIndicatorView?
    private var lastAppliedProcessorSize: CGSize = .zero

    private var currentURL: URL?
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    private func commonInit() {
        clipsToBounds = true
        contentMode = .scaleAspectFill
        image = placeholder
        isAccessibilityElement = true
        accessibilityTraits = .image
    }

    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        switch shape {
        case .rectangle(let r):
            layer.cornerRadius = r
        case .circle:
            layer.cornerRadius = min(bounds.width, bounds.height) / 2
        }

        // If size changed, re-apply downsampling (cache hit, no extra network).
        if let sourceURL = currentURL,
           bounds.size != .zero,
           bounds.size != lastAppliedProcessorSize {
            applyKingfisher(to: sourceURL) // uses cached original, reapplies processor for new size
        }
    }

    // MARK: Public API

    /// Load image from remote URL with Kingfisher. Safe to call repeatedly (reuses cache).
    func setImage(url: URL?, animated: Bool = true) {
        accessibilityLabel = "Image"
        currentURL = url
        guard let url else {
            self.image = placeholder
            return
        }

        // If we don't know our size yet, Kingfisher will still fetch & cache;
        // we'll re-apply a right-sized processor in layoutSubviews when size is known.
        applyKingfisher(to: url, animated: animated)
    }

    /// Cancel any ongoing download (call from a reusable cell’s `prepareForReuse()`).
    func cancelLoad() {
        kf.cancelDownloadTask()
        stopSpinner()
    }

    // MARK: Kingfisher plumbing

    private func applyKingfisher(to url: URL, animated: Bool = true) {
        lastAppliedProcessorSize = bounds.size == .zero ? lastAppliedProcessorSize : bounds.size

        // Downsample to current size if known; otherwise Kingfisher still caches the original.
        let targetSize = lastAppliedProcessorSize == .zero ? CGSize(width: 300, height: 300) : lastAppliedProcessorSize
        let processor = DownsamplingImageProcessor(size: targetSize)

        var opts: KingfisherOptionsInfo = [
            .processor(processor),
            .scaleFactor(self.window?.windowScene?.screen.scale ?? 3.0),
            .cacheOriginalImage,
            .backgroundDecode,
            .loadDiskFileSynchronously
        ]
        if animated { opts.append(.transition(.fade(0.2))) }

        if showsActivityIndicator { startSpinner() }

        kf.setImage(
            with: url,
            placeholder: placeholder,
            options: opts
        ) { [weak self] result in
            guard let self else { return }
            self.stopSpinner()
            if case .failure = result {
                // Optional: keep placeholder or set a fallback
                self.image = self.placeholder
            }
        }
    }

    // MARK: Spinner
    private func startSpinner() {
        guard showsActivityIndicator else { return }
        if spinner == nil {
            let s = UIActivityIndicatorView(style: .medium)
            s.hidesWhenStopped = true
            s.translatesAutoresizingMaskIntoConstraints = false
            addSubview(s)
            NSLayoutConstraint.activate([
                s.centerXAnchor.constraint(equalTo: centerXAnchor),
                s.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            spinner = s
        }
        spinner?.startAnimating()
    }
    private func stopSpinner() {
        spinner?.stopAnimating()
    }
}

