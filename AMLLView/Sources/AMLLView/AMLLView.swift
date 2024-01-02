//
//  AMLLView.swift
//
//
//  Created by YICHAO LI on 2024/1/1.
//

import SwiftUI
import AMLLView

public struct AMLLView: View {
    // MARK: Binding Data
    @Binding var playedTime     : Double
    
    // MARK: Init Config
    @Binding var lrcConfig      : AAMLLrcConfig?
    @State var viewConfig       : AAMLViewConfig = defaultAAMLViewConfig
    
    // MARK: Lyrics
    @State var lyricsArray              : [LrcLyric]?   = nil
    // MARK: Lyrics Hightlight
    @State var lrcHightlightCellIndex   : Int  = 0
    // MARK: ScrollView
    @State var isScrollViewGestrueScroll: Bool          = false
    @State var inLongPress              : Bool          = false
    @State var scorllValue              : CGFloat       = 0
    
    // MARK: seek
    public var onSeek: ((Double) -> Void)?
    
    public init(playedTime: Binding<Double>,
                lrcConfig: Binding<AAMLLrcConfig?>,
                viewConfig: AAMLViewConfig = defaultAAMLViewConfig,
                onSeek: ((Double) -> Void)?
    )
    {
        self._playedTime = playedTime
        self._lrcConfig = lrcConfig
        self.viewConfig = viewConfig
        self.onSeek = onSeek
    }
    
    public var body: some View {
        GeometryReader { bounds in
            //MARK: ScrollView Reader
            ScrollViewReader { proxy in
                
                // MARK: Gestrue Event
                let longPress = LongPressGesture()
                let dragGesture = DragGesture()
                    .onChanged{ value in
                        isScrollViewGestrueScroll = true
                        scorllValue = value.translation.height
                    }
                    .onEnded{ _ in
                        calcLrcScrollViewDragEnd(proxy: proxy)
                    }
                let sequencedGesture = longPress.sequenced(before: dragGesture)
                
                // MARK: Lyrics ScrollView
                ScrollView(showsIndicators: false) {
                    ForEach( lyricsArray ?? [], id:\.id ) { lyric in
                        HStack(spacing: 0) {
                            Spacer(minLength: 0)
                            
                            if (lrcConfig?.lrcType == .lrc) {
                                LrcLyricCell(lyric: lyric,
                                             viewConfig: $viewConfig,
                                             lrcHightlightCellIndex: $lrcHightlightCellIndex,
                                             isScrollViewGestrueScroll: $isScrollViewGestrueScroll,
                                             onSeek: onSeek)
                            }
                            
                            Spacer(minLength: 0)
                        }
                        .id(lyric.id)
                    }
                    .offset(y: scorllValue)
                }
                .scrollDisabled(viewConfig.isCloseDefaultScroll)
                .gesture(viewConfig.isCloseDefaultScroll ? sequencedGesture : nil)
                // MARK: calcHightlightCellChange
                .onChange(of: lrcHightlightCellIndex) { _, _ in
                    calcLrcScrollViewNewHightlightCell(proxy: proxy)
                }
            }
        }
        // MARK: receive time update
        .onChange(of: playedTime) { _, time in
            updateLrcLyric(timePosition: time)
        }
        // MARK: update Lyrics Config
        .onChange(of: lrcConfig) { oldValue, newValue in
            debugPrint("AAMLView onChange LrcConfig")
            guard let lrcConfig = lrcConfig else { return }
            Task {
                do {
                    try await lyricsArray = AAMLResourceManager.shared.handlerLrc(urlType: lrcConfig.lrcURLType, URL: lrcConfig.lrcURL, coderType: lrcConfig.coderType, withExtraInfo: false)
                } catch {
                    debugPrint(error)
                }
            }
        }
        // MARK: onAppear Load Lyrics
        .onAppear {
            debugPrint("AAMLView onAppear")
            guard let lrcConfig = lrcConfig else { return }
            Task {
                do {
                    try await lyricsArray = AAMLResourceManager.shared.handlerLrc(urlType: lrcConfig.lrcURLType, URL: lrcConfig.lrcURL, coderType: lrcConfig.coderType, withExtraInfo: false)
                } catch {
                    debugPrint(error)
                }
            }
        }
    }
}

