////
///  AutoCompleteCellPresenter.swift
//

public struct AutoCompleteCellPresenter {

    public static func configure(cell: AutoCompleteCell, item: AutoCompleteItem) {
        cell.name.font = UIFont.defaultFont()
        cell.name.textColor = UIColor.whiteColor()
        cell.line.hidden = false
        cell.line.backgroundColor = UIColor.grey3()
        if let resultName = item.result.name {
            cell.name.text = item.type == .Emoji ? ":\(resultName):" : "@\(resultName)"
        }
        else {
            cell.name.text = ""
        }
        cell.selectionStyle = .None
        cell.avatar.setUserAvatarURL(item.result.url)
    }
}
