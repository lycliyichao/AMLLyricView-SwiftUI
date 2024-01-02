//
//  Type.swift
//  
//
//  Created by YICHAO LI on 2024/1/1.
//

import Foundation
import SwiftUI

public enum LyricsType {
    case lrc
    case ttml
}

public enum LyricURLType {
    case local
    case remote
}

public struct AAMLLrcConfig : Equatable {
    public var lrcType      : LyricsType
    public var lrcURLType   : LyricURLType
    public var lrcURL       : URL
    public var coderType    : String.Encoding

    public init(lrcType: LyricsType, lrcURLType: LyricURLType, lrcURL: URL, coderType: String.Encoding = .utf8) {
        self.lrcType = lrcType
        self.lrcURLType = lrcURLType
        self.lrcURL = lrcURL
        self.coderType = coderType
    }
}

public struct AAMLViewConfig {
    public var isCloseDefaultScroll : Bool
    public var mainFontSize         : Font
    public var mainFontColor        : Color
    public var subFontSize          : Font
    public var subFontColor         : Color
    public var highlightAnchor      : UnitPoint
    public var fontAnchor           : UnitPoint // .leading / .center / .trading
    public var transformAnimation   : Animation

    public init(isCloseDefaultScroll: Bool = false, mainFontSize: Font, mainFontColor: Color, subFontSize: Font, subFontColor: Color, highlightAnchor: UnitPoint, fontAnchor: UnitPoint, transformAnimation: Animation) {
        self.isCloseDefaultScroll = isCloseDefaultScroll
        self.mainFontSize = mainFontSize
        self.mainFontColor = mainFontColor
        self.subFontSize = subFontSize
        self.subFontColor = subFontColor
        self.highlightAnchor = highlightAnchor
        self.fontAnchor = fontAnchor
        self.transformAnimation = transformAnimation
    }
}

public let defaultAAMLViewConfig =  AAMLViewConfig(isCloseDefaultScroll: false,
                                                   mainFontSize: .title,
                                                   mainFontColor: .primary.opacity(0.8),
                                                   subFontSize: .caption2,
                                                   subFontColor: .primary.opacity(0.8),
                                                   highlightAnchor: UnitPoint(x: 0.5, y: 0.08),
                                                   fontAnchor: .leading,
                                                   transformAnimation: .easeInOut)

public class LrcLyric: Identifiable {
    public var indexNum: Int
    public var lyric: String
    public var time: Double

    init(lyric: String, indexNum: Int, time: Double) {
        self.lyric = lyric
        self.indexNum = indexNum
        self.time = time
    }
}

// Add GBK
extension String.Encoding {
    public static let gbk: String.Encoding = {
        let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        return String.Encoding(rawValue: gbkEncoding)
    }()
}

func loadGBKFile(fileURL: URL) -> String? {
    do {
        let data = try Data(contentsOf: fileURL)
        if let gbkString = String(data: data, encoding: .gbk) {
            return gbkString
        }
    } catch {
        print("Error loading file: \(error)")
    }

    return nil
}
