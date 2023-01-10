import LocalAuthentication
import Foundation

class LAContextMock: LAContext {
    var canEvaluatePolicyResponse = true
    var evaluatePolicyResponse = true
    
    // MARK: - canEvaluatePolicy vars
    private(set) var canEvaluatePolicyCalledCount = 0
    private(set) var lastCanEvaluatePolicyLAPolicy: LAPolicy!
    
    // MARK: - evaluatePolicy vars
    private(set) var evaluatePolicyCalledCount = 0
    private(set) var lastEvaluatePolicyLAPolicy: LAPolicy!
    
    override func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        canEvaluatePolicyCalledCount += 1
        lastCanEvaluatePolicyLAPolicy = policy

        return canEvaluatePolicyResponse
    }
    
    override func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool {
        evaluatePolicyCalledCount += 1
        lastEvaluatePolicyLAPolicy = policy

        return evaluatePolicyResponse
    }
}
