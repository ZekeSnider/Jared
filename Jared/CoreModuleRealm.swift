import Foundation
import RealmSwift

class JalenQuote: Object {
    dynamic var text = ""
}

class BazingaLine: Object {
    dynamic var text = ""
}

class Dream: Object {
    dynamic var text = ""
    dynamic var submitter = ""
    dynamic var date: Date? = nil
}

class Joke: Object {
    dynamic var text = ""
    dynamic var submitter: String? = ""
}
