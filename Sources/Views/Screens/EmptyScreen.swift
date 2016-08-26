////
///  EmptyScreen.swift
//

public class EmptyScreen: Screen {
    var blackBar = BlackBar()

    override func arrange() {
        addSubview(blackBar)

        blackBar.snp_makeConstraints { make in
            make.leading.trailing.top.equalTo(self)
        }
    }
}
