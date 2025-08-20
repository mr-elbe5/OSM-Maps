/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var image : UIImage
    var imageView : UIImageView
    
    var scrollView = UIScrollView()
    var contentView = UIView()
    
    init(image: UIImage) {
        self.image = image
        imageView = UIImageView(image: image)
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        title = "image".localize()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        scrollView.addSubviewWithAnchors(contentView, top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor)
            .width(scrollView.widthAnchor)
        scrollView.maximumZoomScale = 1.0
        scrollView.delegate = self
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        scrollView.addSubviewFilling(imageView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let minWidthScale = scrollView.bounds.width / image.size.width
        let minHeightScale = scrollView.bounds.height / image.size.height
        scrollView.minimumZoomScale = min(minWidthScale,minHeightScale)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
