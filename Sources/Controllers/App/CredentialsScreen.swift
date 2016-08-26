////
///  CredentialsScreen.swift
//

import SnapKit


public class CredentialsScreen: EmptyScreen {
    struct Size {
        static let backTopInset: CGFloat = 10
        static let titleTop: CGFloat = 110
        static let inset: CGFloat = 10
    }

    let scrollView = UIScrollView()
    var scrollViewWidth: Constraint!
    let backButton = UIButton()
    let titleLabel = ElloSizeableLabel()
    let gradientLayer = StartupGradientLayer()

    override public func updateConstraints() {
        super.updateConstraints()
        scrollViewWidth.updateOffset(frame.size.width)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        let maxDimension = max(layer.frame.size.width, layer.frame.size.height)
        let size = CGSize(width: maxDimension, height: maxDimension)
        gradientLayer.frame.size = size
        gradientLayer.position = layer.bounds.center
    }

    override func bindActions() {
        backButton.addTarget(self, action: #selector(backAction), forControlEvents: .TouchUpInside)
    }

    override func style() {
        super.style()
        backButton.setImages(.AngleBracket, degree: 180, white: true)
        backButton.contentMode = .Center
        titleLabel.font = UIFont.defaultBoldFont(18)
        titleLabel.textColor = .whiteColor()
    }

    override func arrange() {
        layer.masksToBounds = true
        layer.addSublayer(gradientLayer)

        super.arrange()

        addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(backButton)

        titleLabel.snp_makeConstraints { make in
            make.top.equalTo(scrollView).offset(Size.titleTop)
            make.leading.equalTo(scrollView).offset(Size.inset)
        }

        backButton.snp_makeConstraints { make in
            make.top.equalTo(scrollView).offset(Size.backTopInset)
            make.leading.equalTo(scrollView)
            make.size.equalTo(CGSize.minButton)
        }
    }

    public func backAction() {
    }
}
