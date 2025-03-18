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

struct BottomPopupView<Content: View>: View {
    let content: Content

    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardVisible: Bool = false
    @State private var addition: CGFloat = UIDevice.current.hasNotch ? 25.0 : 0.0
    @State private var corner_addition: CGFloat = 0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 16) {
                    content
                }
                .padding(20)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + addition)
                    .background {
                        FluidGradient(blobs: [.purple, .primary, .pink],
                                 highlights: [.purple, .primary, .pink],
                                                            speed: 0.25,
                                                            blur: 0.75)
                            .ignoresSafeArea()
                            .background(.quaternary)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(isPad ? 16 : corner_addition)
                    .frame(width: isPad ? UIScreen.main.bounds.width / 4 : UIScreen.main.bounds.width - corner_addition * 2)
                    .offset(x: corner_addition , y: isKeyboardVisible ? -keyboardHeight : 0)
                    .animation(.easeInOut, value: keyboardHeight)
            }
            .edgesIgnoringSafeArea([.bottom])
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        withAnimation(.easeOut(duration: 0.5)) {
                            addition = 0
                            corner_addition = 16
                            self.keyboardHeight = keyboardSize.height + 25
                            self.isKeyboardVisible = true
                        }
                    }
                }
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        if UIDevice.current.hasNotch {
                            addition = 25.0
                        }
                        corner_addition = 0
                        self.keyboardHeight = 0
                        self.isKeyboardVisible = false
                    }
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self)
            }
        }
        .transition(.move(edge: .bottom))
    }
}

extension UIDevice {
    var hasNotch: Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return false
        }
        let bottomInset = windowScene.windows.first?.safeAreaInsets.bottom ?? 0
        return bottomInset > 0
    }
}
