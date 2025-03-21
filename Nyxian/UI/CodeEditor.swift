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

// MARK: Code Editor
import SwiftUI
import UIKit
import Foundation

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

// configuration for NeoEditor
struct NeoEditorConfig {
    var background: UIColor
    var selection: UIColor
    var current: UIColor
    var standard: UIColor
    var font: UIFont
}

// restore class
struct NavigationBarViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var filepath: String

    var title: String
    var backgroundColor: UIColor = UIColor.systemGray6
    var tintColor: UIColor = UIColor.label

    let textView: CustomTextView = CustomTextView()

    private var filename: String
    private let config: NeoEditorConfig = {
        let userInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle

        var meow: NeoEditorConfig = NeoEditorConfig(background: UIColor.clear, selection: UIColor.clear, current: UIColor.clear, standard: UIColor.clear, font: UIFont.systemFont(ofSize: 10.0))

        meow.font = UIFont.monospacedSystemFont(ofSize: CGFloat(UserDefaults.standard.double(forKey: "CEFontSize")), weight: UIFont.Weight.medium)

        if userInterfaceStyle == .light {
            meow.background = neoRGB(255, 255, 255)
            meow.selection = neoRGB(164, 205, 255)
            meow.current = neoRGB(232, 242, 255)
            meow.standard = UIColor.black
        } else {
            meow.background = neoRGB(31, 31, 36)
            meow.selection = neoRGB(81, 91, 112)
            meow.current = neoRGB(35, 37, 43)
            meow.standard = UIColor.white
        }

        return meow
    }()

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
        let hostingController = UIHostingController(rootView: NeoEditor(isPresented: $isPresented, filepath: filepath, textView: textView, config: config))
        hostingController.view.backgroundColor = config.background
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
            textView.endEditing(true)
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
    private let containerView: UIView
    private let textView: CustomTextView
    private let highlightRules: [HighlightRule]
    private let filepath: String
    private let filename: String
    private let toolbar: UIToolbar

    private let config: NeoEditorConfig

    @Binding private var sheet: Bool

    @AppStorage("CERender") var render: Double = 1.0
    @AppStorage("CEFontSize") var font: Double = 13.0
    @AppStorage("CEToolbar") var enableToolbar: Bool = true
    @AppStorage("CECurrentLineHighlighting") var current_line_highlighting: Bool = false
    @AppStorage("CEHighlightCache") var cachehighlightings: Bool = false

    init(
        isPresented: Binding<Bool>,
        filepath: String,
        textView: CustomTextView,
        config: NeoEditorConfig
    ) {
        _sheet = isPresented

        self.filepath = filepath
        self.filename = {
            let fileURL = URL(fileURLWithPath: filepath)
            return fileURL.lastPathComponent
        }()

        self.highlightRules = grule(gsuffix(from: filename))
        self.containerView = UIView()
        self.textView = textView
        self.toolbar = UIToolbar()
        self.config = config
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        textView.text = {
            do {
                return try String(contentsOfFile: filepath)
            } catch {
                sheet = false
                return ""
            }
        }()
        textView.delegate = context.coordinator
        context.coordinator.applyHighlighting(to: textView, with: NSRange(location: 0, length: textView.text.utf16.count))
        context.coordinator.runIntrospect(textView)

        textView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        textView.backgroundColor = config.background
        textView.tintColor = config.selection
        textView.textColor = config.standard
        textView.lineLight = config.current.cgColor
        if current_line_highlighting {
            textView.setupHighlightLayer()
        }
        textView.keyboardType = .asciiCapable
        textView.textContentType = .none
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.layoutManager.allowsNonContiguousLayout = true
        textView.layer.shouldRasterize = true
        textView.layer.rasterizationScale = UIScreen.main.scale * CGFloat(render)
        textView.isUserInteractionEnabled = true
        textView.layoutManager.addTextContainer(textView.textContainer)
        textView.layoutManager.ensureLayout(for: textView.textContainer)

        if enableToolbar {
            setupToolbar(textView: textView)
        }

        return containerView
    }

    func setupToolbar(textView: UITextView) {
        toolbar.sizeToFit()
        let tabButton = ClosureButton(title: "Tab") {
            insertTextAtCurrentPosition(textView: textView, newText: "\t")
        }

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let action1 = UIAction(title: "Go To Line", image: UIImage(systemName: "arrow.right")) { _ in
            toolbarItemCache = toolbar.items ?? []

            self.animateToolbarItemsDisappearance {
                let textField = UITextField()
                textField.text = ""
                textField.placeholder = "Line number to jump to"
                textField.borderStyle = .roundedRect
                textField.keyboardType = .asciiCapable
                textField.textContentType = .none
                textField.smartQuotesType = .no
                textField.smartDashesType = .no
                textField.smartInsertDeleteType = .no
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
                let doneButton = ClosureButton(title: "Cancel") {
                    self.animateToolbarItemsDisappearance {
                        self.restoreToolbarItems()
                    }
                }
                let gotoButton = ClosureButton(title: "Goto") {
                    guard let lineNumber = Int(textField.text ?? "n/a") else { return }
                    guard let textView = textView as? CustomTextView else { return }
                    guard let askedRange: NSRange = textView.rangeOfLine(lineNumber: lineNumber - 1) else { return }
                    guard let rect: CGRect = visualRangeRect(in: textView, for: askedRange) else { return }
                    setSelectedTextRange(for: textView, with: askedRange)
                    textView.scrollRangeToVisible(askedRange)
                    guard let highlight: CAShapeLayer = textView.addPath(color: UIColor.yellow.withAlphaComponent(0.3), rect: rect, entirePath: false, radius: 4.0) else { return }
                    let animation = CABasicAnimation(keyPath: "opacity")
                    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                    animation.fillMode = CAMediaTimingFillMode.forwards
                    animation.isRemovedOnCompletion = false
                    animation.fromValue = 1.0
                    animation.toValue = 0.0
                    animation.duration = 1.5
                    highlight.add(animation, forKey: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + animation.duration) {
                        highlight.removeFromSuperlayer()
                    }
                    self.animateToolbarItemsDisappearance {
                        self.restoreToolbarItems()
                    }
                }
                let doneBarButtonItem = UIBarButtonItem(customView: doneButton)
                let gotoBarButtonItem = UIBarButtonItem(customView: gotoButton)
                let textBarButtonItem = UIBarButtonItem(customView: textField)
                let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                restoreToolbarItems(with: [doneBarButtonItem, flexibleSpace, textBarButtonItem, flexibleSpace, gotoBarButtonItem])
            }
        }

        let action2 = UIAction(title: "Search String", image: UIImage(systemName: "magnifyingglass")) { _ in
            toolbarItemCache = toolbar.items ?? []
            self.animateToolbarItemsDisappearance {
                let textField = UITextField()
                textField.text = ""
                textField.placeholder = "String to search"
                textField.borderStyle = .roundedRect
                textField.keyboardType = .asciiCapable
                textField.textContentType = .none
                textField.smartQuotesType = .no
                textField.smartDashesType = .no
                textField.smartInsertDeleteType = .no
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
                let doneButton = ClosureButton(title: "Close") {
                    if !highlightLayerCache.isEmpty {
                        for item in highlightLayerCache {
                            item.removeFromSuperlayer()
                        }
                    }
                    self.animateToolbarItemsDisappearance {
                        self.restoreToolbarItems()
                    }
                }
                let searchButton = ClosureButton(title: "Search") {
                    guard let string = textField.text else { return }
                    guard let textView = textView as? CustomTextView else { return }
                    if !highlightLayerCache.isEmpty {
                        for item in highlightLayerCache {
                            item.removeFromSuperlayer()
                        }
                    }
                    let nsranges: [NSRange] = findRanges(of: string, in: textView.text)
                    for item in nsranges {
                        if let rect = visualRangeRect(in: textView, for: item) {
                            let layer = textView.addPath(color: UIColor.yellow.withAlphaComponent(0.3), rect: rect, entirePath: false, radius: 4.0)
                            if let layer = layer {
                                highlightLayerCache.append(layer)
                            }
                        }
                    }
                }
                let doneBarButtonItem = UIBarButtonItem(customView: doneButton)
                let gotoBarButtonItem = UIBarButtonItem(customView: searchButton)
                let textBarButtonItem = UIBarButtonItem(customView: textField)
                let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                restoreToolbarItems(with: [doneBarButtonItem, flexibleSpace, textBarButtonItem, flexibleSpace, gotoBarButtonItem])
            }
        }

        let menu = UIMenu(title: "Tools", children: [action2, action1])
        let menuButton = UIButton(type: .system)
        menuButton.tintColor = UIColor.label
        menuButton.setTitle("Tools", for: .normal)
        menuButton.menu = menu
        menuButton.showsMenuAsPrimaryAction = true
        let menuBarButtonItem = UIBarButtonItem(customView: menuButton)
        let TabBarButtonItem = UIBarButtonItem(customView: tabButton)
        toolbar.items = [TabBarButtonItem, flexibleSpace, menuBarButtonItem]
        textView.inputAccessoryView = toolbar
    }

    func animateToolbarItemsDisappearance(completion: @escaping () -> Void) {
        guard let items = toolbar.items else { return }
        let fadeOutDuration: TimeInterval = 0.3
        UIView.animate(withDuration: fadeOutDuration, animations: {
            for item in items {
                item.customView?.alpha = 0.0
            }
        }) { _ in
            self.toolbar.items = []
            completion()
        }
    }

    func restoreToolbarItems(with cache: [UIBarButtonItem] = toolbarItemCache) {
        toolbar.items = cache
        guard let items = toolbar.items else { return }
        let fadeInDuration: TimeInterval = 0.3
        for item in items {
            item.customView?.alpha = 0.0
        }
        UIView.animate(withDuration: fadeInDuration) {
            for item in items {
                item.customView?.alpha = 1.0
            }
        }
    }

    func insertTextAtCurrentPosition(textView: UITextView, newText: String) {
        if let selectedRange = textView.selectedTextRange {
            textView.replace(selectedRange, withText: newText)
        }
    }

    func updateUIView(_ uiView: UIView, context: Context) { }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: NeoEditor
        private var highlightCache: [NSRange: [NSAttributedString.Key: Any]] = [:]

        init(_ markdownEditorView: NeoEditor) {
            self.parent = markdownEditorView
        }

        func runIntrospect(_ textView: UITextView) {
            textView.font = parent.config.font
        }

        func textViewDidChange(_ textView: UITextView) {
            guard let textView = textView as? CustomTextView else { return }

            if textView.didPasted {
                self.applyHighlighting(to: textView, with: NSRange(location: 0, length: textView.text.utf16.count))
                textView.didPasted = false
            } else {
                self.applyHighlighting(to: textView, with: textView.cachedLineRange ?? NSRange(location: 0, length: 0))
            }
        }

        func applyHighlighting(to textView: UITextView, with visibleRange: NSRange) {
            let text = textView.text ?? ""

            DispatchQueue.global(qos: .userInitiated).async {
                var attributesToApply = [(NSRange, NSAttributedString.Key, Any)]()
                self.parent.highlightRules.forEach { rule in
                    let matches = rule.pattern.matches(in: text, options: [], range: visibleRange)
                    matches.forEach { match in
                        let matchRange = match.range
                        if let cachedAttributes = self.highlightCache[matchRange] {
                            for (key, value) in cachedAttributes {
                                attributesToApply.append((matchRange, key, value))
                            }
                            return
                        }
                        let isOverlapping = attributesToApply.contains { (range, _, _) in
                            NSIntersectionRange(range, matchRange).length > 0
                        }
                        guard !isOverlapping else { return }
                        rule.formattingRules.forEach { formattingRule in
                            guard let key = formattingRule.key,
                                  let calculateValue = formattingRule.calculateValue else { return }
                            if let matchRangeStr = Range(match.range, in: text) {
                                let matchContent = String(text[matchRangeStr])
                                let value = calculateValue(matchContent, matchRangeStr)
                                if self.parent.cachehighlightings {
                                    self.highlightCache[matchRange] = [key: value]
                                }
                                attributesToApply.append((match.range, key, value))
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    textView.textStorage.beginEditing()
                    textView.textStorage.addAttribute(.foregroundColor, value: self.parent.config.standard, range: visibleRange)
                    attributesToApply.forEach { (range, key, value) in
                        textView.textStorage.addAttribute(key, value: value, range: range)
                    }
                    textView.textStorage.endEditing()
                }
            }
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            guard let textView = textView as? CustomTextView else { return }
            textView.enableHighlightLayer()
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            guard let textView = textView as? CustomTextView else { return }
            textView.disableHighlightLayer()
        }
    }
}

class CustomTextView: UITextView {
    var didPasted: Bool = false
    var lineLight: CGColor = UIColor.clear.cgColor

    private(set) var hightlight_setuped: Bool = false
    private(set) var cachedLineRange: NSRange?
    private var wempty: Bool = false
    private let highlightLayer = CAShapeLayer()
    var highlightTMPLayer: [CAShapeLayer] = []
    var buttonTMPLayer: [UIButton] = []

    override func paste(_ sender: Any?) {
        didPasted = true
        super.paste(sender)
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        let caretRect = super.caretRect(for: position)
        updateCurrentLineRange()
        return caretRect
    }

    func setupHighlightLayer() {
        highlightLayer.fillColor = lineLight
        layer.insertSublayer(highlightLayer, at: 0)
        hightlight_setuped = true
    }

    private func updateCurrentLineRange() {
        guard let caretPosition = selectedTextRange?.start else {
            return
        }

        let caretIndex = offset(from: beginningOfDocument, to: caretPosition)
        let text = self.text as NSString
        let lineRange = text.lineRange(for: NSRange(location: caretIndex, length: 0))

        cachedLineRange = lineRange

        if hightlight_setuped {
            updateHighlightLayer()
        }
    }

    private func updateHighlightLayer() {
        guard let currentLineRange = cachedLineRange else {
            highlightLayer.path = nil
            return
        }

        let path = UIBezierPath()

        layoutManager.enumerateLineFragments(forGlyphRange: currentLineRange) { (rect, usedRect, _, glyphRange, _) in
            let textRect = usedRect.offsetBy(dx: self.textContainerInset.left, dy: self.textContainerInset.top)
            path.append(UIBezierPath(roundedRect: textRect, cornerRadius: 4.0))
        }

        animateHighlightLayer(from: highlightLayer.path, to: path.cgPath)

        highlightLayer.path = path.cgPath
    }

    private func animateHighlightLayer(from oldPath: CGPath?, to newPath: CGPath) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 0.25

        animation.toValue = newPath
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false

        if newPath.boundingBox.isEmpty && !wempty {
            animation.keyPath = "opacity"
            animation.fromValue = 1.0
            animation.toValue = 0.0
            animation.duration = 0.50
            wempty = true
            highlightLayer.add(animation, forKey: nil)
        } else if wempty && !newPath.boundingBox.isEmpty {
            animation.keyPath = "opacity"
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.duration = 0.50
            wempty = false
        }

        if wempty {
            return
        }

        highlightLayer.add(animation, forKey: nil)
    }

    func enableHighlightLayer() {
        if hightlight_setuped {
            setupHighlightLayer()
        }
    }

    func disableHighlightLayer() {
        if hightlight_setuped {
            highlightLayer.removeFromSuperlayer()
        }
    }

    func rangeOfLine(lineNumber: Int) -> NSRange? {
        let nsString = self.text as NSString
        let lines = nsString.components(separatedBy: .newlines)
        guard lineNumber >= 0 && lineNumber < lines.count else {
            return nil
        }
        var location = 0
        for i in 0..<lineNumber {
            location += (lines[i] as NSString).length + 1
        }
        let length = (lines[lineNumber] as NSString).length
        return NSRange(location: location, length: length)
    }

    func addPath(color: UIColor, rect: CGRect, entirePath: Bool? = nil, radius: CGFloat? = 0.0) -> CAShapeLayer? {
        let newHighlightLayer = CAShapeLayer()
        newHighlightLayer.fillColor = color.cgColor
        layer.insertSublayer(newHighlightLayer, at: 1)

        let path = UIBezierPath()
        var newRect: CGRect = rect

        if let entirePath = entirePath {
            if entirePath {
                newRect.size.width = UIScreen.main.bounds.size.width
            }
        } else {
            newRect.size.width = UIScreen.main.bounds.size.width
        }

        path.append(UIBezierPath(roundedRect: newRect, cornerRadius: radius ?? 0.0))

        newHighlightLayer.path = path.cgPath
        highlightTMPLayer.append(newHighlightLayer)

        return newHighlightLayer
    }

    func addAnimatedPath(color: UIColor, rect: CGRect, entirePath: Bool? = nil, radius: CGFloat? = 0.0) -> CAShapeLayer? {
        let newHighlightLayer = CAShapeLayer()
        newHighlightLayer.fillColor = color.cgColor
        layer.insertSublayer(newHighlightLayer, at: 1)

        let path = UIBezierPath()
        var newRect: CGRect = rect

        if let entirePath = entirePath {
            if entirePath {
                newRect.size.width = UIScreen.main.bounds.size.width
                newRect.origin.x = 0
            }
        } else {
            newRect.size.width = UIScreen.main.bounds.size.width
            newRect.origin.x = 0
        }

        path.append(UIBezierPath(roundedRect: newRect, cornerRadius: radius ?? 0.0))

        newHighlightLayer.path = path.cgPath
        newHighlightLayer.opacity = 0.1
        highlightTMPLayer.append(newHighlightLayer)

        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.fromValue = 0.0
        animation.toValue = 1.0
        newHighlightLayer.add(animation, forKey: nil)

        return newHighlightLayer
    }

    func highlightLine(at lineNumber: Int, with color: UIColor, with text: String, with symbol: String) {
        guard let range = rangeOfLine(lineNumber: lineNumber) else { return }
        guard let rect = visualRangeRect(in: self, for: range) else { return }

        _ = addAnimatedPath(color: color.withAlphaComponent(0.3), rect: rect)

        let lineRect: CGRect = rect

        var button: UIButton = UIButton()
        button = ClosureButton(title: "") {
            let uiView: UIView = UIView()
            uiView.backgroundColor = UIColor.systemGray6
            uiView.frame = CGRect(x: (UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 2.25)) - (self.font?.pointSize ?? 0.0), y: lineRect.midY - ((self.font?.pointSize ?? 0.0) / 2), width: (UIScreen.main.bounds.width / 2.25) + (self.font?.pointSize ?? 0.0), height: 100)
            uiView.layer.cornerRadius = 15
            uiView.layer.borderWidth = 1
            uiView.layer.borderColor = color.cgColor
            uiView.clipsToBounds = true
            let dissmissButton: UIButton = ClosureButton(title: "") {
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                    uiView.alpha = 0.0
                }, completion: { finished in
                    if finished {
                        uiView.removeFromSuperview()
                    }
                })
            }
            dissmissButton.frame = CGRect(x: uiView.bounds.width - 30 , y: 10, width: 15, height: 15)
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
            let image = UIImage(systemName: "xmark.circle", withConfiguration: symbolConfig)
            dissmissButton.setImage(image, for: .normal)
            dissmissButton.tintColor = UIColor.label
            let issueLabel: UILabel = PaddedLabel()
            issueLabel.frame = CGRect(x: 10, y: dissmissButton.frame.maxY + 10, width: uiView.bounds.width - 20, height: (uiView.bounds.height - dissmissButton.bounds.height) - 30)
            issueLabel.backgroundColor = UIColor.systemBackground
            issueLabel.layer.cornerRadius = 10
            issueLabel.layer.borderWidth = 1
            issueLabel.layer.borderColor = color.withAlphaComponent(0.5).cgColor
            issueLabel.clipsToBounds = true
            issueLabel.numberOfLines = 0
            issueLabel.font = self.font?.withSize(CGFloat((self.font?.pointSize ?? 0.0) / 1.5))
            issueLabel.text = text
            uiView.addSubview(dissmissButton)
            uiView.addSubview(issueLabel)
            uiView.alpha = 0.0
            self.addSubview(uiView)
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                uiView.alpha = 1.0
            }, completion: nil)
        }
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let image = UIImage(systemName: symbol, withConfiguration: symbolConfig)
        button.setImage(image, for: .normal)
        button.tintColor = color
        button.backgroundColor = .clear
        button.frame = CGRect(x: (UIScreen.main.bounds.width - 5) - (font?.pointSize ?? 0.0), y: lineRect.midY - ((font?.pointSize ?? 0.0) / 2), width: font?.pointSize ?? 0.0, height: font?.pointSize ?? 0.0)
        self.addSubview(button)
        bringSubviewToFront(button)
        buttonTMPLayer.append(button)
    }

    var onLayoutCompletion: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutCompletion?()
        onLayoutCompletion = nil
    }

    func setLayoutCompletionHandler(_ handler: @escaping () -> Void) {
        self.onLayoutCompletion = handler
    }
}

class PaddedLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
}

struct TextFormattingRule {
   typealias AttributedKeyCallback = (String, Range<String.Index>) -> Any

   let key: NSAttributedString.Key?
   let calculateValue: AttributedKeyCallback?

   init(key: NSAttributedString.Key, value: Any) {
       self.init(key: key, calculateValue: { _, _ in value })
   }

   init(
       key: NSAttributedString.Key? = nil,
       calculateValue: AttributedKeyCallback? = nil
   ) {
       self.key = key
       self.calculateValue = calculateValue
   }
}

struct HighlightRule {
   let pattern: NSRegularExpression

   let formattingRules: [TextFormattingRule]

   init(pattern: NSRegularExpression, formattingRules: [TextFormattingRule]) {
       self.pattern = pattern
       self.formattingRules = formattingRules
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

class ClosureButton: UIButton {
    private var actionHandler: (() -> Void)?

    init(title: String, actionHandler: @escaping () -> Void) {
        self.actionHandler = actionHandler
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        self.setTitleColor(.label, for: .normal)
        self.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        self.tintColor = UIColor.label
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc private func didTapButton() {
        actionHandler?()
    }
}

func grule(_ isaythis: String) -> [HighlightRule] {
    let userInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle

    let color1: UIColor = (userInterfaceStyle == .light) ? neoRGB(155, 35, 147) : neoRGB(252, 95, 163)          // Keywords
    let color5: UIColor = (userInterfaceStyle == .light) ? neoRGB(93, 108, 121) : neoRGB(108, 121, 134)         // Comments
    let color6: UIColor = (userInterfaceStyle == .light) ? neoRGB(196, 26, 22)  : neoRGB(252, 106, 93)          // Strings
    let color8: UIColor = (userInterfaceStyle == .light) ? neoRGB(15, 104, 160) : neoRGB(65, 161, 192)          // Function/Variable names

    switch(isaythis) {
        case "nx":
            return [
                HighlightRule(pattern: try! NSRegularExpression(pattern: "(//.*|\\/\\*[\\s\\S]*?\\*\\/)", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color5)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<!\\/\\/)(<(.*?)>)", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color6)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<!\\/\\/)(\"(.*?)\")", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color6)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(function|if|else|for|while|do|switch|case|default|break|continue|return|var|let|const|class|constructor|this|super|new|extends|static|null|undefined|true|false|try|catch|finally|throw|debugger|import|export|in|instanceof|await|async|yield|enum|implements|interface|let|package|private|protected|public|static)\\b", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color1)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b\\w+(?=(\\())", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color8)
                ])
            ]
        default:
            return []
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
