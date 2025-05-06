import Foundation
import Network

struct JoystickData: Codable {
    let joystickId: Int
    let x: Float
    let y: Float
    
    var data: Data {
        var data = Data()
        var mutableJoystickId = joystickId
        var mutableX = x
        var mutableY = y
        data.append(Data(bytes: &mutableJoystickId, count: MemoryLayout<Int>.size))
        data.append(Data(bytes: &mutableX, count: MemoryLayout<Float>.size))
        data.append(Data(bytes: &mutableY, count: MemoryLayout<Float>.size))
        return data
    }
}

class UDPClient: ObservableObject {
    private var connection: NWConnection?
    private var host: NWEndpoint.Host
    private let port: NWEndpoint.Port
    @Published var isConnected = false
    
    init(host: String, port: UInt16) {
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: port)!
    }
    
    func updateHost(_ newHost: String) {
        if isConnected {
            disconnect()
        }
        host = NWEndpoint.Host(newHost)
    }
    
    func connect() {
        let parameters = NWParameters.udp
        connection = NWConnection(host: host, port: port, using: parameters)
        
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    print("UDP connection ready")
                    self?.isConnected = true
                case .failed(let error):
                    print("UDP connection failed: \(error)")
                    self?.isConnected = false
                case .cancelled:
                    print("UDP connection cancelled")
                    self?.isConnected = false
                default:
                    self?.isConnected = false
                    break
                }
            }
        }
        
        connection?.start(queue: .main)
    }
    
    func disconnect() {
        connection?.cancel()
        isConnected = false
    }
    
    func send(data: Data) {
        guard isConnected else {
            print("Not connected")
            return
        }
        
        connection?.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("Error sending data: \(error)")
            }
        })
    }
    
    func sendJoystickData(x: Float, y: Float, joystickId: Int) {
        guard isConnected else { return }
        
        let joystickData = JoystickData(joystickId: joystickId, x: x, y: y)
        send(data: joystickData.data)
    }
} 