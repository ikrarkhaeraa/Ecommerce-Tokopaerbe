//
//  PullToRefreshView.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 11/07/24.
//

import SwiftUI

struct PullToRefreshView: View {
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    private static let minRefreshTimeInterval = TimeInterval(0.2)
    private static let triggerHeight = CGFloat(100)
    private static let indicatorHeight = CGFloat(100)
    private static let fullHeight = triggerHeight + indicatorHeight
    
    let backgroundColor: Color
    let foregroundColor: Color
    let isEnabled: Bool
    let onRefresh: () -> Void
    
    @State private var isRefreshIndicatorVisible = false
    @State private var refreshStartTime: Date? = nil
    
    init(bg: Color = .white, fg: Color = .black, isEnabled: Bool = true, onRefresh: @escaping () -> Void)
    {
        self.backgroundColor = bg
        self.foregroundColor = fg
        self.isEnabled = isEnabled
        self.onRefresh = onRefresh
    }
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            LazyVStack(spacing: 0)
            {
                Color.clear
                    .frame(height: Self.triggerHeight)
                    .onAppear
                    {
                        if isEnabled
                        {
                            withAnimation
                            {
                                isRefreshIndicatorVisible = true
                            }
                            refreshStartTime = Date()
                        }
                    }
                    .onDisappear
                    {
                        if isEnabled, isRefreshIndicatorVisible, let diff = refreshStartTime?.distance(to: Date()), diff > Self.minRefreshTimeInterval
                        {
                            onRefresh()
                        }
                        withAnimation
                        {
                            isRefreshIndicatorVisible = false
                        }
                        refreshStartTime = nil
                    }
            }
            .frame(height: Self.triggerHeight)
            
            indicator
                .frame(height: Self.indicatorHeight)
        }
        .background(isDark ? .black :backgroundColor)
        .ignoresSafeArea(edges: .all)
        .frame(height: Self.fullHeight)
        .padding(.top, -Self.fullHeight)
    }
    
    private var indicator: some View
    {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: isDark ? .white :foregroundColor))
            .opacity(isRefreshIndicatorVisible ? 1 : 0)
    }
}
