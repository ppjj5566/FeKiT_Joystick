import SwiftUI

struct JoystickView: View {
    @State private var location: CGPoint = .zero
    @State private var isDragging = false
    let size: CGFloat
    let joystickId: Int
    let onJoystickMoved: (Float, Float, Int) -> Void
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: size, height: size)
            
            // Joystick handle
            Circle()
                .fill(isDragging ? Color.blue : Color.gray)
                .frame(width: size * 0.4, height: size * 0.4)
                .position(location)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            let radius = size / 2
                            let center = CGPoint(x: radius, y: radius)
                            let vector = CGVector(
                                dx: value.location.x - center.x,
                                dy: value.location.y - center.y
                            )
                            let distance = sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
                            
                            if distance > radius {
                                let normalizedX = vector.dx / distance
                                let normalizedY = vector.dy / distance
                                location = CGPoint(
                                    x: center.x + normalizedX * radius,
                                    y: center.y + normalizedY * radius
                                )
                            } else {
                                location = value.location
                            }
                            
                            // Calculate normalized values (-1 to 1)
                            let normalizedX = Float((location.x - center.x) / radius)
                            let normalizedY = Float((location.y - center.y) / radius)
                            onJoystickMoved(normalizedX, normalizedY, joystickId)
                        }
                        .onEnded { _ in
                            isDragging = false
                            withAnimation {
                                location = CGPoint(x: size / 2, y: size / 2)
                            }
                            onJoystickMoved(0, 0, joystickId)
                        }
                )
        }
        .frame(width: size, height: size)
        .onAppear {
            location = CGPoint(x: size / 2, y: size / 2)
        }
    }
} 