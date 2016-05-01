import Foundation

import AFNetworking

public typealias JSONObject = [String: AnyObject]

public enum HTTPMethod {
    case Get
}

/**
 API endpoint
 */
public protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters { get }
    associatedtype ResponseType: JSONDecodable
}

/**
 Request parameters
 */
public struct Parameters: DictionaryLiteralConvertible {
    public private(set) var dictionary: [String: AnyObject] = [:]
    public typealias Key = String
    public typealias Value = AnyObject?
    /**
     Initialized from dictionary literals
     */
    public init(dictionaryLiteral elements: (Parameters.Key, Parameters.Value)...) {
        for case let (key, value?) in elements {
            dictionary[key] = value
        }
    }
}

/**
 API error
 - UnexpectedResponse: Unexpected structure
 */
public enum APIError: ErrorType {
    case UnexpectedResponse
}

/** Qaleidospace API created with Import.io
 - SeeAlso: Qaleidospace http://qaleido.space/
            API created with Import.io
 */
public class QaleidospaceAPI {
    private let HTTPSessionManager: AFHTTPSessionManager = {
        let manager = AFHTTPSessionManager(baseURL: NSURL(string: "https://api.import.io/"))
        return manager
    }()
    
    /**
     Perform HTTP request for any endpoints.
     - Parameters:
     - endpoint: API endpoint.
     - handler:  Request results handler.
     */
    public func request<Endpoint: APIEndpoint>(endpoint: Endpoint, handler: (task: NSURLSessionDataTask, response: Endpoint.ResponseType?, error: ErrorType?) -> Void) {
        let success = { (task: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            if let JSON = response as? JSONObject {
                do {
                    let response = try Endpoint.ResponseType(JSON: JSON)
                    handler(task: task, response: response, error: nil)
                } catch {
                    handler(task: task, response: nil, error: error)
                }
            } else {
                handler(task: task, response: nil, error: APIError.UnexpectedResponse)
            }
        }
        let failure = { (task: NSURLSessionDataTask?, var error: NSError) -> Void in
            // If the error has any data, put it into "localized failure reason"
            if let errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? NSData,
                let errorDescription = NSString(data: errorData, encoding: NSUTF8StringEncoding) {
                    var userInfo = error.userInfo
                    userInfo[NSLocalizedFailureReasonErrorKey] = errorDescription
                    error = NSError(domain: error.domain, code: error.code, userInfo: userInfo)
            }
            handler(task: task!, response: nil, error: error)
        }
        
        switch endpoint.method {
        case .Get:
            HTTPSessionManager.GET(endpoint.path, parameters: endpoint.parameters.dictionary, progress: nil, success: success, failure: failure)
        }
    }
    
    /**
    - list API
    */
    public struct List: APIEndpoint {
        public var path = "store/connector/ccb22dfb-1b72-424a-90ba-640186f14406/_query"
        public var method = HTTPMethod.Get
        public var parameters: Parameters {
            return [
                "input": "webpage/url:http://qaleido.space/?type=7hours",
                "_apikey": "",
            ]
        }
        public typealias ResponseType = ListResult<Item>
    }
}

/**
 JSON decodable type
 */
public protocol JSONDecodable {
    init(JSON: JSONObject) throws
}

/**
 JSON decode error
 - MissingRequiredKey:   Required key is missing
 - UnexpectedType:       Value type is unexpected
 - CannotParseURL:       Value cannot be parsed as URL
 - CannotParseDate:      Value cannot be parsed as date
 */
public enum JSONDecodeError: ErrorType, CustomDebugStringConvertible {
    case MissingRequiredKey(String)
    case UnexpectedType(key: String, expected: Any.Type, actual: Any.Type)
    case CannotParseURL(key: String, value: String)
    case CannotParseDate(key: String, value: String)
    
    public var debugDescription: String {
        switch self {
        case .MissingRequiredKey(let key):
            return "JSON Decode Error: Required key '\(key)' missing"
        case let .UnexpectedType(key: key, expected: expected, actual: actual):
            return "JSON Decode Error: Unexpected type '\(actual)' was supplied for '\(key): \(expected)'"
        case let .CannotParseURL(key: key, value: value):
            return "JSON Decode Error: Cannot parse URL '\(value)' for key '\(key)'"
        case let .CannotParseDate(key: key, value: value):
            return "JSON Decode Error: Cannot parse date '\(value)' for key '\(key)'"
        }
    }
}

/**
 List result data
 */
public struct ListResult<ItemType: JSONDecodable>: JSONDecodable {
    public let count: Int
    public let items: [ItemType]
    
