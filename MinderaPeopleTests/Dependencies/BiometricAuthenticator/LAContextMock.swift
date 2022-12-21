import LocalAuthentication
import Foundation

class LAContextMock: LAContext {
    var canEvaluatePolicyResponse = true
    var evaluatePolicyResponse = true
    
    // MARK: - canEvaluatePolicy vars
    private(set) var canEvaluatePolicyCalled = false
    private(set) var lastCanEvaluatePolicyLAPolicy: LAPolicy!
    
    // MARK: - evaluatePolicy vars
    private(set) var evaluatePolicyCalled = false
    private(set) var lastEvaluatePolicyLAPolicy: LAPolicy!
    
    override func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        canEvaluatePolicyCalled = true
        lastCanEvaluatePolicyLAPolicy = policy

        return canEvaluatePolicyResponse
    }
    
    override func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool {
        evaluatePolicyCalled = true
        lastEvaluatePolicyLAPolicy = policy

        return evaluatePolicyResponse
    }
}
