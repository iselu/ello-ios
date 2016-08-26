////
///  BlockUserModalScreen.swift
//

import SnapKit

public protocol BlockUserModalDelegate {
    func updateRelationship(newRelationship: RelationshipPriority)
    func flagTapped()
    func closeModal()
}

public class BlockUserModalScreen: UIView {
    private let backgroundButton = UIButton()
    private let modalView = UIScrollView()
    private let innerWidthView = UIView()
    private let closeButton = UIButton()
    private let titleLabel = UILabel()
    private let muteButton = WhiteElloButton()
    private let muteLabel = UILabel()
    private let blockButton = WhiteElloButton()
    private let blockLabel = UILabel()
    private let flagButton = WhiteElloButton()
    private let flagLabel = UILabel()
    private var scrollHeight: Constraint?
    private var scrollWidth: Constraint?

    private var delegate: BlockUserModalDelegate? {
        get { return nextResponder() as? BlockUserModalDelegate }
    }

    private var scrollWidthConstant: CGFloat = 0 {
        didSet {
            if let scrollWidth = scrollWidth
                where scrollWidthConstant != oldValue {
                scrollWidth.updateOffset(scrollWidthConstant)
            }
        }
    }
    private var scrollHeightConstant: CGFloat = 0 {
        didSet {
            if let scrollHeight = scrollHeight
                where scrollHeightConstant != oldValue {
                scrollHeight.updateOffset(scrollHeightConstant)
            }
        }
    }

    required public init(config: BlockUserModalConfig) {
        super.init(frame: .zero)

        style()
        bindActions()
        setText()
        arrange()
        setDetails(userAtName: config.userAtName, relationshipPriority: config.relationshipPriority)
    }

    required public override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setDetails(userAtName userAtName: String, relationshipPriority: RelationshipPriority) {
        let titleText: String
        switch relationshipPriority {
        case .Mute: titleText = String(format: InterfaceString.Relationship.UnmuteAlertTemplate, userAtName)
        case .Block: titleText = String(format: InterfaceString.Relationship.BlockAlertTemplate, userAtName)
        default: titleText = String(format: InterfaceString.Relationship.MuteAlertTemplate, userAtName)
        }

        let muteText = String(format: InterfaceString.Relationship.MuteWarningTemplate, userAtName, userAtName)
        let blockText = String(format: InterfaceString.Relationship.BlockWarningTemplate, userAtName)
        let flagText = String(format: InterfaceString.Relationship.BlockWarningTemplate, userAtName)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let labels: [(UILabel, String)] = [(titleLabel, titleText), (muteLabel, muteText), (blockLabel, blockText), (flagLabel, flagText)]
        for (label, text) in labels {
            label.attributedText = NSAttributedString(string: text, attributes: [
                NSParagraphStyleAttributeName: paragraphStyle
            ])
        }

        resetButtons()
        switch relationshipPriority {
        case .Mute:
            muteButton.selected = true
        case .Block:
            blockButton.selected = true
        default:
            break
        }
    }

    private func resetButtons() {
        muteButton.selected = false
        blockButton.selected = false
    }
}

// MARK: STYLING

extension BlockUserModalScreen {
    private func style() {
        backgroundButton.backgroundColor = UIColor.modalBackground()
        modalView.backgroundColor = UIColor.redColor()
        for label in [titleLabel, muteLabel, blockLabel, flagLabel] {
            styleLabel(label)
        }
        for button in [muteButton, blockButton, flagButton] {
            styleButton(button)
        }
        closeButton.setImages(.X, white: true)
    }

    private func styleLabel(label: UILabel) {
        label.font = .defaultFont()
        label.textColor = .whiteColor()
        label.lineBreakMode = .ByWordWrapping
        label.numberOfLines = 0
    }

    private func styleButton(button: UIButton) {
        button.backgroundColor = .whiteColor()
        button.titleLabel?.font = .defaultFont()
        button.titleLabel?.textColor = .whiteColor()
    }
}

