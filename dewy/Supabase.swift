import Foundation
import OSLog
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://riycadlhyixpkdpvxhpx.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJpeWNhZGxoeWl4cGtkcHZ4aHB4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI3Mzg4NTksImV4cCI6MjA0ODMxNDg1OX0.zigMLxHXcDCGpGyVyz-n-6CmUkGpLUFpJTbd1MQkr6w",
    options: .init(
        global: .init(logger: AppLogger())
    )
)

struct AppLogger: SupabaseLogger {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "supabase")
    
    func log(message: SupabaseLogMessage) {
        switch message.level {
        case .verbose:
            logger.log(level: .info, "\(message.description)")
        case .debug:
            logger.log(level: .debug, "\(message.description)")
        case .warning, .error:
            logger.log(level: .error, "\(message.description)")
        }
    }
}
