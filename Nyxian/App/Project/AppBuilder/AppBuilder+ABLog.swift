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

enum AL: Int {
    case msg = 0
    case suc = 1
    case err = 2
    case warn = 3
}

func ABLog(_ type: AL, _ message: String) {
    let escapecolor: String = {
        switch(type) {
        case AL.msg: // Message
            return "\u{001B}[94m"
        case AL.suc: // Success
            return "\u{001B}[32m"
        case AL.err: // Error
            return "\u{001B}[91m"
        case AL.warn: // Warning
            return "\u{001B}[33m"
        }
    }()
    
    let symbol: String = {
        switch(type) {
        case AL.msg: // Message
            return "[*] "
        case AL.suc: // Success
            return "[*] "
        case AL.err: // Error
            return "[!] "
        case AL.warn: // Warning
            return "[?] "
        }
    }()
    
    printfake("\(escapecolor)\(symbol)\(message.replacingOccurrences(of: "&", with: "\u{001B}[0m").replacingOccurrences(of: "§", with: escapecolor))\u{001B}[0m\n")
}
