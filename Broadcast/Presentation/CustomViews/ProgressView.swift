//
//  ProgressView.swift
//  Broadcast
//
//  Created by Piotr Suwara on 11/1/21.
//

import UIKit
import TinyConstraints
import RxSwift
import RxCocoa
import Lottie

protocol Progress {
    var progressText: String { get set }
    var totalProgress: Float { get set }// 0-1
}

class ProgressView : UIView, Progress {
    fileprivate let progressContainerView = UIView()
    
    fileprivate let progressSuccessContainerView = UIStackView()
    fileprivate let progressSuccessAnimation = AnimationView(animationAsset: .success)
    fileprivate let progressSuccessLabel = UILabel.tinyBody(LocalizedString.uploadCompleted)
    
    fileprivate let progressView = UIProgressView()
    fileprivate let progressLabel = UILabel.tinyBody()

    var progressText: String {
        set {
            progressLabel.text = newValue
        }
        get {
            return progressLabel.text ?? ""
        }
    }
    
    var totalProgress: Float {
        set {
            return progressView.progress = newValue
        }
        get {
            return progressView.progress
        }
    }
    
    var progressCompleteSuccess: Bool = false {
        didSet {
            progressSuccessContainerView.isHidden = !progressCompleteSuccess
            progressSuccessAnimation.play()
            progressView.isHidden = progressCompleteSuccess
            progressLabel.isHidden = progressCompleteSuccess
        }
    }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        configureViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureViews() {
        
        progressContainerView.backgroundColor = .clear
        progressContainerView.layer.cornerRadius = 8
        progressContainerView.layer.borderWidth = 1
        progressContainerView.layer.borderColor = UIColor.secondaryLightGrey.cgColor
        
        progressView.progressViewStyle = .bar
        progressView.progress = 0.0
        progressView.trackTintColor = .clear
        progressView.progressTintColor = .progressBarColor
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        
        progressLabel.textAlignment = .center
        
        progressSuccessContainerView.axis = .vertical
        progressSuccessContainerView.alignment = .center
        progressSuccessContainerView.distribution = .fill
        
        progressSuccessAnimation.loopMode = .playOnce
    }
    
    private func layoutViews() {
        /// Progress Container view wraps a simple border around the progress bar
        addSubview(progressContainerView)
        progressContainerView.addSubview(progressView)
        progressContainerView.centerXToSuperview()
        progressContainerView.widthToSuperview()
        progressContainerView.height(16)
        
        progressView.edgesToSuperview(insets: TinyEdgeInsets(top: 4, left: 5, bottom: 5, right: 5))
        
        addSubview(progressLabel)
        progressLabel.topToBottom(of: progressContainerView)
        progressLabel.widthToSuperview()
        progressLabel.height(16)
        
        addSubview(progressSuccessContainerView)
        progressSuccessContainerView.addArrangedSubview(progressSuccessAnimation)
        progressSuccessContainerView.addArrangedSubview(progressSuccessLabel)
    }
}

// MARK: RxSwift Extensions

extension Reactive where Base : ProgressView {
    /// Reactive wrapper for `Title Text` property.
    var text: Binder<String> {
        Binder(base) { progress, text in
            progress.progressText = text
        }
    }

    var totalProgress: Binder<Float> {
        Binder(base) { progress, totalProgress in
            progress.totalProgress = totalProgress
        }
    }
    
    var uploadSuccess: Binder<Bool> {
        Binder(base) { progress, uploadSuccess in
            progress.progressCompleteSuccess = uploadSuccess
        }
    }
}
