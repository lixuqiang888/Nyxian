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

import AudioToolbox
import SwiftUI
import UIKit
import Foundation
import Runestone
import TreeSitterJavaScript
import TreeSitterC
import TreeSitterPython
import TreeSitterLua
import TreeSitterXML
import TreeSitterHTML

enum HighlightName: String {
    case comment
    case constantBuiltin = "constant.builtin"
    case constantCharacter = "constant.character"
    case constructor
    case function
    case keyword
    case number
    case `operator`
    case property
    case punctuation
    case string
    case type
    case variable
    case variableBuiltin = "variable.builtin"
    case tag

    init?(_ rawHighlightName: String) {
        var comps = rawHighlightName.split(separator: ".")
        while !comps.isEmpty {
            let candidateRawHighlightName = comps.joined(separator: ".")
            if let highlightName = Self(rawValue: candidateRawHighlightName) {
                self = highlightName
                return
            }
            comps.removeLast()
        }
        return nil
    }
}

class NyxianTheme: Theme {
    let fontSize: CGFloat = CGFloat(UserDefaults.standard.double(forKey: "CEFontSize"))
    
    let font: UIFont = UIFont.monospacedSystemFont(ofSize: CGFloat(UserDefaults.standard.double(forKey: "CEFontSize")), weight: .medium)
    
    var lineNumberFont: UIFont {
        return UIFont.monospacedSystemFont(ofSize: fontSize * 0.85, weight: .regular)
    }
    
    var textColor: UIColor
    var backgroundColor: UIColor
    
    var gutterBackgroundColor: UIColor
    var gutterHairlineColor: UIColor
    
    var lineNumberColor: UIColor
    
    var selectedLineBackgroundColor: UIColor
    var selectedLinesLineNumberColor: UIColor
    var selectedLinesGutterBackgroundColor: UIColor
    
    var invisibleCharactersColor: UIColor
    
    var pageGuideHairlineColor: UIColor
    var pageGuideBackgroundColor: UIColor
    
    var markedTextBackgroundColor: UIColor
    
    let colorKeyword: UIColor
    let colorComment: UIColor
    let colorString: UIColor
    let colorNumber: UIColor
    let colorRegex: UIColor
    let colorFunction: UIColor
    let colorOperator: UIColor
    let colorProperty: UIColor
    let colorPunctuation: UIColor
    let colorDirective: UIColor
    let colorType: UIColor
    let colorConstantBuiltin: UIColor
    