extension BlockUserModalScreen {
    private func bindActions() {
        backgroundButton.addTarget(self, action: #selector(closeModal), forControlEvents: .TouchUpInside)
        blockButton.addTarget(self, action: #selector(blockTapped(_:)), forControlEvents: .TouchUpInside)
        muteButton.addTarget(self, action: #selector(muteTapped(_:)), forControlEvents: .TouchUpInside)
        flagButton.addTarget(self, action: #selector(flagTapped), forControlEvents: .TouchUpInside)
        closeButton.addTarget(self, action: #selector(closeModal), forControlEvents: .TouchUpInside)
    }

// MARK: ACTIONS

    func blockTapped(sender: UIButton) {
        let relationshipPriority: RelationshipPriority
        if sender.selected == true {
            relationshipPriority = .Inactive
        } else {
            relationshipPriority = .Block
        }
        delegate?.updateRelationship(relationshipPriority)
    }

    func muteTapped(sender: UIButton) {
        let relationshipPriority: RelationshipPriority
        if sender.selected == true {
            relationshipPriority = .Inactive
        } else {
            relationshipPriority = .Mute
        }
        delegate?.updateRelationship(relationshipPriority)
    }

    func flagTapped() {
        delegate?.flagTapped()
    }

    func closeModal() {
        delegate?.closeModal()
    }
}

extension BlockUserModalScreen {
    private func setText() {
        muteButton.setTitle(InterfaceString.Relationship.MuteButton, forState: UIControlState.Normal)
        blockButton.setTitle(InterfaceString.Relationship.BlockButton, forState: UIControlState.Normal)
        flagButton.setTitle(InterfaceString.Relationship.FlagButton, forState: UIControlState.Normal)
    }
}

extension BlockUserModalScreen {
    override public func updateConstraints() {
        super.updateConstraints()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        scrollWidthConstant = modalView.frame.size.width - 40
        scrollHeightConstant = modalView.contentSize.height

        titleLabel.preferredMaxLayoutWidth = scrollWidthConstant
        muteLabel.preferredMaxLayoutWidth = scrollWidthConstant
        blockLabel.preferredMaxLayoutWidth = scrollWidthConstant
        flagLabel.preferredMaxLayoutWidth = scrollWidthConstant
    }

    private func arrange() {
        addSubview(backgroundButton)
        addSubview(modalView)

        let modalViews: [UIView] = [innerWidthView, closeButton, titleLabel, muteButton, muteLabel, blockButton, blockLabel, flagButton, flagLabel]
        for view in modalViews {
            modalView.addSubview(view)
        }
        innerWidthView.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)

        backgroundButton.snp_makeConstraints { make in
            make.edges.equalTo(self)
        }

        modalView.snp_makeConstraints { make in
            make.leading.equalTo(self).offset(10)
            make.trailing.equalTo(self).offset(-10)
            make.top.equalTo(self).offset(50)
            make.bottom.equalTo(innerWidthView)
            self.scrollHeight = make.height.equalTo(scrollHeightConstant).priorityMedium().constraint
            make.bottom.lessThanOrEqualTo(self.snp_bottom).priorityHigh()
        }

        innerWidthView.snp_makeConstraints { make in
            make.top.equalTo(modalView).offset(20).priorityHigh()
            make.bottom.equalTo(flagLabel).offset(20).priorityHigh()
            make.leading.equalTo(modalView).offset(20).priorityHigh()
            make.trailing.equalTo(modalView).offset(-20).priorityHigh()
            self.scrollWidth = make.width.equalTo(scrollWidthConstant).priorityHigh().constraint
        }

        closeButton.snp_makeConstraints { make in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.top.equalTo(modalView).offset(10)
            make.trailing.equalTo(modalView).offset(-10)
        }

        titleLabel.snp_makeConstraints { make in
            make.top.equalTo(innerWidthView)
            make.leading.equalTo(innerWidthView)
            make.trailing.equalTo(closeButton.snp_leading).offset(-10)
        }

        muteButton.snp_makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom).offset(40)
            make.leading.equalTo(innerWidthView)
            make.trailing.equalTo(innerWidthView)
            make.height.equalTo(50)
        }

        muteLabel.snp_makeConstraints { make in
            make.top.equalTo(muteButton.snp_bottom).offset(20)
            make.leading.equalTo(innerWidthView)
            make.trailing.equalTo(innerWidthView)
        }

        blockButton.snp_makeConstraints { make in
            make.top.equalTo(muteLabel.snp_bottom).offset(40)
            make.leading.equalTo(innerWidthView)
            make.trailing.equalTo(innerWidthView)
            make.height.equalTo(50)
        }

        blockLabel.snp_makeConstraints { make in
            make.top.equalTo(blockButton.snp_bottom).offset(20)
            make.leading.equalTo(innerWidthView)
            make.trailing.equalTo(innerWidthView)
        }

        flagButton.snp_makeConstraints { make in
            make.top.equalTo(blockLabel.snp_bottom).offset(40)
            make.leading.equalTo(innerWidthView)
            make.trailing.equalTo(innerWidthView)
            make.height.equalTo(50)
        }

        flagLabel.snp_makeConstraints { make in
            make.top.equalTo(flagButton.snp_bottom).offset(20)
            make.leading.equalTo(innerWidthView)
            make.trailing.equalTo(innerWidthView)
        }
    }

}
