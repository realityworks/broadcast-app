//
//  TipsView.swift
//  Broadcast
//
//  Created by Piotr Suwara on 29/12/20.
//

import UIKit
import RxSwift
import RxCocoa
import TinyConstraints

class TipsView : UIView {
    
    // MARK: UI Components
    private let verticalStackView = UIStackView()
    private let subTitleLabel = UILabel.bodyBold(LocalizedString.hotTips, textColor: UIColor.white)
    private let titleLabel = UILabel.extraLargeTitle(LocalizedString.greatContent, textColor: UIColor.white)
    private let closeButton = UIButton.text(withTitle: LocalizedString.close)
    private let containerView = UIView()
    
    struct TipData {
        let image: UIImage?
        let title: LocalizedString
        let description: LocalizedString
    }
    
    let tipData: [TipData] = [
        TipData(image: UIImage.iconCustomPortraitMode,
                title: LocalizedString.tip1Title,
                description: LocalizedString.tip1SubTitle),
        TipData(image: UIImage.iconCustomPortraitMode,
                title: LocalizedString.tip2Title,
                description: LocalizedString.tip2SubTitle),
        TipData(image: UIImage.iconCustomPortraitMode,
                title: LocalizedString.tip2Title,
                description: LocalizedString.tip2SubTitle)
    ]
    
    init() {
        super.init(frame: .zero)
        
        configureView()
        configureLayout()
    }
    
    private func configureView() {
        backgroundColor = UIColor.darkGrey.withAlphaComponent(0.94)
        
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .center
        
        containerView.backgroundColor = .darkGrey
        containerView.layer.cornerRadius = 16
        
        closeButton.setTitleColor(.primaryLightGrey, for: .normal)
    }
    
    private func configureLayout() {
        addSubview(containerView)
        containerView.addSubview(verticalStackView)
        
        containerView.width(315)
        containerView.centerInSuperview()
        
        verticalStackView.edgesToSuperview(insets: TinyEdgeInsets(top: 32, left: 24, bottom: 32, right: 24))
        
        verticalStackView.addArrangedSubview(subTitleLabel)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addSpace(16)
        tipData.forEach { tipData in
            verticalStackView.addSpace(40)
            verticalStackView.addArrangedSubview(UIImageView(image: tipData.image))
            verticalStackView.addArrangedSubview(UILabel.largeBodyBold(tipData.title))
            
            let descriptionLabel = UILabel.smallBody(tipData.description)
            descriptionLabel.numberOfLines = 0
            descriptionLabel.lineBreakMode = .byWordWrapping
            
            verticalStackView.addArrangedSubview(descriptionLabel)
        }
        
        verticalStackView.addSpace(30)
        verticalStackView.addArrangedSubview(closeButton)
        closeButton.width(66)
        closeButton.height(30)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