    init() {
        let userInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
        
        if userInterfaceStyle == .light {
            // Light Mode Colors (VSCode Light+ Pro inspired)
            backgroundColor = neoRGB(250, 250, 250)
            textColor = neoRGB(30, 30, 30)
            
            gutterBackgroundColor = neoRGB(240, 240, 240)
            gutterHairlineColor = neoRGB(220, 220, 220)
            lineNumberColor = neoRGB(180, 180, 180)
            
            selectedLineBackgroundColor = neoRGB(220, 230, 250)
            selectedLinesLineNumberColor = neoRGB(80, 120, 180)
            selectedLinesGutterBackgroundColor = neoRGB(235, 235, 240)
            
            pageGuideHairlineColor = neoRGB(220, 220, 230)
            pageGuideBackgroundColor = neoRGB(245, 245, 250)
            markedTextBackgroundColor = neoRGB(230, 240, 250)
            
            colorKeyword = neoRGB(0, 0, 192)         // Deep blue
            colorComment = neoRGB(0, 128, 0)         // Green
            colorString = neoRGB(163, 21, 21)        // Red
            colorNumber = neoRGB(128, 0, 128)        // Purple
            colorRegex = neoRGB(255, 140, 0)         // Orange
            colorFunction = neoRGB(43, 145, 175)     // Teal-blue
            colorOperator = neoRGB(0, 0, 0)          // Black
            colorProperty = neoRGB(0, 0, 128)        // Navy blue
            colorPunctuation = neoRGB(50, 50, 50)    // Dark gray for punctuation
            colorDirective = neoRGB(60, 60, 60)      // Dark gray directive
            colorType = neoRGB(43, 43, 150)          // Type
            colorConstantBuiltin = neoRGB(75, 0, 130)
        } else {
            // Dark Mode Colors (VSCode Dark+ Pro inspired)
            backgroundColor = neoRGB(30, 30, 30)
            textColor = neoRGB(232, 242, 255)
            
            gutterBackgroundColor = neoRGB(25, 25, 25)
            gutterHairlineColor = neoRGB(50, 50, 50)
            lineNumberColor = neoRGB(90, 90, 90)
            
            selectedLineBackgroundColor = neoRGB(40, 44, 52)
            selectedLinesLineNumberColor = neoRGB(130, 180, 255)
            selectedLinesGutterBackgroundColor = neoRGB(20, 20, 25)
            
            pageGuideHairlineColor = neoRGB(45, 45, 50)
            pageGuideBackgroundColor = neoRGB(30, 30, 35)
            markedTextBackgroundColor = neoRGB(60, 60, 70)
            
            colorKeyword = neoRGB(86, 156, 214)      // Blue
            colorComment = neoRGB(106, 153, 85)      // Green
            colorString = neoRGB(206, 145, 120)      // Orange
            colorNumber = neoRGB(181, 206, 168)      // Soft green
            colorRegex = neoRGB(255, 198, 109)       // Yellow-orange
            colorFunction = neoRGB(220, 220, 170)    // Pale yellow
            colorOperator = neoRGB(212, 212, 212)    // Light gray
            colorProperty = neoRGB(156, 220, 254)    // Cyan
            colorPunctuation = neoRGB(200, 200, 200)
            colorDirective = neoRGB(255, 165, 0)     // Orange directive
            colorType = neoRGB(78, 201, 176)         // Type
            colorConstantBuiltin = neoRGB(0, 255, 255)
        }
        
        invisibleCharactersColor = textColor.withAlphaComponent(0.25)
    }
    
    func textColor(for highlightName: String) -> UIColor? {
        guard let highlightName = HighlightName(highlightName) else {
            return nil
        }
        switch highlightName {
        case .keyword:
            return colorKeyword
        case .constantBuiltin:
            return colorConstantBuiltin
        case .number:
            return colorNumber
        case .comment:
            return colorComment
        case .operator:
            return colorOperator
        case .string:
            return colorString
        case .function, .variable:
            return colorFunction
        case .property:
            return colorProperty
        case .punctuation:
            return colorPunctuation
        case .type:
            return colorType
        case .tag:
            return colorString
        default:
            return textColor
        }
    }
}

struct NeoEditorHelper: View {
    @Binding var isPresented: Bool
    @Binding var filepath: String
    @State var ready: Bool = false

    var body: some View {
        Group {
            if ready {
                NavigationBarViewControllerRepresentable(isPresented: $isPresented, filepath: filepath)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            ready = true
        }
    }
}

// caches for toolbar v2
var highlightLayerCache: [CAShapeLayer] = []
var toolbarItemCache: [UIBarButtonItem] = []

struct NavigationBarViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var filepath: String

    var title: String
    var backgroundColor: UIColor = UIColor.systemGray6
    var tintColor: UIColor = UIColor.label

    let textView: TextView = TextView()//CustomTextView()

    private var filename: String

    init(
        isPresented: Binding<Bool>,
        filepath: String
    ) {
        _isPresented = isPresented
        self.filepath = filepath
        self.filename = {
            let fileURL = URL(fileURLWithPath: filepath)
            return fileURL.lastPathComponent
        }()
        self.title = filename
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let hostingController = UIHostingController(rootView: NeoEditor(filename: filepath, textView: textView))
        
        let userInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            hostingController.view.backgroundColor = neoRGB(255, 255, 255)
        } else {
            hostingController.view.backgroundColor = neoRGB(31, 31, 36)
        }
        
