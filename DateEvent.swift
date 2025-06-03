import Foundation

struct DateEvent: Codable {
    let title: String
    let date: Date
    let type: EventType
    let color: String
    
    enum EventType: String, Codable {
        case countdown
        case countup
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: date)
        return components.day ?? 0
    }
    
    var daysElapsed: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: Date())
        return components.day ?? 0
    }
    
    var detailedDateInfo: (year: Int, month: Int, day: Int, hour: Int, totalDays: Int) {
        let calendar = Calendar.current
        let now = Date()
        let fromDate = type == .countdown ? now : date
        let toDate = type == .countdown ? date : now
        
        // 计算详细的时间组件
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: fromDate, to: toDate)
        
        // 计算总天数
        let totalDays = type == .countdown ? abs(daysRemaining) : daysElapsed
        
        // 获取实际的月份和天数（不需要取模，因为 Calendar 已经正确处理了进位）
        return (
            year: abs(components.year ?? 0),
            month: abs(components.month ?? 0),
            day: abs(components.day ?? 0),
            hour: abs(components.hour ?? 0),
            totalDays: totalDays
        )
    }
} 