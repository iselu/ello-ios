////
///  StartupScreen.swift
//

import SnapKit


public class StartupScreen: EmptyScreen {
    struct Size {
        static let topLogoOffset: CGFloat = 100
        static let bottomLogoOffset: CGFloat = 90
        static let logoSize: CGFloat = 250
        static let buttonInset: CGFloat = 10
        static let buttonHeight: CGFloat = 50
        static let maxButtonWidth: CGFloat = 414 - 2 * buttonInset
    }

    weak var delegate: StartupDelegate?

    let logoImage = FLAnimatedImageView()
    let signUpButton = GreenElloButton()
    let loginButton = RoundedElloButton()
    // let gradientLayer = StartupGradientLayer()

    override func style() {
        loginButton.borderColor = .greyA()
        loginButton.cornerRadius = 5
        loginButton.setTitleColor(.greyA(), forState: .Normal)
        loginButton.setTitleColor(.blackColor(), forState: .Highlighted)

        // layer.addSublayer(gradientLayer)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        // let size = max(layer.frame.size.width, layer.frame.size.height)
        // gradientLayer.frame.size = CGSize(width: size, height: size)
        // gradientLayer.position = layer.frame.center
    }

    override func setText() {
        if let resource = NSBundle.mainBundle().pathForResource("ello-crazy-logo", ofType: "gif") {
            let data = NSData(contentsOfFile: resource)
            let image = FLAnimatedImage(animatedGIFData: data)
            logoImage.animatedImage = image
        }
        signUpButton.setTitle(InterfaceString.Startup.SignUp, forState: .Normal)
        loginButton.setTitle(InterfaceString.Startup.Login, forState: .Normal)
    }

    override func bindActions() {
        signUpButton.addTarget(self, action: #selector(signUpAction), forControlEvents: .TouchUpInside)
        loginButton.addTarget(self, action: #selector(loginAction), forControlEvents: .TouchUpInside)
    }

    override func arrange() {
        super.arrange()

        addSubview(logoImage)
        addSubview(signUpButton)
        addSubview(loginButton)

        logoImage.snp_makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(blackBar.snp_bottom).offset(Size.topLogoOffset).priorityMedium()
            make.size.equalTo(CGSize(width: Size.logoSize, height: Size.logoSize))
            make.top.greaterThanOrEqualTo(blackBar.snp_bottom).priorityRequired()
            make.bottom.lessThanOrEqualTo(signUpButton.snp_top).offset(-Size.bottomLogoOffset).priorityRequired()
        }

        loginButton.snp_makeConstraints { make in
            make.bottom.equalTo(self).offset(-Size.buttonInset)
            make.centerX.equalTo(self)
            make.height.equalTo(Size.buttonHeight)
            make.width.equalTo(self).offset(-2 * Size.buttonInset).priorityMedium()
            make.width.lessThanOrEqualTo(Size.maxButtonWidth).priorityRequired()
        }

        signUpButton.snp_makeConstraints { make in
            make.centerX.width.height.equalTo(loginButton)
            make.bottom.equalTo(loginButton.snp_top).offset(-Size.buttonInset)
        }
    }
}

extension StartupScreen {
    @objc func signUpAction() {
        delegate?.signUpAction()
    }

    @objc func loginAction() {
        delegate?.loginAction()
    }
}

extension StartupScreenProtocol {}
