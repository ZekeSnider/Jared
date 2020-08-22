import Foundation
import Telegraph
import JaredFramework

class JaredWebServer: NSObject {
    static var DEFAULT_PORT = 3000
    var defaults: UserDefaults!
    var server: Server!
    var port: Int!
    var sender: MessageSender
    
    init(sender: MessageSender, configuration: WebserverConfiguration) {
        self.sender = sender
        super.init()
        defaults = UserDefaults.standard
        server = Server()
        server.route(.POST, "message", handleMessageRequest)
        
        port = configuration.port
        
        defaults.addObserver(self, forKeyPath: JaredConstants.restApiIsDisabled, options: .new, context: nil)
        updateServerState()
    }
    
    deinit {
        stop()
        UserDefaults.standard.removeObserver(self, forKeyPath: JaredConstants.jaredIsDisabled)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == JaredConstants.restApiIsDisabled) {
            updateServerState()
        }
    }
    
    func updateServerState() {
        if (defaults.bool(forKey: JaredConstants.restApiIsDisabled)) {
            stop()
        } else {
            start()
        }
        
    }
    
    public func start() {
        try? server.start(port: port)
    }
    
    public func stop() {
        server.stop()
    }
    
    private func handleMessageRequest(request: HTTPRequest) -> HTTPResponse {
        // Attempt to decode the request body to the MessageRequest struct
        do {
            let parsedBody = try JSONDecoder().decode(MessageRequest.self, from: request.body)
            
            let textBody = parsedBody.body as? TextBody
            
            guard (textBody != nil || parsedBody.attachments != nil) else {
                return HTTPResponse(HTTPStatus(code: 400, phrase: "Bad Request"), headers: HTTPHeaders(), content: "A text body and/or attachments are required")
            }
            
            let message = Message(body: parsedBody.body, date: Date(), sender: Person(givenName: nil, handle: "", isMe: true), recipient: parsedBody.recipient, attachments: parsedBody.attachments ?? [], sendStyle: nil, associatedMessageType: nil, associatedMessageGUID: nil)
            
            sender.send(message)
            return HTTPResponse()
        } catch {
            return HTTPResponse(HTTPStatus(code: 400, phrase: "Bad Request"), headers: HTTPHeaders(), content: error.localizedDescription)
        }
    }
}
