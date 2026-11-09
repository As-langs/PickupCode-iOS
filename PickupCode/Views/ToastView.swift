import SwiftUI

struct ToastView: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 16, weight: .semibold))
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 6)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.9)),
            removal: .opacity.combined(with: .scale(scale: 0.95))
        ))
    }
}
