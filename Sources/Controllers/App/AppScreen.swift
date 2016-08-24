////
///  AppScreen.swift
//

import SnapKit


public class AppScreen: EmptyScreen {
    private var logoImage = ElloLogoView()

    override func arrange() {
        super.arrange()
        addSubview(logoImage)

        logoImage.snp_makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
        }
    }
}

extension AppScreen: AppScreenProtocol {
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