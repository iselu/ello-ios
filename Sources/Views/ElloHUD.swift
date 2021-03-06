////
///  ElloHUD.swift
//

import MBProgressHUD

class ElloHUD: NSObject {

    class func showLoadingHudInView(view: UIView) -> MBProgressHUD? {
        var existingHub: MBProgressHUD?
        for subview in view.subviews {
            if let found = subview as? MBProgressHUD {
                existingHub = found
                break
            }
        }
        if let existingHub = existingHub {
            return existingHub
        }

        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.opacity = 0.0

        let elloLogo = ElloLogoView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        elloLogo.animateLogo()
        hud.customView = elloLogo
        hud.mode = .CustomView
        hud.removeFromSuperViewOnHide = true
        return hud
    }

    class func hideLoadingHudInView(view: UIView) {
        MBProgressHUD.hideHUDForView(view, animated: true)
    }

}
