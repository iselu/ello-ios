////
///  Screen.swift
//

public class Screen: UIView {

    public required init(frame: CGRect) {
        super.init(frame)

        backgroundColor = .whiteColor()

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
    func style() {}
    func bindActions() {}
    func setText() {}
    func arrange() {}

}
