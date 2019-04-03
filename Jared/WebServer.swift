import Foundation
import Telegraph
import JaredFramework

let server = Server()

func initWebServer() {
    server.route(.POST, "message", handleGreeting)
    try! server.start(port: 9000)
}

public struct MessageRequest: Decodable {
    public var body: MessageBody
    public var recipient: RecipientEntity
    
    enum CodingKeys : String, CodingKey{
        case body
        case recipient
    }
    
    enum ParameterError: Error {
        case runtimeError(String)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let textBody = try? container.decode(TextBody.self, forKey: .body) {
            self.body = textBody
        } else if let imageBody = try? container.decode(ImageBody.self, forKey: .body) {
            self.body = imageBody
        } else {
            throw ParameterError.runtimeError("the body parameter is incorrectly formatted")
        }
        
        if let person = try? container.decode(Person.self, forKey: .recipient) {
            self.recipient = person
        } else if let group = try? container.decode(Group.self, forKey: .recipient) {
            self.recipient = group
        } else {
            throw ParameterError.runtimeError("the recipient parameter is incorrectly formatted")
        }
    }
    
}

func handleGreeting(request: HTTPRequest) -> HTTPResponse {
    do {
        let parsedBody = try JSONDecoder().decode(MessageRequest.self, from: request.body)
//      Jared.Send
    } catch {
        return HTTPResponse(HTTPStatus(code: 400), headers: HTTPHeaders(), content: error.localizedDescription)
    }
    
    return HTTPResponse(content: "Hello")
}
