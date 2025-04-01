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

import UIKit

let generator = UINotificationFeedbackGenerator()

//Haptic Feedback
func haptfeedback(_ type: Int) -> Void {
    switch(type) {
        case 1:
            generator.notificationOccurred(.success)
            return
        case 2:
            generator.notificationOccurred(.error)
            return
        default:
            return
    }
}

//Alert Feedback
func ShowAlert(_ alert: UIAlertController) -> Void {
    DispatchQueue.main.async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.keyWindow,
              let rootViewController = keyWindow.rootViewController else {
            return
        }
        
        // Find the topmost view controller to present the alert from
        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }
        topController.present(alert, animated: true, completion: nil)
    }
}

func DismissAlert(completion: (() -> Void)? = nil) {
    DispatchQueue.main.async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.keyWindow,
              let rootViewController = keyWindow.rootViewController else {
            completion?()
            return
        }

        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }
        
        topController.dismiss(animated: true) {
            completion?()
        }
    }
}

func showAlert(with message: String) {
    // Create the alert controller
    let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)

    // Create the OK action
    let okAction = UIAlertAction(title: "Close", style: .default, handler: nil)

    // Add the action to the alert
    alert.addAction(okAction)

    // Present the alert
    ShowAlertAdv(alert)
}

func ShowAlertAdv(_ alert: UIAlertController) {
    DispatchQueue.main.async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.keyWindow,
              let rootViewController = keyWindow.rootViewController else {
            return
        }
        
        // Find the topmost view controller to present the alert from
        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }
        topController.present(alert, animated: true, completion: nil)
    }
}