// MARK: Animation
extension AMLLView {
    func calcLrcScrollViewDragEnd(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(viewConfig.translateAnimation) {
                scorllValue = 0
                isScrollViewGestrueScroll = false
                if let lyricsCount = lyricsArray?.count, lyricsCount >= 1, lrcHightlightCellIndex > 0 {
                    proxy.scrollTo(lyricsArray?[lrcHightlightCellIndex - 1].id, anchor: viewConfig.highlightAnchor)
                } else {
                    proxy.scrollTo(lyricsArray?[lrcHightlightCellIndex].id, anchor: .top)
                }
            }
        }
    }
    
    func calcLrcScrollViewNewHightlightCell(proxy: ScrollViewProxy) {
        if let lyricsCount = lyricsArray?.count, lyricsCount >= 1, !isScrollViewGestrueScroll {
            DispatchQueue.main.async {
                withAnimation(viewConfig.translateAnimation) {
                    let scrollToIndex = lrcHightlightCellIndex > 0 ? lrcHightlightCellIndex - 1 : lrcHightlightCellIndex
                    proxy.scrollTo(lyricsArray?[scrollToIndex].id, anchor: scrollToIndex > 0 ? viewConfig.highlightAnchor : .top)
                }
            }
        }
    }
}

// MARK: Update HighlightCellIndex
extension AMLLView {
    func updateLrcLyric(timePosition: Double) {
        // Empty
        guard let lyricArray = self.lyricsArray, !lyricArray.isEmpty else {
            DispatchQueue.main.async {
                lrcHightlightCellIndex = 0
            }
            return
        }
        if timePosition <= 0.1 {
            DispatchQueue.main.async {
                lrcHightlightCellIndex = 0
            }
        }
        DispatchQueue.main.async {
            for (index, lyric) in lyricArray.enumerated() {
                if index != lyricArray.count-1 {
                    if lyric.time < timePosition && lyricArray[index+1].time >= timePosition {
                        if index != lrcHightlightCellIndex {
                            lrcHightlightCellIndex = index
                            debugPrint("update", index, lyric.time)
                            break
                        }
                    }
                } else {
                    if lyric.time < timePosition {
                        if index != lrcHightlightCellIndex {
                            lrcHightlightCellIndex = index
                            debugPrint("update", index, lyric.time)
                            break
                        }
                    }
                }
            }
        }
    }
}

// MARK: LyricCell - Lrc Type
struct LrcLyricCell: View {
    // MARK:
    @State   var lyric                  : LrcLyric
    @Binding var viewConfig             : AAMLViewConfig
    @Binding var lrcHightlightCellIndex : Int
    @Binding var isScrollViewGestrueScroll : Bool
    // MARK: Internal Calc Value
    @State var isHighlight          : Bool = false
    @State var highlightCellIndex   : Int? = 0
    @State var isBlurEffectReduce   : Bool = false
    // MARK: Seek
    public var onSeek: ((Double) -> Void)?
    
    // MARK: Internal Display Value
    @State var isClick : Bool = false
    @State private var blurRadius: CGFloat = 1.2
    
    var body: some View {
        if (!lyric.lyric.isEmpty) {
            HStack(spacing: 0) {
                Text(lyric.lyric)
                    .font(viewConfig.mainFontSize)
                    .bold()
                    .multilineTextAlignment(.leading)
                    .foregroundColor(isHighlight ? viewConfig.mainFontColor : viewConfig.mainFontColor.opacity(0.7))
                    .blur(radius: blurRadius)
                    .scaleEffect(isHighlight ? 1 : 0.88, anchor: viewConfig.fontAnchor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isClick ? viewConfig.mainFontColor.opacity(0.3) : Color.clear)
                            .scaleEffect(isHighlight ? 1 : 0.88, anchor: viewConfig.fontAnchor)
                    )
                    .onTapGesture {
                        onSeek?(lyric.time)
                        withAnimation(.easeOut(duration: 0.3)) {
                            isClick = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isClick = false
                            }
                        }
                    }
                    .onChange(of: lrcHightlightCellIndex) { oldValue, newValue in
                        if (oldValue == lyric.indexNum) {
                            withAnimation(.spring()) {
                                self.isHighlight = false
                                updateBlurRadius()
                            }
                            return
                        }
                        if (newValue == lyric.indexNum) {
                            withAnimation(.spring()) {
                                self.isHighlight = true
                                updateBlurRadius()
                            }
                            return
                        }
                    }
                    .onChange(of: isScrollViewGestrueScroll) { _, _ in
                        withAnimation(.spring()) {
                            updateBlurRadius()
                        }
                    }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 2)
            
        } else {
            EmptyView().frame(height: 12)
        }
    }
    
    private func updateBlurRadius() {
        blurRadius = isHighlight ? 0 : (isScrollViewGestrueScroll ? 0.5 : 1.2)
    }
}