        let navigationController = UINavigationController(rootViewController: hostingController)
        let navigationBar = navigationController.navigationBar
        navigationBar.prefersLargeTitles = false
        navigationBar.backgroundColor = backgroundColor
        navigationBar.tintColor = tintColor

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: tintColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: tintColor]

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance

        let saveButton = ClosureBarButtonItem(title: "Save", style: .plain) {
            let fileURL = URL(fileURLWithPath: filepath)
            do {
                try textView.text.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
            }
        }

        let closeButton = ClosureBarButtonItem(title: "Close", style: .plain) {
            textView.endEditing(true)
            isPresented = false
        }

        hostingController.navigationItem.rightBarButtonItem = saveButton
        hostingController.navigationItem.leftBarButtonItem = closeButton

        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        uiViewController.navigationBar.topItem?.title = title
        uiViewController.navigationBar.backgroundColor = backgroundColor
        uiViewController.navigationBar.tintColor = tintColor
    }
}

struct NeoEditor: UIViewRepresentable {
    private var filename: String
    private var textView: TextView
    private let toolbar: UIToolbar
    
    @AppStorage("CEToolbar") var toolbarenabled: Bool = true
    @AppStorage("CEShowLines") var showlines: Bool = true
    @AppStorage("CEShowTab") var showtab: Bool = true
    @AppStorage("CEShowSpace") var showspace: Bool = true
    @AppStorage("CEWrapLines") var wraplines: Bool = true
    @AppStorage("CEShowReturn") var showreturn: Bool = true
    
    @AppStorage("CEDEFAULTTAB") var deftab: Bool = true
    @AppStorage("CEDEFAULTSPACE") var defspace: Bool = true
    @AppStorage("CEDEFAULTRETURN") var defreturn: Bool = true
    
    @AppStorage("CETab") var tab: String = ""
    @AppStorage("CESpace") var space: String = ""
    @AppStorage("CERETURN") var ret: String = ""
    
    init(filename: String, textView: TextView) {
        self.filename = filename
        self.textView = textView
        toolbar = UIToolbar()
    }
    
    func makeUIView(context: Context) -> some UIView {
        let text = {
            do {
                return try String(contentsOfFile: filename)
            } catch {
                return ""
            }
        }()
        textView.text = text
        
        let userInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
        
        if userInterfaceStyle == .light {
            textView.backgroundColor = neoRGB(255, 255, 255)
        } else {
            textView.backgroundColor = neoRGB(31, 31, 36)
        }
        
        textView.showLineNumbers = showlines
        textView.lineSelectionDisplayType = .line
        textView.showTabs = showtab
        textView.showSpaces = showspace
        textView.showLineBreaks = showreturn
        textView.showSoftLineBreaks = showreturn
        textView.lineHeightMultiplier = 1.3
        textView.keyboardType = .asciiCapable
        
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.isLineWrappingEnabled = wraplines
        textView.isUserInteractionEnabled = true
        textView.textContainerInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 0)
        
        if showtab {
            if !deftab {
                textView.tabSymbol = tab
            }
        }
        
        if showspace {
            if !defspace {
                textView.spaceSymbol = space
            }
        }
        
        if showreturn {
            if !defreturn {
                textView.lineBreakSymbol = ret
            }
        }
        
        // get suffix
        let suffix = gsuffix(from: filename)
        
