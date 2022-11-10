//

import SwiftUI
import GoogleSignIn
import Firebase

class UserAuthModel: ObservableObject {
    func signIn(presentingController: UIViewController, completion: @escaping () -> ()) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config,
                                        presenting: presentingController) { user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let user = result?.user else { return }
                
                print(user.displayName ?? "Success")
                completion()
            }
        }
    }
    
    func signOut(){
        GIDSignIn.sharedInstance.signOut()
        try? Auth.auth().signOut()
    }
}

