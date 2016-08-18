////
///  HireViewController.swift
//

public class HireViewController: BaseElloViewController {
    var user: User
    var screen: HireScreen { return self.view as! HireScreen }
    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?

    required public init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)

        title = "Email \(user.atName)"
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        elloNavigationItem.title = title

        let leftItem = UIBarButtonItem.backChevronWithTarget(self, action: #selector(backTapped(_:)))
        elloNavigationItem.leftBarButtonItems = [leftItem]
        elloNavigationItem.fixNavBarItemPadding()

        let screen = HireScreen(navigationItem: elloNavigationItem)
        screen.delegate = self
        screen.recipient = user.displayName
        self.view = screen
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        elloTabBarController?.tabBarHidden = false

        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: self.keyboardWillShow)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: self.keyboardWillHide)
        screen.toggleKeyboard(visible: Keyboard.shared.active)
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        keyboardWillShowObserver?.removeObserver()
        keyboardWillShowObserver = nil
        keyboardWillHideObserver?.removeObserver()
        keyboardWillHideObserver = nil
    }

    public func keyboardWillShow(keyboard: Keyboard) {
        screen.toggleKeyboard(visible: true)
    }

    public func keyboardWillHide(keyboard: Keyboard) {
        screen.toggleKeyboard(visible: false)
    }

}

extension HireViewController: HireDelegate {
    func submit(body body: String) {
        self.screen.showSuccess()
        let hireSuccess = after(2) {
            self.navigationController?.popViewControllerAnimated(true)
            delay(DefaultAppleAnimationDuration) {
                self.screen.hideSuccess()
            }
        }
        // this ensures a minimum 3 second display of the success screen
        delay(3) {
            hireSuccess()
        }

        HireService().hire(user: user, body: body)
            .onSuccess { _ in
                Tracker.sharedTracker.hiredUser(self.user)
                hireSuccess()
            }
            .onFail { error in
                self.screen.hideSuccess()
                let alertController = AlertViewController(error: InterfaceString.GenericError)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
    }
}
