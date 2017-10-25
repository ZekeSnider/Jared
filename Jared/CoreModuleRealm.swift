import Foundation
import RealmSwift

enum IntervalType: String {
    case Minute
    case Hour
    case Day
    case Week
    case Month
}

let intervalSeconds: [IntervalType: Double] =
[
    .Minute: 60.0,
    .Hour: 3600.0,
    .Day: 86400.0,
    .Week: 604800.0,
    .Month: 2592000.0
]

class SchedulePost: Object {
    dynamic var sendIntervalNumber = 1
    dynamic var sendIntervalType = IntervalType.Hour.rawValue
    dynamic var text = ""
    dynamic var handle = ""
    dynamic var sendNumberTimes = 1
    dynamic var chatID = ""
    dynamic var startDate = Date()
    dynamic var id = UUID().uuidString
    dynamic var lastSendDate = Date()
    
    var sendIntervalTypeEnum: IntervalType {
        get {
            return IntervalType(rawValue: sendIntervalType)!
        }
        set {
            sendIntervalType = newValue.rawValue
        }
    }
    
}
