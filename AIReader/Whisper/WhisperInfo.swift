//
//  WhisperInfo.swift
//  read
//
//  Created by 何纪栋 on 2025/8/24.
//

import SwiftUI

struct WhisperInfo: View {
    var size: CGSize
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: size.height / 4)
                .fill(.blue.gradient)
                .frame(width: size.width, height: size.height)
            
            VStack (alignment: .leading, spacing: 6) {
                Text ("Some Apple Music Title")
                    .font(.callout)
                Text("Some Artist Name")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            .lineLimit(1)
        }
    }
}
