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

import SwiftUI
import UIKit

@objc class TerminalWindow: UIView, UITextViewDelegate {
    @objc let id: UUID = UUID()
    @objc var terminalText: UITextView = UITextView()
    @objc var capturedInput: String = ""
    @objc var input: (String) -> Void = { _ in }
    @objc var deletion: (String) -> Void = { _ in }
    @objc var refreshcolor: (UIColor) -> Void = { _ in }
    @objc var name: String = "Serial"

    @objc func setInput(new: @escaping (String) -> Void) {
        input = new
    }

    @objc func setDeletion(new: @escaping (String) -> Void) {
        deletion = new
    }
    
    @objc func safetyAlert(semaphore: DispatchSemaphore) -> Void {        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let keyWindow = windowScene.keyWindow,
                let rootViewController = keyWindow.rootViewController else {
            return
        }

        let alertController = UIAlertController(title: "Warning", message: "Script wants to disable safety checks which could lead to the crash of the app and uncontrolled behaviour\n", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            setFJSafety(true)
            semaphore.signal()
        }))
        
        alertController.addAction(UIAlertAction(title: "Proceed", style: .default, handler: { _ in
            setFJSafety(false)
            semaphore.signal()
        }))
        
        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }
        topController.present(alertController, animated: true, completion: nil)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        terminalText.frame = self.bounds
        terminalText.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        terminalText.text = ""
        terminalText.backgroundColor = .clear
        terminalText.isEditable = true
        terminalText.font = UIFont.monospacedSystemFont(ofSize: 10.0, weight: .semibold)
        terminalText.delegate = self
        terminalText.keyboardType = .asciiCapable
        terminalText.textContentType = .none
        terminalText.smartQuotesType = .no
        terminalText.smartDashesType = .no
        terminalText.smartInsertDeleteType = .no
        terminalText.autocorrectionType = .no
        terminalText.autocapitalizationType = .none
        //terminalText.layoutManager.allowsNonContiguousLayout = true
        terminalText.layer.shouldRasterize = true
        terminalText.layer.rasterizationScale = UIScreen.main.scale
        terminalText.isUserInteractionEnabled = true
        //terminalText.layoutManager.addTextContainer(terminalText.textContainer)
        //terminalText.layoutManager.ensureLayout(for: terminalText.textContainer)
        terminalText.isUserInteractionEnabled = false
        self.addSubview(terminalText)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText string: String) -> Bool {
        if string.isEmpty {
            deletion(string)
        } else {
            input(string)
        }
        return false
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if self.window != nil {
            DispatchQueue.main.async {
                self.terminalText.becomeFirstResponder()
            }
        }
    }
}
