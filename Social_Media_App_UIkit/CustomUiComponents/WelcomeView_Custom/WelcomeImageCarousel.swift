//
//  ImageCarousel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/22/25.
//
import UIKit

class ImageCarouselView: UIView {
    
     let images: [UIImage]
    private var collectionView: UICollectionView!
    private var layout: UICollectionViewFlowLayout!
    
    var onPageChanged: ((Int) -> Void)?
    
    private var currentPage = 0
    private var timer: Timer?
    init(images: [UIImage],autoScroll:Bool = true) {
        self.images = images
        super.init(frame: .zero)
        setupCollectionView()
        // Scroll to first item immediately after collection view is laid out
            
            
            if autoScroll {
                startAutoScroll()
            }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupCollectionView() {
        layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
      
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: "cell")
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        guard width > 0 else { return }
        
        let pageDouble = scrollView.contentOffset.x / width
        guard pageDouble.isFinite else { return }
        
        let page = Int(round(pageDouble))
        
        if page != currentPage {
            currentPage = page
            onPageChanged?(page)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !images.isEmpty else { return }
        print("Layout Subviews")
        if layout.itemSize != self.bounds.size {
            layout.itemSize = self.bounds.size
            layout.invalidateLayout()
            
            // Scroll to first item after layout is ready
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let indexPath = IndexPath(item: 0, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }
        }
    }
    // MARK: - Auto Scroll
       
       private func startAutoScroll() {
           timer = Timer.scheduledTimer(timeInterval: 3.0, target: self,
                                        selector: #selector(scrollToNextPage),
                                        userInfo: nil, repeats: true)
           RunLoop.current.add(timer!, forMode: .common)
       }
    @objc private func scrollToNextPage() {
        guard images.count > 1 else { return }

        // calculate next index manually
        let nextIndex = (currentPage + 1) % images.count
        let indexPath = IndexPath(item: nextIndex, section: 0)
        
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)

        // update currentPage immediately, don't rely on indexPathForItem
        currentPage = nextIndex
    }
    func scrollToIndex(index:Int) {
           let rect = self.collectionView.layoutAttributesForItem(at: IndexPath(row: index, section: 0))?.frame
           self.collectionView.scrollRectToVisible(rect!, animated: true)
         }
       
       deinit {
           timer?.invalidate()
       }
}

extension ImageCarouselView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CarouselCell
        cell.imageView.image = images[indexPath.item]
        return cell
    }
}

// MARK: - Cell
class CarouselCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
