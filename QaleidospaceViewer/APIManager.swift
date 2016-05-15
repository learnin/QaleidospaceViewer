import Foundation

/**
 Perform Qaleidospace API
 */
class APIManager {
    
    let qaleidospaceAPI: QaleidospaceAPI
    
    var networking: Bool = false
    
    var results: [Item] = []
    var completed: Bool = false
    
    init?(qaleidospaceAPI: QaleidospaceAPI) {
        self.qaleidospaceAPI = qaleidospaceAPI
    }
    
    /**
     List
     - Parameters:
     - reload:     Reload
     - completion: Completion handler
     - Returns: True if executed
     */
    func list(reload: Bool, completion: (error: ErrorType?) -> Void) -> Bool {
        if completed || networking {
            return false
        }
        networking = true
        qaleidospaceAPI.request(QaleidospaceAPI.List()) { (response, error) in
            if let response = response {
                if reload {
                    self.results.removeAll()
                }
                self.results.appendContentsOf(response.items)
                self.completed = response.count <= self.results.count
            }
            self.networking = false
            completion(error: error)
        }
        return true
    }
    
}
