struct UserResponse: Decodable {
    let person: Person
    
    struct Person: Decodable {
        let id: Int
        let name: String
        let photo: String
        let email: String
    }
}
