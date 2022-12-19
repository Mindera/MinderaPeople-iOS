import Foundation

public struct User: Equatable {
    let id: Int
    let name: String
    let photo: String
    let email: String
}

#if DEBUG
extension User {
    static func stub(
        id: Int = 12345,
        name: String = "Jack Nilson",
        photo: String = "https://e1.pngegg.com/pngimages/49/181/png-clipart-lego-heads-ep-lego-head.png",
        email: String = "jack.nilson@mindera.com"
    ) -> User {
        .init(
            id: id,
            name: name,
            photo: photo,
            email: email
        )
    }
}
#endif
