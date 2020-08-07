import Foundation
import Telegraph
import JaredFramework

class JaredWebServer: NSObject {
    static var DEFAULT_PORT = 3000
    var defaults: UserDefaults!
    var server: Server!
    var port: Int!
    var configurationURL: URL
    
    init(configurationURL: URL) {
        self.configurationURL = configurationURL
        super.init()
        defaults = UserDefaults.standard
        server = Server()
        server.route(.POST, "message", JaredWebServer.handleMessageRequest)
        
        port = assignPort()
        
        defaults.addObserver(self, forKeyPath: "RestApiIsDisabled", options: .new, context: nil)
        updateServerState()
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "JaredIsDisabled")
    }
    
    // Attempt to pull the port number from the config
    func assignPort() -> Int {
        let filemanager = FileManager.default
        do {
            // If config file does not exist, use default port
            guard filemanager.fileExists(atPath: configurationURL.path) else {
                return JaredWebServer.DEFAULT_PORT
            }
            
            //Read the JSON config file
            let jsonData = try! NSData(contentsOfFile: configurationURL.path, options: .mappedIfSafe)
            
            // If the JSON format is not as expected at all, use the default port
            guard let jsonResult = try? JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject] else {
                return JaredWebServer.DEFAULT_PORT
            }
            
            guard let serverConfig = jsonResult?["webserver"] as? [String : AnyObject] else {
                return JaredWebServer.DEFAULT_PORT
            }
            
            guard let configPort = serverConfig["port"] as? NSNumber else {
                return JaredWebServer.DEFAULT_PORT
            }
            
            return Int(truncating: configPort)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "RestApiIsDisabled") {
            updateServerState()
        }
    }
    
    func updateServerState() {
        if (defaults.bool(forKey: "RestApiIsDisabled")) {
            stop()
        } else {
            start()
        }
    }
    
    func start() {
        try? server.start(port: port)
    }
    
    func stop() {
        server.stop()
    }
    
    static func handleMessageRequest(request: HTTPRequest) -> HTTPResponse {
        // Attempt to decode the request body to the MessageRequest struct
        do {
            let parsedBody = try JSONDecoder().decode(MessageRequest.self, from: request.body)
            
            if let textBody = parsedBody.body as? TextBody {
                Jared.Send(textBody.message, to: parsedBody.recipient)
                return HTTPResponse()
            }
            else {
                return HTTPResponse(HTTPStatus(code: 400, phrase: "Bad Request"), headers: HTTPHeaders(), content: "Image body types are not supported yet.")
            }
        } catch {
            return HTTPResponse(HTTPStatus(code: 400, phrase: "Bad Request"), headers: HTTPHeaders(), content: error.localizedDescription)
        }
    }
}
