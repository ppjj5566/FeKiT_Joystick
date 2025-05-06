//
//  ContentView.swift
//  FeKit_Joystick
//
//  Created by 박정욱 on 5/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var udpClient = UDPClient(host: "192.168.1.100", port: 12345)
    @State private var ipAddress: String = "192.168.1.100"
    @State private var port: Int = 12345
    @State private var portString: String = "12345"
    @State private var showSettings = false
    @State private var joystickSize: CGFloat = 150
    @State private var joystickSpacing: CGFloat = 200
    @State private var isDarkMode = false
    private let minJoystickSize: CGFloat = 100
    private let maxJoystickSize: CGFloat = 300
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Menu Bar
                HStack {
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Text(udpClient.isConnected ? "Connected" : "Disconnected")
                        .foregroundColor(udpClient.isConnected ? .green : .red)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .font(.title2)
                            .foregroundColor(isDarkMode ? .yellow : .orange)
                    }
                    .padding()
                }
                .background(Color.gray.opacity(0.1))
                
                // Main Content
                VStack {
                    HStack(spacing: joystickSpacing) {
                        JoystickView(size: joystickSize, joystickId: 0) { x, y, id in
                            udpClient.sendJoystickData(x: x, y: y, joystickId: id)
                        }
                        
                        JoystickView(size: joystickSize, joystickId: 1) { x, y, id in
                            udpClient.sendJoystickData(x: x, y: y, joystickId: id)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity)
            }
            
            if showSettings {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showSettings = false
                    }
                
                VStack(spacing: 15) {
                    // Connection Settings
                    HStack(spacing: 10) {
                        TextField("IP", text: $ipAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numbersAndPunctuation)
                            .autocapitalization(.none)
                            .frame(width: 120)
                        
                        TextField("Port", text: $portString)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .autocapitalization(.none)
                            .frame(width: 80)
                            .onChange(of: portString) { oldValue, newValue in
                                if let newPort = Int(newValue) {
                                    port = newPort
                                }
                            }
                        
                        Button(action: {
                            if udpClient.isConnected {
                                udpClient.disconnect()
                            } else {
                                udpClient.updateHost(ipAddress)
                                udpClient.connect()
                            }
                        }) {
                            Text(udpClient.isConnected ? "Disconnect" : "Connect")
                                .frame(width: 100)
                                .padding(.vertical, 8)
                                .background(udpClient.isConnected ? Color.red : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Joystick Settings
                    VStack(spacing: 12) {
                        HStack {
                            Text("Size")
                                .frame(width: 60, alignment: .leading)
                            Slider(value: $joystickSize, in: minJoystickSize...maxJoystickSize)
                            Text("\(Int(joystickSize))")
                                .frame(width: 40)
                        }
                        
                        HStack {
                            Text("Space")
                                .frame(width: 60, alignment: .leading)
                            Slider(value: $joystickSpacing, in: 100...300)
                            Text("\(Int(joystickSpacing))")
                                .frame(width: 40)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button("Close") {
                        showSettings = false
                    }
                    .frame(width: 100)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.vertical, 15)
                .background(isDarkMode ? Color.black : Color.white)
                .cornerRadius(15)
                .padding()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}