        // code interpreter choosing switch
        switch(suffix)
        {
        case "nx", "nxm", "js":
            let highlightsQuery = TreeSitterLanguage.Query(contentsOf: URL(fileURLWithPath: "\(Bundle.main.bundlePath)/highlights.scm"))
            let injectionsQuery = TreeSitterLanguage.Query(contentsOf: URL(fileURLWithPath: "\(Bundle.main.bundlePath)/injections.scm"))
            let language = TreeSitterLanguage(tree_sitter_javascript(), highlightsQuery: highlightsQuery, injectionsQuery: injectionsQuery)
            let languageMode = TreeSitterLanguageMode(language: language)
            textView.setLanguageMode(languageMode)
            break
        case "c":
            let highlightsQuery = TreeSitterLanguage.Query(contentsOf: URL(fileURLWithPath: "\(Bundle.main.bundlePath)/c.scm"))
            let language = TreeSitterLanguage(tree_sitter_c(), highlightsQuery: highlightsQuery, injectionsQuery: nil)
            let languageMode = TreeSitterLanguageMode(language: language)
            textView.setLanguageMode(languageMode)
            break
        case "lua":
            let highlightsQuery = TreeSitterLanguage.Query(contentsOf: URL(fileURLWithPath: "\(Bundle.main.bundlePath)/lua.scm"))
            let injectionsQuery = TreeSitterLanguage.Query(contentsOf: URL(fileURLWithPath: "\(Bundle.main.bundlePath)/lua_inj.scm"))
            let language = TreeSitterLanguage(tree_sitter_lua(), highlightsQuery: highlightsQuery, injectionsQuery: injectionsQuery)
            let languageMode = TreeSitterLanguageMode(language: language)
            textView.setLanguageMode(languageMode)
            break
        case "py":
            let highlightsQuery = TreeSitterLanguage.Query(contentsOf: URL(fileURLWithPath: "\(Bundle.main.bundlePath)/py.scm"))
            let language = TreeSitterLanguage(tree_sitter_python(), highlightsQuery: highlightsQuery, injectionsQuery: nil)
            let languageMode = TreeSitterLanguageMode(language: language)
            textView.setLanguageMode(languageMode)
            break
        case "xml","plist":
            let highlightsQuery = TreeSitterLanguage.Query(contentsOf: URL(fileURLWithPath: "\(Bundle.main.bundlePath)/xml.scm"))
            let language = TreeSitterLanguage(tree_sitter_xml(), highlightsQuery: highlightsQuery, injectionsQuery: nil)
            let languageMode = TreeSitterLanguageMode(language: language)
            textView.setLanguageMode(languageMode)
            break
        case "html":
            let highlightsQuery = TreeSitterLanguage.Query(contentsOf: URL(fileURLWithPath: "\(Bundle.main.bundlePath)/html.scm"))
            let injectionsQuery = TreeSitterLanguage.Query(contentsOf: URL(fileURLWithPath: "\(Bundle.main.bundlePath)/html_inj.scm"))
            let language = TreeSitterLanguage(tree_sitter_html(), highlightsQuery: highlightsQuery, injectionsQuery: injectionsQuery)
            let languageMode = TreeSitterLanguageMode(language: language)
            textView.setLanguageMode(languageMode)
            break
        default:
            break
        }
        
        textView.theme = NyxianTheme()
        
