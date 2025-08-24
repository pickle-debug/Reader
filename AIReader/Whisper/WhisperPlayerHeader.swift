//
//  WhisperHeaderView.swift
//  read
//
//  Created by 何纪栋 on 2025/8/24.
//
import SwiftUI

struct WhisperPlayerHeader: View {
 
    var articleName: String
    var createTime: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(articleName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(createTime)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
