//
//  Logger.swift
//  Broadcast
//
//  Created by Piotr Suwara on 17/11/20.
//

import Foundation

struct Logger {

    static var crashOnDebugLogLevels: Set<Log.Level> = [.error]
    static var reportableLogLevels: Set<Log.Level> = [.error]
    static var logEntries: [Log] = []
    static let queue = DispatchQueue(label: "thread-safe-logger", attributes: .concurrent)
    static func log(level: Log.Level, topic: Log.Topic, message: String) {
        let log = Log(level: level, topic: topic, message: message)
        if shouldPrintLog(for: level) {
            print(log.output)
        }
        assert(!crashOnDebugLogLevels.contains(level), message)
        
        // write
        if Configuration.debugUIEnabled {
            queue.async(flags: .barrier) {
                // perform writes on data
                logEntries.append(log)
            }
        }
        
        // Comment out unless we add crashlytics or other external error reporting
//        if reportableLogLevels.contains(level) {
//            let error = NSError(domain: "Logger", code: 0, userInfo: log.userInfo)
//            Crashlytics.crashlytics().record(error: error)
//        }
    }
    
    static func saveFile(_ filename: String) -> URL {
        let logString = logEntries.reduce("") { result, log -> String in
            return result + log.output + "\n"
        }
        
        let fileUrl = FileManager.default.documentsDirectory().appendingPathComponent(filename)
        try? logString.write(to: fileUrl, atomically: true, encoding: .utf8)
            
        return fileUrl
    }

    static func error(topic: Log.Topic, message: String) {
        Logger.log(level: .error, topic: topic, message: message)
    }

    static func warning(topic: Log.Topic, message: String) {
        Logger.log(level: .warning, topic: topic, message: message)
    }

    static func info(topic: Log.Topic, message: String) {
        Logger.log(level: .info, topic: topic, message: message)
    }

    static func verbose(topic: Log.Topic, message: String) {
        Logger.log(level: .verbose, topic: topic, message: message)
    }

    private static func shouldPrintLog(for level: Log.Level) -> Bool {
        if Configuration.debugUIEnabled {
            switch level {
            case .error: return true
            case .info: return true
            case .verbose: return true
            case .warning: return true
            }
        }
        
        return false
    }
}

// MARK: - Log

struct Log {

    static let dateFormatter = DateFormatter()

    let timestamp: Date = Date()
    let level: Level
    let topic: Topic
    let message: String

    var output: String {
        Log.dateFormatter.dateFormat = "dd-MM-yy HH:mm:ss.SSS"
        let date = Log.dateFormatter.string(from: timestamp)
        return "LOGGER: [\(date)] [\(level.rawValue)] \(topic.rawValue): \(message)"
    }

    var userInfo: [String: Any] {
        [
            "level": level.rawValue,
            "topic": topic.rawValue,
            "message": message,
        ]
    }

    enum Topic: String {
        case appState = "App State"
        case authentication = "Authentication"
        case api = "Api"
        case other = "Other"
        case debug = "Debug"
    }

    enum Level: String {
        case error = "🔴 Error  "
        case warning = "🔶 Warning"
        case info = "🔵 Info   "
        case verbose = "⚪️ Verbose"
    }
}
