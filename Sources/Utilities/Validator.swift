////
///  Validator.swift
//

public extension String {

    func isValidEmail() -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(self)
        return result ?? false
    }

    func isValidUsername() -> Bool {
        let usernameRegEx = "^[_-]|[\\w-]{2,}$"
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        let result = usernameTest.evaluateWithObject(self)
        return result ?? false
    }

    func isValidPassword() -> Bool {
        return self.characters.count >= 8
    }

}
