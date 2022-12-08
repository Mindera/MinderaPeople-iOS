import LocalAuthentication
import Foundation

class LAContextMock: LAContext {
    var canEvaluatePolicyResponse = true
    var evaluatePolicyResponse = true
    
    override func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        return canEvaluatePolicyResponse
    }
    
    override func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool {
        return evaluatePolicyResponse
    }
}
