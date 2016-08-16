////
///  AvatarButton.swift
//

public class AvatarButton: UIButton {
    // for specs; ensure the correct URL is assigned
    public var imageURL: NSURL?

    var starIcon = UIImageView()
    var starIconHidden: Bool {
        get { return true }
        set { }
    }
    let starSize = CGSize(width: 15, height: 15)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        let star = InterfaceImage.Star.selectedImage
        starIcon.image = star
        starIcon.frame.size = starSize
        starIcon.hidden = true
        addSubview(starIcon)
        clipsToBounds = false
    }

    func setUser(user: User?) {
        setUserAvatarURL(user?.avatarURL())

        starIcon.hidden = starIconHidden || (user?.relationshipPriority != .Starred)
    }

    func setUserAvatarURL(url: NSURL?) {
        self.imageURL = url
        self.setDefaultImage()

        starIcon.hidden = starIconHidden

        if let url = url {
            self.pin_setImageFromURL(url) { result in
                if result.image != nil {
                    if result.resultType != .MemoryCache {
                        self.alpha = 0
                        UIView.animateWithDuration(0.3,
                            delay:0.0,
                            options:UIViewAnimationOptions.CurveLinear,
                            animations: {
                                self.alpha = 1.0
                            }, completion: nil)
                    }
                    else {
                        self.alpha = 1.0
                    }
                }
            }
        }
    }

    func setDefaultImage() {
        pin_cancelImageDownload()
        setImage(nil, forState: .Normal)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = self.imageView {
            imageView.layer.cornerRadius = imageView.bounds.size.height / CGFloat(2)
        }

        let scale = frame.width / 60
        starIcon.frame.size = CGSize(width: scale * starSize.width, height: scale * starSize.height)
        starIcon.center = CGPoint(x: frame.width, y: 0)
    }

}
