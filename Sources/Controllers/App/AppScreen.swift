////
///  AppScreen.swift
//

import SnapKit


public class AppScreen: EmptyScreen {
    struct Size {
        static let topLogoOffset: CGFloat = 210
    }

    private var logoImage = ElloLogoView()

    override func arrange() {
        super.arrange()
        addSubview(logoImage)

        logoImage.snp_makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self.snp_top).offset(Size.topLogoOffset).priorityMedium()
        }
    }

    func animateLogo() {
        logoImage.animateLogo()
    }

    func stopAnimatingLogo() {
        logoImage.stopAnimatingLogo()
    }

    func hide() {
        logoImage.alpha = 0
    }

}
