// LoadingOverlay.swift
import SwiftUI

/// A simple spinning loader overlay during processing.
struct LoadingOverlay: View {
    var message: String = "Processing..."
    
    var body: some View {
        ZStack {
            // Subtle darkening
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Spinning loader
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text(message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}

// Convenience view modifier
struct LoadingOverlayModifier: ViewModifier {
    @Binding var isPresented: Bool
    var message: String = "Processing..."
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isPresented {
                        LoadingOverlay(message: message)
                            .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                    }
                }
            )
    }
}

extension View {
    func loadingOverlay(isPresented: Binding<Bool>, message: String = "Processing...") -> some View {
        self.modifier(LoadingOverlayModifier(isPresented: isPresented, message: message))
    }
}
