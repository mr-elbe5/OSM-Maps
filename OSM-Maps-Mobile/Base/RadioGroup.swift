/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol RadioGroupDelegate{
    func valueDidChangeTo(idx: Int, value: String)
}

class RadioGroup: UIView{
    
    var selectedIndex : Int = -1
    var selectedValue : String{
        if selectedIndex != -1{
            return radioViews[selectedIndex].title
        }
        return ""
    }
    
    var radioViews = Array<RadioGroupButton>()
    var stackView = UIStackView()
    
    var delegate: RadioGroupDelegate? = nil
    
    init(){
        super.init(frame: .zero)
        backgroundColor = .tertiarySystemBackground
        setRoundedBorders()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(values: Array<String>, includingNobody: Bool = false){
        stackView.axis = .vertical
        stackView.alignment = .leading
        addSubviewFilling(stackView, insets: .zero)
        if includingNobody{
            let radioView = RadioGroupButton()
            radioViews.append(radioView)
            radioView.setup(title: "nobody".localize(), index: -1)
            radioView.delegate = self
            stackView.addArrangedSubview(radioView)
        }
        for i in 0..<values.count{
            let radioView = RadioGroupButton()
            radioViews.append(radioView)
            radioView.setup(title: values[i], index: i)
            radioView.delegate = self
            stackView.addArrangedSubview(radioView)
        }
    }
    
    func select(index: Int){
        selectedIndex = index
        for radioView in radioViews{
            radioView.isOn = radioView.index == index
        }
    }
    
}

extension RadioGroup: RadioGroupButtonDelegate{
    
    func radioIsSelected(index: Int) {
        selectedIndex = index
        for radioView in radioViews{
            radioView.isOn = radioView.index == index
        }
        delegate?.valueDidChangeTo(idx: selectedIndex, value: selectedValue)
    }
    
}
