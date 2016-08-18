////
///  HireService.swift
//

import FutureKit


public class HireService {

    public init() {}

    public func hire(user user: User, body: String) -> Future<Void> {
        let promise = Promise<Void>()
        ElloProvider.shared.elloRequest(.Hire(userId: user.id, body: body),
            success: { data, responseConfig in
                promise.completeWithSuccess(Void())
            }
            failure: { error, _ in
                promise.completeWithFail(error)
            }
        )
        return p.future
    }

}
