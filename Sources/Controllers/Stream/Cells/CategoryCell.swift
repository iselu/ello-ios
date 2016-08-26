////
///  CategoryCell.swift
//

import SnapKit

public class CategoryCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryCell"

    enum Highlight {
        case Gray
        case White

        var color: UIColor {
            switch self {
            case .Gray: return .greyF2()
            case .White: return .whiteColor()
            }
        }
    }

    struct Size {
        static let sideMargins: CGFloat = 15
        static let lineHeight: CGFloat = 1
    }

    var title: String {
        set { label.text = newValue }
        get { return label.text ?? "" }
    }
    var highlight: Highlight = .White {
        didSet {
            colorFillView.backgroundColor = highlight.color
        }
    }

    private let label = ElloLabel()
    private let colorFillView = UIView()

    override public init(frame: CGRect) {
        super.init(frame: frame)

        arrange()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func arrange() {
        contentView.addSubview(colorFillView)
        contentView.addSubview(label)

        colorFillView.snp_makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-Size.lineHeight)
        }
        label.snp_makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView).offset(Size.sideMargins)
        }
    }
}
