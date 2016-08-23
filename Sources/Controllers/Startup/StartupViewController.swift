////
///  StartupViewController.swift
//

public class StartupViewController: UIViewController {
    var screen: StartupScreen { return self.view as! StartupScreen }

    override public func loadView() {
        self.view = StartupScreen()
    }

}
