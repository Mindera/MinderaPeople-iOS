public enum MinderaPeopleServiceError: Error, Equatable {
    public static func == (lhs: MinderaPeopleServiceError, rhs: MinderaPeopleServiceError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
    
    case noToken
    case invalidUrl
    case parseError
    case networkError
}