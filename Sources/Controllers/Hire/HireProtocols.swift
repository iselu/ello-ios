////
///  HireProtocols.swift
//

protocol HireDelegate: class {
    func submit(body body: String)
}

protocol HireScreenProtocol: class {
    func toggleKeyboard(visible visible: Bool)
    func showSuccess()
    func hideSuccess()
}
