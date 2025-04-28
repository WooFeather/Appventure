//
//  ExpandableText.swift
//  Appventure
//
//  Created by 조우현 on 4/26/25.
//

import SwiftUI

struct ExpandableText: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var expanded: Bool = false
    @State private var truncated: Bool = false
    private var text: String

    let lineLimit: Int

    init(_ text: String, lineLimit: Int) {
        self.text = text
        self.lineLimit = lineLimit
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(expanded ? nil : lineLimit)
                .background(
                    Text(text).lineLimit(lineLimit)
                        .background(GeometryReader { visibleTextGeometry in
                            ZStack {
                                Text(self.text)
                                    .background(GeometryReader { fullTextGeometry in
                                        Color.clear.onAppear {
                                            self.truncated = fullTextGeometry.size.height > visibleTextGeometry.size.height
                                        }
                                    })
                            }
                            .frame(height: .greatestFiniteMagnitude)
                        })
                        .hidden()
            )
            if truncated {
                Button {
                    withAnimation { expanded = true }
                } label: {
                    Text("더 보기")
                        .foregroundStyle(.blue)
                        .frame(width: 60, height: 20)
                        .background(colorScheme == .light ? Color.white : Color.black)
                }
                .opacity(expanded ? 0 : 1)
                
            }
        }
    }
}
