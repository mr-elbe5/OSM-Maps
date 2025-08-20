/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

protocol RadioGroupDelegate{
    func valueDidChangeTo(idx: Int, value: String)
}

class RadioGroup: NSView{
    
    var selectedIndex : Int = -1
    var selectedValue : String{
        if selectedIndex != -1{
            return radioViews[selectedIndex].title
        }
        return ""
    }
    
    var radioViews = Array<NSButton>()
    var stackView = NSStackView()
    
    var delegate: RadioGroupDelegate? = nil
    
    init(){
        super.init(frame: .zero)
        setRoundedBorders()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(values: Array<String>, includingNobody: Bool = false){
        stackView.orientation = .vertical
        stackView.alignment = .leading
        addSubviewFilling(stackView)
        if includingNobody{
            let radioView = NSButton(radioButtonWithTitle: "nobody", target: self, action: #selector(radioIsSelected))
            radioViews.append(radioView)
            stackView.addArrangedSubview(radioView)
        }
        for i in 0..<values.count{
            let radioView = NSButton(radioButtonWithTitle: values[i], target: self, action: #selector(radioIsSelected))
            radioViews.append(radioView)
            stackView.addArrangedSubview(radioView)
        }
    }
    
    func select(index: Int){
        selectedIndex = index
        for i in 0..<radioViews.count{
            let radioView = radioViews[i]
            radioView.state = i == index ? .on : .off
        }
    }
    
    func select(title: String){
        for i in 0..<radioViews.count{
            let radioView = radioViews[i]
            if radioView.title == title{
                radioView.state = .on
                selectedIndex = i
            }
            else{
                radioView.state =  .off
            }
        }
    }
    
    @objc func radioIsSelected(sender: AnyObject) {
        if let selectedRadio = sender as? NSButton{
            for i in 0..<radioViews.count{
                let radioView = radioViews[i]
                if radioView == selectedRadio{
                    radioView.state = .on
                    selectedIndex = i
                }
                else{
                    radioView.state = .off
                }
            }
            delegate?.valueDidChangeTo(idx: selectedIndex, value: selectedValue)
        }
    }
    
}


