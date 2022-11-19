import Foundation

public struct User: Equatable {
    let uid: String
    let refreshToken: String?
    let isAnonymous: Bool
    let photoURL: URL?
    let phoneNumber: String?
    let email: String?
    let displayName: String?
    let isEmailVerified: Bool
}

extension User {
    static func stub(
        uid: String = UUID().uuidString,
        refreshToken: String? = nil,
        isAnonymous: Bool = false,
        photoURL: URL? = URL(string: "https://e1.pngegg.com/pngimages/49/181/png-clipart-lego-heads-ep-lego-head.png"),
        phoneNumber: String? = "919998877",
        email: String? = "john.doe@mindera.com",
        displayName: String? = "John Doe",
        isEmailVerified: Bool = true
    ) -> User {
        .init(
            uid: uid,
            refreshToken: refreshToken,
            isAnonymous: isAnonymous,
            photoURL: photoURL,
            phoneNumber: phoneNumber,
            email: email,
            displayName: displayName,
            isEmailVerified: isEmailVerified
        )
    }
}
