////
///  ElloScreen.swift
//

public class ElloScreen: UIView {
    let navigationBar = ElloNavigationBar()
    var navigationBarTopConstraint: NSLayoutConstraint!
    let streamContainer = UIView()

    public required init(navigationItem: UINavigationItem) {
        navigationBar.items = [navigationItem]
        super.init(frame: UIScreen.mainScreen().bounds)

        screenInit()
        style()
        bindActions()
        setText()
        arrange()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func screenInit() {}

    func style() {
        backgroundColor = .whiteColor()
    }

    func bindActions() {}
    func setText() {}

    func arrange() {
        addSubview(streamContainer)
        addSubview(navigationBar)

        navigationBar.snp_makeConstraints { make in
            let c = make.top.equalTo(self).constraint
            self.navigationBarTopConstraint = c.layoutConstraints.first!
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
        streamContainer.snp_makeConstraints { make in
            make.edges.equalTo(self)
            streamContainer.frame = self.bounds
        }

        layoutIfNeeded()
    }
}
