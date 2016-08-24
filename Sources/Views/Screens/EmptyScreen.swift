////
///  EmptyScreen.swift
//

public class EmptyScreen: Screen {
    private var blackBar = BlackBar()

    override func arrange() {
        addSubview(blackBar)

        blackBar.snp_makeConstraints { make in
            make.left.right.top.equalTo(self)
        }
    }
}
