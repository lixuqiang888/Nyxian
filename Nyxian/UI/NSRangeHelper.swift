/*
 MIT License

 Copyright (c) 2025 SeanIsTethered

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import UIKit

func findRanges(of word: String, in text: String) -> [NSRange] {
    let nsText = NSString(string: text)
    var ranges: [NSRange] = []

    var searchRange = NSRange(location: 0, length: nsText.length)

    while true {
        let range = nsText.range(of: word, options: [], range: searchRange)

        if range.location == NSNotFound {
            break
        }

        ranges.append(range)

        let newLocation = range.location + range.length
        searchRange = NSRange(location: newLocation, length: nsText.length - newLocation)
    }

    return ranges
}

func setSelectedTextRange(for textView: UITextView, with askedRange: NSRange) {
    guard let text = textView.text,
          askedRange.location != NSNotFound,
          askedRange.location + askedRange.length <= text.count else {
        return
    }

    let caretRange = NSRange(location: askedRange.location + askedRange.length, length: 0)

    let startPosition = textView.position(from: textView.beginningOfDocument, offset: caretRange.location)
    let endPosition = textView.position(from: startPosition!, offset: 0)

    let textRange = textView.textRange(from: startPosition!, to: endPosition!)
    textView.selectedTextRange = textRange
}

func visualRangeRect(in textView: UITextView, for textRange: NSRange) -> CGRect? {
    guard textRange.location != NSNotFound,
          textRange.location + textRange.length <= textView.textStorage.length else {
          return nil
    }

    let layoutManager = textView.layoutManager
    let textContainer = textView.textContainer
    let glyphRange = layoutManager.glyphRange(forCharacterRange: textRange, actualCharacterRange: nil)

    var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

    rect.origin.x += textView.textContainerInset.left
    rect.origin.y += textView.textContainerInset.top

    return rect
}
