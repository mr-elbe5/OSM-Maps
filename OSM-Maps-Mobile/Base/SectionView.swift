/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class SectionView: UIView{
    
    init(){
        super.init(frame: .zero)
        backgroundColor = .tertiarySystemBackground
        setRoundedBorders()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ArrangedSectionView: SectionView{
    
    var stackView = UIStackView()
    
    override init(){
        super.init()
        stackView.axis = .vertical
        addSubviewFilling(stackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addArrangedSubview(_ subview: UIView){
        stackView.addArrangedSubview(subview)
    }
    
    func addSpacer(){
        stackView.addSpacer()
    }
    
    func removeAllArrangedSubviews(){
        stackView.removeAllArrangedSubviews()
    }
    
}

