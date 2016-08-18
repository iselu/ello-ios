////
///  ProfileViewController.swift
//

import FLAnimatedImage


public final class ProfileViewController: StreamableViewController {

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.Person) }
        set { self.tabBarItem = newValue }
    }

    var user: User?
    var headerItems: [StreamCellItem]?
    var responseConfig: ResponseConfig?
    var userParam: String!
    var coverImageHeightStart: CGFloat?
    let initialStreamKind: StreamKind
    var currentUserChangedNotification: NotificationObserver?
    var postChangedNotification: NotificationObserver?
    var relationshipChangedNotification: NotificationObserver?
    var deeplinkPath: String?
    var generator: ProfileGenerator?
    private var isSetup = false

    @IBOutlet weak var navigationBar: ElloNavigationBar!
    @IBOutlet weak var whiteSolidView: UIView!

    @IBOutlet weak var loaderView: InterpolatedLoadingView!
    @IBOutlet weak var coverImage: FLAnimatedImageView!
    @IBOutlet weak var relationshipControl: RelationshipControl!
    @IBOutlet weak var mentionButton: UIButton!
    @IBOutlet weak var hireButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var relationshipControlsView: UIView!
    let gradientLayer = CAGradientLayer()

    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
    @IBOutlet weak var whiteSolidTop: NSLayoutConstraint!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var gradientViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var relationshipControlsViewTopConstraint: NSLayoutConstraint!

    required public init(userParam: String, username: String? = nil) {
        self.userParam = userParam
        self.initialStreamKind = .UserStream(userParam: self.userParam)
        super.init(nibName: "ProfileViewController", bundle: nil)

        if let username = username {
            title = "@\(username)"
        }

        if self.user == nil {
            if let user = ElloLinkedStore.sharedInstance.getObject(self.userParam,
               inCollection: MappingType.UsersType.rawValue) as? User {
                self.user = user
            }
        }

        sharedInit()

        relationshipChangedNotification = NotificationObserver(notification: RelationshipChangedNotification) { [unowned self] user in
            if self.user?.id == user.id {
                self.updateRelationshipPriority(user.relationshipPriority)
            }
        }
    }

    // this should only be initialized this way for currentUser in tab nav
    required public init(user: User) {
        // this user must have the profile property assigned (since it is currentUser)
        self.user = user
        self.userParam = user.id
        self.initialStreamKind = .CurrentUserStream
        super.init(nibName: "ProfileViewController", bundle: nil)

        sharedInit()
        currentUserChangedNotification = NotificationObserver(notification: CurrentUserChangedNotification) { [unowned self] _ in
            self.updateCachedImages()
        }
    }

    private func sharedInit() {
        streamViewController.streamKind = initialStreamKind
        streamViewController.initialLoadClosure = { [unowned self] in self.loadProfile() }
        streamViewController.reloadClosure = { [unowned self] in self.reloadEntireProfile() }
        streamViewController.toggleClosure = { [unowned self] isGridView in self.toggleGrid(isGridView) }
    }

    deinit {
        currentUserChangedNotification?.removeObserver()
        currentUserChangedNotification = nil
        postChangedNotification?.removeObserver()
        postChangedNotification = nil
        relationshipChangedNotification?.removeObserver()
        relationshipChangedNotification = nil
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if user == nil {
            hireButton.enabled = false
            mentionButton.enabled = false
            editButton.enabled = false
            inviteButton.enabled = false
            relationshipControl.enabled = false
        }

        self.generator = ProfileGenerator(
            currentUser: self.currentUser,
            userParam: userParam,
            user: self.user,
            streamKind: self.streamViewController.streamKind,
            destination: self
        )
        view.clipsToBounds = true
        setupNavigationBar()
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
        relationshipControl.relationshipDelegate = streamViewController.dataSource.relationshipDelegate
        relationshipControl.style = .ProfileView

        setupGradient()

        if let user = user {
            updateUser(user)
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let ratio: CGFloat = ProfileHeaderCellSizeCalculator.ratio
        let height: CGFloat = view.frame.width / ratio
        let maxHeight = height - streamViewController.collectionView.contentOffset.y
        let constant = max(maxHeight, height)
        coverImageHeight.constant = constant
        whiteSolidTop.constant = max(maxHeight, 0)
        coverImageHeightStart = maxHeight

        gradientLayer.frame.size = gradientView.frame.size
    }

    override public func didSetCurrentUser() {
        generator?.currentUser = currentUser
        super.didSetCurrentUser()
    }

    override func showNavBars(scrollToBottom: Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationBar, visible: true, withConstraint: navigationBarTopConstraint)
        updateInsets()

        if scrollToBottom {
            self.scrollToBottom(streamViewController)
        }

        animate {
            self.updateGradientViewConstraint()
            self.relationshipControlsViewTopConstraint.constant = self.navigationBar.frame.height

            self.relationshipControlsView.frame.origin.y = self.relationshipControlsViewTopConstraint.constant
            self.gradientView.frame.origin.y = self.gradientViewTopConstraint.constant
        }
    }

    override func hideNavBars() {
        super.hideNavBars()
        hideNavBar(animated: true)
        updateInsets()

        animate {
            self.updateGradientViewConstraint()
            if self.user?.id == self.currentUser?.id && self.user?.id != nil {
                self.relationshipControlsViewTopConstraint.constant = -self.relationshipControlsView.frame.height
            }
            else {
                self.relationshipControlsViewTopConstraint.constant = 0
            }

            self.relationshipControlsView.frame.origin.y = self.relationshipControlsViewTopConstraint.constant
            self.gradientView.frame.origin.y = self.gradientViewTopConstraint.constant
        }
    }

    private func updateGradientViewConstraint() {
        let scrollView = streamViewController.collectionView
        let additional: CGFloat = navBarsVisible() ? navigationBar.frame.height : 0
        let constant: CGFloat

        if scrollView.contentOffset.y < 0 {
            constant = 0
        }
        else if scrollView.contentOffset.y > 45 {
            constant = -45
        }
        else {
            constant = -scrollView.contentOffset.y
        }
        gradientViewTopConstraint.constant = constant + additional
    }

    private func updateInsets() {
        updateInsets(navBar: relationshipControlsView, streamController: streamViewController)
    }

    private func hideNavBar(animated animated: Bool) {
        positionNavBar(navigationBar, visible: false, withConstraint: navigationBarTopConstraint, animated: animated)
    }

    // MARK : private

    private func loadProfile() {
        generator?.load()
    }

    private func reloadEntireProfile() {
        coverImage.pin_cancelImageDownload()
        coverImage.image = nil
        generator?.load(reload: true)
    }

    private func showUserLoadFailure() {
        let message = InterfaceString.GenericError
        let alertController = AlertViewController(message: message)
        let action = AlertAction(title: InterfaceString.OK, style: .Dark) { _ in
            self.navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(action)
        logPresentingAlert("ProfileViewController")
        presentViewController(alertController, animated: true, completion: nil)
    }

    private func setupNavigationBar() {
        navigationController?.navigationBarHidden = true
        navigationBar.items = [elloNavigationItem]
        if !isRootViewController() {
            let item = UIBarButtonItem.backChevronWithTarget(self, action: #selector(StreamableViewController.backTapped(_:)))
            self.elloNavigationItem.leftBarButtonItems = [item]
            self.elloNavigationItem.fixNavBarItemPadding()
        }
        assignRightButtons()
    }

    private func setupGradient() {
        gradientLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: gradientView.frame.width,
            height: gradientView.frame.height
        )
        gradientLayer.locations = [0, 0.8, 1]
        gradientLayer.colors = [
            UIColor.whiteColor().CGColor,
            UIColor.whiteColor().colorWithAlphaComponent(0.5).CGColor,
            UIColor.whiteColor().colorWithAlphaComponent(0).CGColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientView.layer.addSublayer(gradientLayer)
    }

    func assignRightButtons() {
        if let currentUser = currentUser where userParam == currentUser.id || userParam == "~\(currentUser.username)" {
            elloNavigationItem.rightBarButtonItems = [
                UIBarButtonItem(image: .Search, target: self, action: #selector(BaseElloViewController.searchButtonTapped)),
            ]
            return
        }

        guard let user = user else {
            elloNavigationItem.rightBarButtonItems = []
            return
        }

        if let currentUser = currentUser where user.id == currentUser.id {
            elloNavigationItem.rightBarButtonItems = []
            return
        }

        var rightBarButtonItems: [UIBarButtonItem] = []
        if user.hasSharingEnabled {
            rightBarButtonItems.append(UIBarButtonItem(image: .Share, target: self, action: #selector(ProfileViewController.sharePostTapped(_:))))
        }
        rightBarButtonItems.append(UIBarButtonItem(image: .Dots, target: self, action: #selector(ProfileViewController.moreButtonTapped)))
        elloNavigationItem.rightBarButtonItems = rightBarButtonItems
    }

    @IBAction func mentionButtonTapped() {
        guard let user = user else { return }

        createPost(text: "\(user.atName) ", fromController: self)
    }

    @IBAction func hireButtonTapped() {
        guard let user = user else { return }

        Tracker.sharedTracker.tappedHire(user)
        let vc = HireViewController(user: user)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func editButtonTapped() {
        onEditProfile()
    }

    @IBAction func inviteButtonTapped() {
        onInviteFriends()
    }

    func moreButtonTapped() {
        guard let user = user else { return }

        let userId = user.id
        let userAtName = user.atName
        let prevRelationshipPriority = user.relationshipPriority
        streamViewController.relationshipController?.launchBlockModal(userId, userAtName: userAtName, relationshipPriority: prevRelationshipPriority) { newRelationshipPriority in
            user.relationshipPriority = newRelationshipPriority
        }
    }

    func sharePostTapped(sourceView: UIView) {
        guard let user = user,
            shareLink = user.shareLink,
            shareURL = NSURL(string: shareLink)
        else { return }

        Tracker.sharedTracker.userShared(user)
        let activityVC = UIActivityViewController(activityItems: [shareURL], applicationActivities: [SafariActivity()])
        if UI_USER_INTERFACE_IDIOM() == .Phone {
            activityVC.modalPresentationStyle = .FullScreen
            logPresentingAlert(readableClassName() ?? "ProfileViewController")
            presentViewController(activityVC, animated: true) { }
        }
        else {
            activityVC.modalPresentationStyle = .Popover
            activityVC.popoverPresentationController?.sourceView = sourceView
            logPresentingAlert(readableClassName() ?? "ProfileViewController")
            presentViewController(activityVC, animated: true) { }
        }
    }

    func toggleGrid(isGridView: Bool) {
        generator?.toggleGrid()
    }

}

// MARK: Check for cached coverImage and avatar (only for currentUser)
extension ProfileViewController {
    public func cachedImage(key: CacheKey) -> UIImage? {
        guard user?.id == currentUser?.id else {
            return nil
        }
        return TemporaryCache.load(key)
    }

    public func updateCachedImages() {
        guard let cachedImage = cachedImage(.CoverImage) where coverImage != nil else {
            return
        }

        // this seemingly unecessary nil check is an attempt
        // to guard against crash #6:
        // https://www.crashlytics.com/ello/ios/apps/co.ello.ello/issues/55725749f505b5ccf00cf76d/sessions/55725654012a0001029d613137326264
        coverImage.image = cachedImage
    }

    public func updateUser(user: User) {
        hireButton.enabled = true
        mentionButton.enabled = true
        editButton.enabled = true
        inviteButton.enabled = true
        relationshipControl.enabled = true

        guard user.id == self.currentUser?.id else {
            hireButton.hidden = !user.isHireable
            mentionButton.hidden = user.isHireable
            relationshipControl.hidden = false
            editButton.hidden = true
            inviteButton.hidden = true
            return
        }

        // only update the avatar and coverImage assets if there is nothing
        // in the cache.  If images are in the cache, that implies that the
        // image could still be unprocessed, so don't set the avatar or
        // coverImage to the old, stale value.
        if cachedImage(.Avatar) == nil {
            self.currentUser?.avatar = user.avatar
        }

        if cachedImage(.CoverImage) == nil {
            self.currentUser?.coverImage = user.coverImage
        }

        elloNavigationItem.rightBarButtonItem = nil

        hireButton.hidden = true
        mentionButton.hidden = true
        relationshipControl.hidden = true
        editButton.hidden = false
        inviteButton.hidden = false
    }

    public func updateRelationshipPriority(relationshipPriority: RelationshipPriority) {
        relationshipControl.relationshipPriority = relationshipPriority
        self.user?.relationshipPriority = relationshipPriority
    }
}

// MARK: ProfileViewController: PostsTappedResponder
extension ProfileViewController: PostsTappedResponder {
    public func onPostsTapped() {
        let indexPath = NSIndexPath(forItem: 1, inSection: 0)
        guard streamViewController.dataSource.isValidIndexPath(indexPath) else { return }
        streamViewController.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
    }
}

// MARK: ProfileViewController: EditProfileResponder
extension ProfileViewController: EditProfileResponder {
    public func onEditProfile() {
        guard let settings = UIStoryboard(name: "Settings", bundle: .None).instantiateInitialViewController() as? SettingsContainerViewController else { return }
        settings.currentUser = currentUser
        navigationController?.pushViewController(settings, animated: true)
    }
}

// MARK: ProfileViewController: StreamViewDelegate
extension ProfileViewController {

    override public func streamViewDidScroll(scrollView: UIScrollView) {
        if let start = coverImageHeightStart {
            coverImageHeight.constant = max(start - scrollView.contentOffset.y, start)
            whiteSolidTop.constant = max(start - scrollView.contentOffset.y, 0)
        }

        updateGradientViewConstraint()

        super.streamViewDidScroll(scrollView)
    }
}

// MARK: ProfileViewController: StreamDestination
extension ProfileViewController:  StreamDestination {

    public var pagingEnabled: Bool {
        get { return streamViewController.pagingEnabled }
        set { streamViewController.pagingEnabled = newValue }
    }

    public func replacePlaceholder(type: StreamCellType.PlaceholderType, @autoclosure items: () -> [StreamCellItem], completion: ElloEmptyCompletion) {
        streamViewController.replacePlaceholder(type, with: items, completion: completion)
    }

    public func setPlaceholders(items: [StreamCellItem]) {
        streamViewController.clearForInitialLoad()
        streamViewController.appendUnsizedCellItems(items, withWidth: view.frame.width) { _ in }
        assignRightButtons()
    }

    public func setPrimaryJSONAble(jsonable: JSONAble) {
        guard let user = jsonable as? User else { return }

        self.user = user
        updateUser(user)

        relationshipControl.userId = user.id
        relationshipControl.userAtName = user.atName
        relationshipControl.relationshipPriority = user.relationshipPriority

        userParam = user.id
        title = user.atName
        if let cachedImage = cachedImage(.CoverImage) {
            coverImage.image = cachedImage
        }
        else if let
            cover = user.coverImageURL(viewsAdultContent: currentUser?.viewsAdultContent, animated: true),
            coverImage = coverImage
        {
            coverImage.pin_setImageFromURL(cover) { result in }
        }

        assignRightButtons()
        Tracker.sharedTracker.profileLoaded(user.atName ?? "(no name)")

    }

    public func setPagingConfig(responseConfig: ResponseConfig) {
        streamViewController.responseConfig = responseConfig
    }

    public func primaryJSONAbleNotFound() {
        if let deeplinkPath = self.deeplinkPath,
            deeplinkURL = NSURL(string: deeplinkPath)
        {
            UIApplication.sharedApplication().openURL(deeplinkURL)
            self.deeplinkPath = nil
            self.navigationController?.popViewControllerAnimated(true)
        }
        else {
            self.showUserLoadFailure()
        }
        self.streamViewController.doneLoading()
    }
}
