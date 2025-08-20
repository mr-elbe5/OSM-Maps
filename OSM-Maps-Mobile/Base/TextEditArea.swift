/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class TextEditArea : UITextView{
    
    private let placeholderTextView: UITextView = {
        let tv = UITextView()
        
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.textColor = .placeholderText
        tv.isUserInteractionEnabled = false
        return tv
    }()
    
    var placeholder: String? {
        get {
            return placeholderTextView.text
        }
        set {
            placeholderTextView.text = newValue
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        placeholderTextView.font = UIFont.preferredFont(forTextStyle: .body)
        addSubviewFilling(placeholderTextView, insets: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDefaults(placeholder : String = ""){
        super.setDefaults()
        self.placeholder = placeholder
    }
    
    func defaultWithBorder() -> TextEditArea{
        setGrayRoundedBorders()
        setDefaults()
        isScrollEnabled = false
        setKeyboardToolbar(doneTitle: "done".localize())
        return self
    }
    
    override var contentInset: UIEdgeInsets {
        didSet {
            placeholderTextView.contentInset = contentInset
        }
    }
    
    func setText(_ text: String){
        self.text = text
        placeholderTextView.isHidden = !text.isEmpty
    }
    
    func textDidChange() {
        invalidateIntrinsicContentSize()
        placeholderTextView.isHidden = !text.isEmpty
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if size.height == UIView.noIntrinsicMetric {
            layoutManager.glyphRange(for: textContainer)
            size.height = layoutManager.usedRect(for: textContainer).height + textContainerInset.top + textContainerInset.bottom
        }
        return size
    }

}

