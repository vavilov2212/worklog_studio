import Cocoa
import FlutterMacOS

class RegisteredEngine {
    let id: String
    let role: String
    let channel: FlutterMethodChannel
    var subscriptions: Set<String> = []

    init(id: String, role: String, channel: FlutterMethodChannel) {
        self.id = id
        self.role = role
        self.channel = channel
    }
}

class IpcRouter {
    static let shared = IpcRouter()
    private var engines: [String: RegisteredEngine] = [:]

    func register(messenger: FlutterBinaryMessenger, role: String, callHandler: @escaping FlutterMethodCallHandler) {
        let engineId = UUID().uuidString
        let channel = FlutterMethodChannel(name: "worklog_studio/ipc", binaryMessenger: messenger)
        let engine = RegisteredEngine(id: engineId, role: role, channel: channel)

        self.engines[engineId] = engine

        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }

            // Intercept IPC routing commands
            switch call.method {
            case "getEngineInfo":
                result(["engineId": engineId, "role": role])
                
            case "subscribe":
                if let args = call.arguments as? [String: Any], let topic = args["topic"] as? String {
                    self.engines[engineId]?.subscriptions.insert(topic)
                }
                result(nil)
                
            case "unsubscribe":
                if let args = call.arguments as? [String: Any], let topic = args["topic"] as? String {
                    self.engines[engineId]?.subscriptions.remove(topic)
                }
                result(nil)
                
            case "sendMessage":
                if let args = call.arguments as? [String: Any],
                   let target = args["target"] as? String,
                   let messageMethod = args["method"] as? String {
                    let payload = args["payload"]
                    self.routeMessage(from: engineId, target: target, method: messageMethod, payload: payload)
                }
                result(nil)
                
            case "deregister":
                self.engines.removeValue(forKey: engineId)
                result(nil)
                
            default:
                // Pass unhandled native commands back to the custom handler (like show/hide/legacy ones)
                callHandler(call, result)
            }
        }
    }

    func routeMessage(from sourceId: String, target: String, method: String, payload: Any?) {
        var targets: [RegisteredEngine] = []

        if target == "main" {
            targets = engines.values.filter { $0.role == "main" }
        } else if target.hasPrefix("role:") {
            let role = target.replacingOccurrences(of: "role:", with: "")
            targets = engines.values.filter { $0.role == role }
        } else if target.hasPrefix("engine:") {
            let id = target.replacingOccurrences(of: "engine:", with: "")
            if let e = engines[id] { targets.append(e) }
        } else if target.hasPrefix("topic:") {
            let topic = target.replacingOccurrences(of: "topic:", with: "")
            targets = engines.values.filter { $0.subscriptions.contains(topic) }
        } else if target == "all" {
            targets = Array(engines.values)
        }

        let arguments: [String: Any?] = [
            "from": sourceId,
            "method": method,
            "payload": payload
        ]

        for t in targets {
            t.channel.invokeMethod("onMessage", arguments: arguments)
        }
    }
}
