# AMLLyricView-SwiftUI (AppleMusic Like Lyric View - SwiftUI)
A demo package for LyricView 'a little bit' like AppleMusic style.
一个基于SwiftUI的歌词滚动显示页面

### Installation 安装
[Swift Package Manager](https://github.com/lycliyichao/AMLLyricView-SwiftUI.git), which is the recommended option.
推荐使用SPM

### Minimum Requirements 最低版本需求
iOS v17 (by using SwiftUI, also support iPadOS and macOS(designed for iPad))
由于基于最新版本iOS 17 .onChange的API，因此当前为iOS v17开始支持，SwiftUI的强大特性理论上也可以在iPadOS和macOS(Design for iPad)工作。

### How to use 如何使用
```Swift
@State private var playedTime   : Double            // Current Song's Played-Time by your MusicPlayer :)
@State private var lrcConfig    : AAMLLrcConfig?    // LrcConfig
...

// in some View
AMLLView(playedTime: $playedTime, lrcConfig: $lrcConfig, viewConfig: viewConfig(optional)) { seekTime in
    // seek ～～～～
}
.frame() // —— the size you want
... // other you want

// playedTime and lrcConfig are worked with binding, so when you change the song, it can also change the lyrics with the config change.

```
Config: 配置设置:
```Swift
AAMLLrcConfig :
    lrcType      : LyricsType       // -> .lrc / .ttml(future)
    lrcURLType   : LyricURLType     // -> .remote / .local
    lrcURL       : URL              
    coderType    : String.Encoding  // default : .utf8
```
```Swift
AAMLViewConfig :
    isCloseDefaultScroll : Bool         // default = false; when choosed false -> the scrollview is based on it's own scroll behaviour
                                        //                  when choosed true  -> the scrollview need longpress then scroll
    mainFontSize         : Font         // Lyric's Font
    mainFontColor        : Color        // Lyric's Font Color
    subFontSize          : Font         // Future for .ttml‘s sub font
    subFontColor         : Color        // Future for .ttml‘s sub font
    highlightAnchor      : UnitPoint    // The Visoion‘s center of the highlighted(current) Cell
    fontAnchor           : UnitPoint    // .leading / .center / .trading
    transformAnimation   : Animation    // Scroll AnimationType
```
The dynamics of this component completely depend on the value of ‘playedTime’.
该组件的动态完全取决于“playedTime”这个值。
Therefore, when you choose not to process ‘seektime’, the modified component will not actively reposition the lyrics.
因此当您选择不处理“seektime”的时候，改组件并不会主动对歌词进行重新定位。

### Next 下一步
The next version‘s goal is to add support for .ttml. 下一版本准备增加对.ttml的支持

