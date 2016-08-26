////
///  StreamableScreen.swift
//

public class StreamableScreen: Screen {
    let navigationBar = ElloNavigationBar()
    var navigationBarTopConstraint: NSLayoutConstraint!
    let streamContainer = UIView()

    convenience init(navigationItem: UINavigationItem) {
        self.init(frame: UIScreen.mainScreen().bounds)
        navigationBar.items = [navigationItem]
    }

    override func arrange() {
        addSubview(streamContainer)
        addSubview(navigationBar)

        navigationBar.snp_makeConstraints { make in
            let c = make.top.equalTo(self).constraint
            self.navigationBarTopConstraint = c.layoutConstraints.first!
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
        }
        streamContainer.snp_makeConstraints { make in
            make.edges.equalTo(self)
            streamContainer.frame = self.bounds
        }

        layoutIfNeeded()
    }
}
