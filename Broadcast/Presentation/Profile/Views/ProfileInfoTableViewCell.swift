//
//  ProfileInfoTableViewCell.swift
//  Broadcast
//
//  Created by Piotr Suwara on 4/12/20.
//

import UIKit
import RxSwift

class ProfileInfoTableViewCell: UITableViewCell {
    static let identifier: String = "ProfileInfoTableViewCell"
    static let cellHeight: CGFloat = 100
    
    let containerStackView = UIStackView()
    let thumbnailContainerStackView = UIStackView()
    let thumbnailImageView = UIImageView()
    let changeThumbnailButton = UIButton.text(withTitle: LocalizedString.change)
    
    let subscribersContainerStackView = UIStackView()
    let subscribersCountLabel = UILabel.largeTitle()
    let subscribersTitleLabel = UILabel.body(LocalizedString.subscribers)

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        containerStackView.axis = .horizontal
        containerStackView.distribution = .fillEqually
        containerStackView.spacing = 5
        
        thumbnailContainerStackView.axis = .horizontal
        thumbnailContainerStackView.spacing = 10
        thumbnailContainerStackView.alignment = .leading
        
        subscribersContainerStackView.axis = .vertical
        subscribersContainerStackView.spacing = 5
        subscribersContainerStackView.alignment = .center
        subscribersContainerStackView.distribution = .fillProportionally
        
        contentView.addSubview(containerStackView)
        containerStackView.edgesToSuperview()
        
        containerStackView.addArrangedSubview(thumbnailContainerStackView)
        containerStackView.addArrangedSubview(subscribersContainerStackView)
        
        thumbnailContainerStackView.addArrangedSubview(thumbnailImageView)
        thumbnailContainerStackView.addArrangedSubview(changeThumbnailButton)
        
        subscribersContainerStackView.addArrangedSubview(subscribersCountLabel)
        subscribersContainerStackView.addArrangedSubview(subscribersTitleLabel)
        
        thumbnailImageView.contentMode = .scaleAspectFit
    }
    
    func configure(withProfileImageUrl profileImageUrl: URL?, subscribers: Int) {
        thumbnailImageView.sd_setImage(with: profileImageUrl)
        subscribersCountLabel.text = "\(subscribers)"
    }
}