    /**
     Initialize from JSON object
     - Parameter JSON: JSON object
     - Throws: JSONDecodeError
     - Returns: SearchResult
     */
    public init(JSON: JSONObject) throws {
        self.items = try (getValue(JSON, key: "results") as [JSONObject]).mapWithRethrow { return try ItemType(JSON: $0) }
        self.count = self.items.count
        
    }
}

/**
 Item data
 */
public struct Item: JSONDecodable {
    public let no: String
    public let userIconURL: NSURL
    public let userIconAlt: String
    public let title: String
    public let URL: NSURL
    public let date: String
    public let point: String
    public let tags: AnyObject
    
    /**
     Initialize from JSON object
     - Parameter JSON: JSON object
     - Throws: JSONDecodeError
     - Returns: SearchResult
     */
    public init(JSON: JSONObject) throws {
        self.no = try getValue(JSON, key: "no")
        self.userIconURL = try getURL(JSON, key: "user_icon")
        self.userIconAlt = try getValue(JSON, key: "user_icon/_alt")
        self.title = try getValue(JSON, key: "title/_text")
        self.URL = try getURL(JSON, key: "title")
        self.date = try getValue(JSON, key: "date")
        self.point = try getValue(JSON, key: "point")
        self.tags = try getValue(JSON, key: "tags") as AnyObject
        
    }
}

// MARK: - Utilities

/**
Get URL from JSON for key
- Parameters:
- JSON: JSON object
- key:  Key
- Throws: JSONDecodeError
- Returns: URL
*/
private func getURL(JSON: JSONObject, key: String) throws -> NSURL {
    let URLString: String = try getValue(JSON, key: key)
    guard let URL = NSURL(string: URLString) else {
        throw JSONDecodeError.CannotParseURL(key: key, value: URLString)
    }
    return URL
}

/**
 Get URL from JSON for key
 - Parameters:
 - JSON: JSON object
 - key:  Key
 - Throws: JSONDecodeError
 - Returns: URL or nil
 */
private func getOptionalURL(JSON: JSONObject, key: String) throws -> NSURL? {
    guard let URLString: String = try getOptionalValue(JSON, key: key) else { return nil }
    guard let URL = NSURL(string: URLString) else {
        throw JSONDecodeError.CannotParseURL(key: key, value: URLString)
    }
    return URL
}

/**
Parse ISO 8601 format date string
*/
private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    return formatter
}()

/**
 Get date from JSON for key
 - Parameters:
 - JSON: JSON object
 - key:  Key
 - Throws: JSONDecodeError
 - Returns: date
 */
private func getDate(JSON: JSONObject, key: String) throws -> NSDate {
    let dateString: String = try getValue(JSON, key: key)
    guard let date = dateFormatter.dateFromString(dateString) else {
        throw JSONDecodeError.CannotParseDate(key: key, value: dateString)
    }
    return date
}

/**
 Get date from JSON for key
 - Parameters:
 - JSON: JSON object
 - key:  Key
 - Throws: JSONDecodeError
 - Returns: date or nil
 */
private func getOptionalDate(JSON: JSONObject, key: String) throws -> NSDate? {
    guard let dateString: String = try getOptionalValue(JSON, key: key) else { return nil }
    guard let date = dateFormatter.dateFromString(dateString) else {
        throw JSONDecodeError.CannotParseDate(key: key, value: dateString)
    }
    return date
}

/**
 Get typed value from JSON for key. Type `T` should be inferred from contexts.
 - Parameters:
 - JSON: JSON object
 - key:  Key
 - Throws: JSONDecodeError
 - Returns: Typed value
 */
private func getValue<T>(JSON: JSONObject, key: String) throws -> T {
    guard let value = JSON[key] else {
        throw JSONDecodeError.MissingRequiredKey(key)
    }
    guard let typedValue = value as? T else {
        throw JSONDecodeError.UnexpectedType(key: key, expected: T.self, actual: value.dynamicType)
    }
    return typedValue
}

/**
 Get typed value from JSON for key. Type `T` should be inferred from contexts.
 - Parameters:
 - JSON: JSON object
 - key:  Key
 - Throws: JSONDecodeError
 - Returns: Typed value or nil
 */
private func getOptionalValue<T>(JSON: JSONObject, key: String) throws -> T? {
    guard let value = JSON[key] else {
        return nil
    }
    if value is NSNull {
        return nil
    }
    guard let typedValue = value as? T else {
        throw JSONDecodeError.UnexpectedType(key: key, expected: T.self, actual: value.dynamicType)
    }
    return typedValue
}

private extension Array {
    /**
     Workaround for `map` with throwing closure
     */
    func mapWithRethrow<T>(@noescape transform: (Array.Generator.Element) throws -> T) rethrows -> [T] {
        var mapped: [T] = []
        for element in self {
            mapped.append(try transform(element))
        }
        return mapped
    }
}
