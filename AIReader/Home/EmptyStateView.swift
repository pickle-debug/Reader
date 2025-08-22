//
//  EmptyStateView.swift
//  read
//
//  Created by 何纪栋 on 2025/8/21.
//

import SwiftUI
// 空状态视图
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: (() -> Void)?
    
    init(icon: String, title: String, subtitle: String, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let action = action {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("开始创建")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(20)
                }
            }
        }
        .padding(.top, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
