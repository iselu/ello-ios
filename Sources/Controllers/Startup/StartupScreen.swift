////
///  StartupScreen.swift
//

import SnapKit


public class StartupScreen: EmptyScreen {
    struct Size {
        static let topLogoOffset: CGFloat = 245
        static let logoSize: CGFloat = 250
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
            make.centerY.equalTo(self.snp_top).offset(Size.topLogoOffset).priorityMedium()
            make.size.equalTo(CGSize(width: Size.logoSize, height: Size.logoSize))
            make.bottom.lessThanOrEqualTo(signUpButton.snp_top).offset(15).priorityHigh()
        }

        loginButton.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(self).inset(10)
            make.height.equalTo(50)
        }

        signUpButton.snp_makeConstraints { make in
            make.left.right.equalTo(self).inset(10)
            make.bottom.equalTo(loginButton.snp_top).offset(-10)
            make.height.equalTo(loginButton.snp_height)
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
