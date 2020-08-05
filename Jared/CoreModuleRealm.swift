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
    @objc dynamic var sendIntervalNumber = 1
    @objc dynamic var sendIntervalType = IntervalType.Hour.rawValue
    @objc dynamic var text = ""
    @objc dynamic var handle = ""
    @objc dynamic var sendNumberTimes = 1
    @objc dynamic var chatID = ""
    @objc dynamic var startDate = Date()
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var lastSendDate = Date()
    
    var sendIntervalTypeEnum: IntervalType {
        get {
            return IntervalType(rawValue: sendIntervalType)!
        }
        set {
            sendIntervalType = newValue.rawValue
        }
    }
    
}
