import Foundation

/// States shared in whole app
class ApplicationContext {
    let qaleidospaceAPI: QaleidospaceAPI = QaleidospaceAPI()
}

protocol ApplicationContextSettable: class {
    var appContext: ApplicationContext! { get set }
}