////
///  Validator.swift
//

public struct Validator {

    public static func hasValidSignUpCredentials(email email: String, username: String, password: String) -> Bool {
        return isValidEmail(email) && isValidUsername(username) && isValidPassword(password)
    }

    public static func invalidSignUpUsernameReason(username: String) -> String? {
        if username.isEmpty {
            return InterfaceString.Validator.UsernameRequired
        }
        else if !isValidUsername(username) {
            return InterfaceString.Validator.UsernameInvalid
        }
        return nil
    }

    public static func invalidSignUpEmailReason(email: String) -> String? {
        if email.isEmpty {
            return InterfaceString.Validator.EmailRequired
        }
        else if !isValidEmail(email) {
            return InterfaceString.Validator.EmailInvalid
        }
        return nil
    }

    public static func invalidSignUpPasswordReason(password: String) -> String? {
        if password.isEmpty {
            return InterfaceString.Validator.PasswordRequired
        }
        else if !isValidPassword(password) {
            return InterfaceString.Validator.PasswordInvalid
        }
        return nil
    }

    public static func hasValidLoginCredentials(username username: String, password: String) -> Bool {
        return (isValidEmail(username) || isValidUsername(username)) && isValidPassword(password)
    }

    public static func invalidLoginCredentialsReason(username username: String, password: String) -> String? {
        if username.isEmpty {
            return InterfaceString.Validator.UsernameRequired
        }
        else if !(isValidUsername(username) || isValidEmail(username)) {
            return InterfaceString.Validator.SignInInvalid
        }
        else if password.isEmpty {
            return InterfaceString.Validator.PasswordRequired
        }
        else if !isValidPassword(password) {
            return InterfaceString.Validator.PasswordInvalid
        }
        return nil
    }

    public static func isValidEmail(string: String) -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(string)
        return result ?? false
    }

    public static func isValidUsername(string: String) -> Bool {
        let usernameRegEx = "^[_-]|[\\w-]{2,}$"
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        let result = usernameTest.evaluateWithObject(string)
        return result ?? false
    }

    public static func isValidPassword(string: String) -> Bool {
        return string.characters.count >= 8
    }

}
