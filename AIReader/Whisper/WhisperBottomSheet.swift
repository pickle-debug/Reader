//
//  ContentView.swift
//  Apple Music Bottom Bar
//
//  Created by Bruno Mazzocchi on 22/6/25.
//

import SwiftUI

struct WhisperBottomSheet: View {
    @Binding var expandSheet: Bool
    var animation: Namespace.ID
    // View Properties
    @State private var animationContent: Bool = false
    @State private var offsetY: CGFloat = 0
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            ZStack {
                RoundedRectangle(cornerRadius: animationContent ? deviceCornerRadius : 0, style: .continuous)
                    .fill(GradientBackground.gradient)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: animationContent ? deviceCornerRadius : 0, style: .continuous)
                            .fill(Color("BG"))
                            .opacity(animationContent ? 0 : 1)
                    })
                    .matchedGeometryEffect(id: "BGVIEW", in: animation)
                
                VStack(spacing: 15) {
                    Capsule()
                        .fill(.gray)
                        .frame(width: 40, height: 5)
                        .opacity(animationContent ? 1 : 0)
                        .offset(y: animationContent ? 0 : size.height)
                    
                    
                    // Artwork Hero View
                    GeometryReader {
                        let size = $0.size
                        
                        Image("Artwork")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: animationContent ? 15 : 5, style: .continuous))
                        
                    }
                    .matchedGeometryEffect(id: "ARTWORK", in: animation)
                    .frame(height: size.width - 50)
                    .padding(.vertical, size.height < 700 ? 10 : 30)
                    
                    Spacer()
                    WhisperPlayerView(mainsize: size)
                        .offset(y: animationContent ? 0 : size.height)
                }
                .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10 : 0))
                .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
                .padding(.horizontal, 25)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipped()
            }
            .contentShape(Rectangle())
            .offset(y: offsetY)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        let translationY = value.translation.height
                        offsetY = (translationY > 0 ? translationY : 0)
                    }).onEnded({ value in
                        withAnimation (.easeInOut (duration: 0.3)) {
                            if offsetY > size.height * 0.4 {
                                expandSheet = false
                                animationContent = false
                            } else {
                                offsetY = .zero
                            }
                            
                        }
                    })
            )
            .ignoresSafeArea(.container, edges: .all)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) {
                animationContent = true
            }
        }
    }
}
extension View {
    var deviceCornerRadius: CGFloat {
        let key = "_displayCornerRadius"
        if let screen = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen {
            if let cornerRadius = screen.value(forKey: key) as? CGFloat {
                return cornerRadius
            }
            
            return 0
        }
        return 0
    }
}