        if(toolbarenabled)
        {
            setupToolbar(textView: textView, exten: suffix)
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func spawnBarButton(title: String) -> UIBarButtonItem {
        let button = SymbolButton(symbolName: title, width: 28.0) {
            insertTextAtCurrentPosition(textView: textView, newText: title)
        }
        
        return UIBarButtonItem(customView: button)
    }
    
    func spawnSeperator() -> UIBarButtonItem {
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 5
        return fixedSpace
    }
    
    func setupToolbar(textView: TextView, exten: String) {
        toolbar.sizeToFit()
        
        var additionalButtons: [UIBarButtonItem] = []
        
        let tabButton = SymbolButton(symbolName: "arrow.right.to.line", width: 35.0) {
            insertTextAtCurrentPosition(textView: textView, newText: "\t")
        }
        
        switch(exten)
        {
            case "nx", "nxm", "js", "lua", "c":
                additionalButtons.append(spawnBarButton(title: "("))
                additionalButtons.append(spawnSeperator())
                additionalButtons.append(spawnBarButton(title: ")"))
                additionalButtons.append(spawnSeperator())
                additionalButtons.append(spawnBarButton(title: "{"))
                additionalButtons.append(spawnSeperator())
                additionalButtons.append(spawnBarButton(title: "}"))
                additionalButtons.append(spawnSeperator())
                additionalButtons.append(spawnBarButton(title: "["))
                additionalButtons.append(spawnSeperator())
                additionalButtons.append(spawnBarButton(title: "]"))
                additionalButtons.append(spawnSeperator())
                additionalButtons.append(spawnBarButton(title: ";"))
                break
            default:
                break
        }
        
        let hideButton = SymbolButton(symbolName: "keyboard.chevron.compact.down", width: 35.0) {
            textView.resignFirstResponder()
        }

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let flexibleSpace2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let tabBarButton = UIBarButtonItem(customView: tabButton)
        let hideBarButton = UIBarButtonItem(customView: hideButton)
        
        toolbar.items = [tabBarButton, flexibleSpace2] + additionalButtons + [flexibleSpace, hideBarButton]
        textView.inputAccessoryView = toolbar
    }
        
    func insertTextAtCurrentPosition(textView: TextView, newText: String) {
        if let selectedRange = textView.selectedTextRange {
            textView.replace(selectedRange, withText: newText)
        }
    }
}

class ClosureBarButtonItem: UIBarButtonItem {
    private var actionHandler: (() -> Void)?

    init(title: String?, style: UIBarButtonItem.Style, actionHandler: @escaping () -> Void) {
        self.actionHandler = actionHandler
        super.init()
        self.title = title
        self.style = style
        self.target = self
        self.tintColor = UIColor.label
        self.action = #selector(didTapButton)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc private func didTapButton() {
        actionHandler?()
    }
}

class SymbolButton: UIButton {
    private var actionHandler: (() -> Void)?
    private var currentAnimator: UIViewPropertyAnimator?
    
    init(symbolName: String, width: CGFloat, actionHandler: @escaping () -> Void) {
        self.actionHandler = actionHandler
        super.init(frame: .zero)
        
        let image = UIImage(systemName: symbolName)
        if image != nil {
            setImage(image, for: .normal)
        } else {
            setTitle(symbolName, for: .normal)
            titleLabel?.font = UIFont.systemFont(ofSize: 16)
            setTitleColor(.label, for: .normal)
        }
        
        tintColor = .label
        
        self.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
        
        layer.cornerRadius = 5
        
        let userInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
        
        if userInterfaceStyle == .light {
            backgroundColor = .systemGray5
        } else {
            backgroundColor = .systemGray6
        }
        
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: width),
            self.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc private func didTapButton() {
        actionHandler?()
        playKeyboardSound()
        triggerHapticFeedback()
    }
    
    private func playKeyboardSound() {
        AudioServicesPlaySystemSound(1104) // iOS keyboard tap sound
    }
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @objc private func touchDown() {
        // Interrupt any existing animation
        currentAnimator?.stopAnimation(true)
        
        // Create and start a new animation
        currentAnimator = UIViewPropertyAnimator(duration: 0.1, curve: .easeInOut) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        
        currentAnimator?.startAnimation()
    }
    
    @objc private func touchUp() {
        // Interrupt any existing animation
        currentAnimator?.stopAnimation(true)
        
        // Create and start a new animation to return to original state
        currentAnimator = UIViewPropertyAnimator(duration: 0.1, curve: .easeInOut) {
            self.transform = CGAffineTransform.identity
        }
        
        currentAnimator?.startAnimation()
    }
}


func neoRGB(_ red: CGFloat,_ green: CGFloat,_ blue: CGFloat ) -> UIColor {
    return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
}

func gsuffix(from fileName: String) -> String {
    let trimmedFileName = fileName.replacingOccurrences(of: " ", with: "")
    let suffix = URL(string: trimmedFileName)?.pathExtension
    return suffix ?? ""
}
