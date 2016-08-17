////
///  ProfileViewButtons.swift
//

public class ProfileButton: RoundedElloButton {
    override public func sharedSetup() {
        super.sharedSetup()
        setTitle("", forState: .Disabled)
    }

    override func updateStyle() {
        super.updateStyle()
        if highlighted {
            backgroundColor = .grey4D()
        }
        else if enabled {
            backgroundColor = .clearColor()
        }
        else {
            backgroundColor = .greyF2()
        }
    }
}

public class ElloMentionButton: ProfileButton {
    override public func sharedSetup() {
        super.sharedSetup()
        setTitle(InterfaceString.Profile.Mention, forState: .Normal)
    }
}

public class ElloInviteButton: ProfileButton {
    override public func sharedSetup() {
        super.sharedSetup()
        setTitle(InterfaceString.Profile.Invite, forState: .Normal)
    }
}

public class ElloEditProfileButton: ProfileButton {
    override public func sharedSetup() {
        super.sharedSetup()
        setTitle(InterfaceString.Profile.EditProfile, forState: .Normal)
    }
}
