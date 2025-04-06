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

///
/// Functions to encode and decode Color as RGB String
///
func encodeColor(_ color: Color) -> String {
    let uiColor = UIColor(color)
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    let redInt = Int(red * 255)
    let greenInt = Int(green * 255)
    let blueInt = Int(blue * 255)
    
    return "\(redInt),\(greenInt),\(blueInt)"
}
    
func decodeColor(_ rgbString: String) -> Color {
    let components = rgbString.components(separatedBy: ",").compactMap { Int($0) }
    guard components.count == 3 else {
        return .black
    }
    
    let red = Double(components[0]) / 255.0
    let green = Double(components[1]) / 255.0
    let blue = Double(components[2]) / 255.0
    
    return Color(red: red, green: green, blue: blue)
}

///
/// Structures for the saved theming json file
///
struct CodeEditorTheme: Codable, Hashable {
    var name: String
    
    // Light Mode
    var backgroundColor: Color
    var textColor: Color
    var gutterBackgroundColor: Color
    var gutterHairlineColor: Color
    
    var lineNumberColor: Color
    
    var selectedLineBackgroundColor: Color
    var selectedLinesLineNumberColor: Color
    var selectedLinesGutterBackgroundColor: Color
    
    var markedTextBackgroundColor: Color
    
    var colorKeyword: Color
    var colorComment: Color
    var colorString: Color
    var colorNumber: Color
    var colorRegex: Color
    var colorFunction: Color
    var colorOperator: Color
    var colorProperty: Color
    var colorPunctuation: Color
    var colorDirective: Color
    var colorType: Color
    var colorConstantBuiltin: Color
    
    // Dark Mode
    var backgroundColorDark: Color
    var textColorDark: Color
    var gutterBackgroundColorDark: Color
    var gutterHairlineColorDark: Color
    
    var lineNumberColorDark: Color
    
    var selectedLineBackgroundColorDark: Color
    var selectedLinesLineNumberColorDark: Color
    var selectedLinesGutterBackgroundColorDark: Color
    
    var markedTextBackgroundColorDark: Color
    
    var colorKeywordDark: Color
    var colorCommentDark: Color
    var colorStringDark: Color
    var colorNumberDark: Color
    var colorRegexDark: Color
    var colorFunctionDark: Color
    var colorOperatorDark: Color
    var colorPropertyDark: Color
    var colorPunctuationDark: Color
    var colorDirectiveDark: Color
    var colorTypeDark: Color
    var colorConstantBuiltinDark: Color
    
    var font: Double
    var toolbar: Bool
    var showlines: Bool
    var showtab: Bool
    var showspace: Bool
    var wraplines: Bool
    var showreturn: Bool
    var deftab: Bool
    var defspace: Bool
    var defreturn: Bool
    var tab: String
    var space: String
    var ret: String
}

struct CodeEditorThemeJSON: Codable, Hashable {
    var list: [CodeEditorTheme]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(list)
    }
}

///
/// Functions to gather the plist and store it back where it came from
///
func parseCEJSON() -> CodeEditorThemeJSON {
    // first lets read the content at path we dont need the user to pass the path as we can just to trick 17 and we know where it is
    let path: String = "\(NSHomeDirectory())/Documents/themes.json"
    
    // now we lets get it as a string
    guard let content: Data = FileManager.default.contents(atPath: path) else { return CodeEditorThemeJSON(list: []) }
    
    // now lets parse the JSON it self
    let decoder = JSONDecoder()
    
    do {
        let jsonStructure = try decoder.decode(CodeEditorThemeJSON.self, from: content)
        return jsonStructure
    } catch {
        print("Error decoding JSON: \(error)")
        return CodeEditorThemeJSON(list: [])
    }
}

func storeCEJSON(_ CEJSON: CodeEditorThemeJSON) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    var jsonStringTW = ""
    
    do {
        let jsonData = try encoder.encode(CEJSON)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            jsonStringTW = jsonString
        }
    } catch {
        print("Error encoding Library to JSON: \(error)")
        return
    }
    
    do {
        try jsonStringTW.write(toFile: "\(NSHomeDirectory())/Documents/themes.json", atomically: true, encoding: .utf8)
    } catch {
        return
    }
    
    return
}

///
/// Function to generate a base theme
///
func baseThemeGenerate(name: String) -> CodeEditorTheme {
    return CodeEditorTheme(name: name,
                    backgroundColor: Color(neoRGB(250, 250, 250)),
                    textColor: Color(neoRGB(30, 30, 30)),
                    gutterBackgroundColor: Color(neoRGB(240, 240, 240)),
                    gutterHairlineColor: Color(neoRGB(220, 220, 220)),
                    lineNumberColor: Color(neoRGB(180, 180, 180)),
                    selectedLineBackgroundColor: Color(neoRGB(220, 230, 250)),
                    selectedLinesLineNumberColor: Color(neoRGB(80, 120, 180)),
                    selectedLinesGutterBackgroundColor: Color(neoRGB(235, 235, 240)),
                    markedTextBackgroundColor: Color(neoRGB(230, 240, 250)),
                    colorKeyword: Color(neoRGB(0, 0, 192)),
                    colorComment: Color(neoRGB(0, 128, 0) ),
                    colorString: Color(neoRGB(163, 21, 21)),
                    colorNumber: Color(neoRGB(128, 0, 128)),
                    colorRegex: Color(neoRGB(255, 140, 0)),
                    colorFunction: Color(neoRGB(43, 145, 175)),
                    colorOperator: Color(neoRGB(0, 0, 0)),
                    colorProperty: Color(neoRGB(0, 0, 128)),
                    colorPunctuation: Color(neoRGB(50, 50, 50)),
                    colorDirective: Color(neoRGB(60, 60, 60)),
                    colorType: Color(neoRGB(43, 43, 150)),
                    colorConstantBuiltin: Color(neoRGB(75, 0, 130)),
                    backgroundColorDark: Color(neoRGB(30, 30, 30)),
                    textColorDark: Color(neoRGB(232, 242, 255)),
                    gutterBackgroundColorDark: Color(neoRGB(25, 25, 25)),
                    gutterHairlineColorDark: Color(neoRGB(50, 50, 50)),
                    lineNumberColorDark: Color(neoRGB(90, 90, 90)),
                    selectedLineBackgroundColorDark: Color(neoRGB(40, 44, 52)),
                    selectedLinesLineNumberColorDark: Color(neoRGB(130, 180, 255)),
                    selectedLinesGutterBackgroundColorDark: Color(neoRGB(20, 20, 25)),
                    markedTextBackgroundColorDark: Color(neoRGB(60, 60, 70)),
                    colorKeywordDark: Color(neoRGB(86, 156, 214)),
                    colorCommentDark: Color(neoRGB(106, 153, 85)),
                    colorStringDark: Color(neoRGB(206, 145, 120)),
                    colorNumberDark: Color(neoRGB(181, 206, 168)),
                    colorRegexDark: Color(neoRGB(255, 198, 109)),
                    colorFunctionDark: Color(neoRGB(220, 220, 170)),
                    colorOperatorDark: Color(neoRGB(212, 212, 212)),
                    colorPropertyDark: Color(neoRGB(156, 220, 254)),
                    colorPunctuationDark: Color(neoRGB(200, 200, 200)),
                    colorDirectiveDark: Color(neoRGB(255, 165, 0)),
                    colorTypeDark: Color(neoRGB(78, 201, 176)),
                    colorConstantBuiltinDark: Color(neoRGB(0, 255, 255)),
                    font: 12.0,
                    toolbar: true,
                    showlines: true,
                    showtab: true,
                    showspace: true,
                    wraplines: true,
                    showreturn: true,
                    deftab: true,
                    defspace: true,
                    defreturn: true,
                    tab: "",
                    space: "",
                    ret: "")
}

///
/// Views containing settings for the Code editor
///

// FIXME: There are difinetly better ways to do that then this, I mean the different views having the same texts
struct CodeEditorThemeSettingsLM: View {
    @Binding var item: CodeEditorTheme
    
    var body: some View {
        List {
            Section(header: Text("Main")) {
                ColorPicker("Background", selection: $item.backgroundColor)
                ColorPicker("Text", selection: $item.textColor)
                ColorPicker("Marked Text Background", selection: $item.markedTextBackgroundColor)
            }
            Section(header: Text("Gutter")) {
                ColorPicker("Gutter Background", selection: $item.gutterBackgroundColor)
                ColorPicker("Gutter Hairline", selection: $item.gutterHairlineColor)
                ColorPicker("Gutter Line Number", selection: $item.lineNumberColor)
                ColorPicker("Gutter Selected Lines Background", selection: $item.selectedLinesGutterBackgroundColor)
                ColorPicker("Gutter Selected Lines Line Number Background", selection: $item.selectedLinesLineNumberColor)
            }
            Section(header: Text("Line")) {
                ColorPicker("Selected Line Background", selection: $item.selectedLineBackgroundColor)
            }
            Section(header: Text("Highlighting")) {
                ColorPicker("Keyword", selection: $item.colorKeyword)
                ColorPicker("Comment", selection: $item.colorComment)
                ColorPicker("String", selection: $item.colorString)
                ColorPicker("Number", selection: $item.colorNumber)
                ColorPicker("Regex", selection: $item.colorRegex)
                ColorPicker("Function", selection: $item.colorFunction)
                ColorPicker("Operator", selection: $item.colorOperator)
                ColorPicker("Property", selection: $item.colorProperty)
                ColorPicker("Punctuation", selection: $item.colorPunctuation)
                ColorPicker("Directive", selection: $item.colorDirective)
                ColorPicker("Type", selection: $item.colorType)
                ColorPicker("ConstantBuiltin", selection: $item.colorConstantBuiltin)
            }
        }
        .navigationTitle("Light Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CodeEditorThemeSettingsDM: View {
    @Binding var item: CodeEditorTheme
    
    var body: some View {
        List {
            Section(header: Text("Main")) {
                ColorPicker("Background", selection: $item.backgroundColorDark)
                ColorPicker("Text", selection: $item.textColorDark)
                ColorPicker("Marked Text Background", selection: $item.markedTextBackgroundColorDark)
            }
            Section(header: Text("Gutter")) {
                ColorPicker("Gutter Background", selection: $item.gutterBackgroundColorDark)
                ColorPicker("Gutter Hairline", selection: $item.gutterHairlineColorDark)
                ColorPicker("Gutter Line Number", selection: $item.lineNumberColorDark)
                ColorPicker("Gutter Selected Lines Background", selection: $item.selectedLinesGutterBackgroundColorDark)
                ColorPicker("Gutter Selected Lines Line Number Background", selection: $item.selectedLinesLineNumberColorDark)
            }
            Section(header: Text("Line")) {
                ColorPicker("Selected Line Background", selection: $item.selectedLineBackgroundColorDark)
            }
            Section(header: Text("Highlighting")) {
                ColorPicker("Keyword", selection: $item.colorKeywordDark)
                ColorPicker("Comment", selection: $item.colorCommentDark)
                ColorPicker("String", selection: $item.colorStringDark)
                ColorPicker("Number", selection: $item.colorNumberDark)
                ColorPicker("Regex", selection: $item.colorRegexDark)
                ColorPicker("Function", selection: $item.colorFunctionDark)
                ColorPicker("Operator", selection: $item.colorOperatorDark)
                ColorPicker("Property", selection: $item.colorPropertyDark)
                ColorPicker("Punctuation", selection: $item.colorPunctuationDark)
                ColorPicker("Directive", selection: $item.colorDirectiveDark)
                ColorPicker("Type", selection: $item.colorTypeDark)
                ColorPicker("ConstantBuiltin", selection: $item.colorConstantBuiltinDark)
            }
        }
        .navigationTitle("Dark Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CodeEditorThemeSettings: View {
    @Binding var themes: CodeEditorThemeJSON
    @Binding var item: CodeEditorTheme
    
    // Code Editor CFG
    @AppStorage("CEBGCol") var backgroundColor: String = encodeColor(Color.black)
    @AppStorage("CEBGColDark") var backgroundColorDark: String = encodeColor(Color.black)
    
    @AppStorage("CETCol") var textColor: String = encodeColor(Color.black)
    @AppStorage("CETColDark") var textColorDark: String = encodeColor(Color.black)
    
    @AppStorage("CEGBGCol") var gutterBackgroundColor: String = encodeColor(Color.black)
    @AppStorage("CEGBGColDark") var gutterBackgroundColorDark: String = encodeColor(Color.black)
    
    @AppStorage("CEGHCol") var gutterHairlineColor: String = encodeColor(Color.black)
    @AppStorage("CEGHColDark") var gutterHairlineColorDark: String = encodeColor(Color.black)
    
    @AppStorage("CEGLNCol") var lineNumberColor: String = encodeColor(Color.black)
    @AppStorage("CEGLNColDark") var lineNumberColorDark: String = encodeColor(Color.black)
    
    @AppStorage("CESLCol") var selectedLineBackgroundColor: String = encodeColor(Color.black)
    @AppStorage("CESLColDark") var selectedLineBackgroundColorDark: String = encodeColor(Color.black)
    
    @AppStorage("CESLLCol") var selectedLinesLineNumberColor: String = encodeColor(Color.black)
    @AppStorage("CESLLColDark") var selectedLinesLineNumberColorDark: String = encodeColor(Color.black)
    
    @AppStorage("CESLGBGCol") var selectedLinesGutterBackgroundColor: String = encodeColor(Color.black)
    @AppStorage("CESLGBGColDark") var selectedLinesGutterBackgroundColorDark: String = encodeColor(Color.black)
    
    @AppStorage("CEMTCol") var markedTextBackgroundColor: String = encodeColor(Color.black)
    @AppStorage("CEMTColDark") var markedTextBackgroundColorDark: String = encodeColor(Color.black)
    
    @AppStorage("CEKeywordCol") var colorKeyword: String = encodeColor(Color.black)
    @AppStorage("CEKeywordColDark") var colorKeywordDark: String = encodeColor(Color.black)
    
    @AppStorage("CECommentCol") var colorComment: String = encodeColor(Color.black)
    @AppStorage("CECommentColDark") var colorCommentDark: String = encodeColor(Color.black)
    
    @AppStorage("CEStringCol") var colorString: String = encodeColor(Color.black)
    @AppStorage("CEStringColDark") var colorStringDark: String = encodeColor(Color.black)
    
    @AppStorage("CENumberCol") var colorNumber: String = encodeColor(Color.black)
    @AppStorage("CENumberColDark") var colorNumberDark: String = encodeColor(Color.black)
    
    @AppStorage("CERegexCol") var colorRegex: String = encodeColor(Color.black)
    @AppStorage("CERegexColDark") var colorRegexDark: String = encodeColor(Color.black)
    
    @AppStorage("CEFunctionCol") var colorFunction: String = encodeColor(Color.black)
    @AppStorage("CEFunctionColDark") var colorFunctionDark: String = encodeColor(Color.black)
    
    @AppStorage("CEOperatorCol") var colorOperator: String = encodeColor(Color.black)
    @AppStorage("CEOperatorColDark") var colorOperatorDark: String = encodeColor(Color.black)
    
    @AppStorage("CEPropertyCol") var colorProperty: String = encodeColor(Color.black)
    @AppStorage("CEPropertyColDark") var colorPropertyDark: String = encodeColor(Color.black)
    
    @AppStorage("CEPunctuationCol") var colorPunctuation: String = encodeColor(Color.black)
    @AppStorage("CEPunctuationColDark") var colorPunctuationDark: String = encodeColor(Color.black)
    
    @AppStorage("CEDirectiveCol") var colorDirective: String = encodeColor(Color.black)
    @AppStorage("CEDirectiveColDark") var colorDirectiveDark: String = encodeColor(Color.black)
    
    @AppStorage("CETypeCol") var colorType: String = encodeColor(Color.black)
    @AppStorage("CETypeColDark") var colorTypeDark: String = encodeColor(Color.black)
    
    @AppStorage("CEConstantBuiltinCol") var colorConstantBuiltin: String = encodeColor(Color.black)
    @AppStorage("CEConstantBuiltinColDark") var colorConstantBuiltinDark: String = encodeColor(Color.black)
    
    // Other options
    @AppStorage("CEFontSize") var font: Double = 13.0
    @AppStorage("CEToolbar") var toolbar: Bool = true
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
    
    var body: some View {
        List {
            Section(header: Text("Coloration")) {
                NavigationLink(destination: CodeEditorThemeSettingsLM(item: $item)) {
                    Text("Light Mode")
                }
                NavigationLink(destination: CodeEditorThemeSettingsDM(item: $item)) {
                    Text("Dark Mode")
                }
            }
            Section(header: Text("Size")) {
                Stepper("Font Size: \(String(Int(item.font)))", value: $item.font, in: 0...20)
            }
            Section(header: Text("Features")) {
                Toggle("Toolbar", isOn: $item.toolbar)
                Toggle("Wrap Lines", isOn: $item.wraplines)
                Toggle("Show Line Numbers", isOn: $item.showlines)
                Toggle("Show Tab", isOn: $item.showtab)
                Toggle("Show Space", isOn: $item.showspace)
                Toggle("Show Return", isOn: $item.showreturn)
            }
            if item.showtab || item.showspace || item.showreturn {
                Section(header: Text("Advanced")) {
                    if item.showtab {
                        Toggle("Default Tab", isOn: $item.deftab)
                        if !item.deftab {
                            TextField("Tab", text: $item.tab)
                        }
                    }
                    if item.showspace {
                        Toggle("Default Space", isOn: $item.defspace)
                        if !item.defspace {
                            TextField("Space", text: $item.space)
                        }
                    }
                    if item.showreturn {
                        Toggle("Default Return", isOn: $item.defreturn)
                        if !item.defreturn {
                            TextField("Space", text: $item.ret)
                        }
                    }
                }
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        storeCEJSON(themes)
                        
                        // Implementation of apply
                        backgroundColor = encodeColor(item.backgroundColor)
                        backgroundColorDark = encodeColor(item.backgroundColorDark)
                        textColor = encodeColor(item.textColor)
                        textColorDark = encodeColor(item.textColorDark)
                        gutterBackgroundColor = encodeColor(item.gutterBackgroundColor)
                        gutterBackgroundColorDark = encodeColor(item.gutterBackgroundColorDark)
                        
                        gutterHairlineColor = encodeColor(item.gutterHairlineColor)
                        gutterHairlineColorDark = encodeColor(item.gutterHairlineColorDark)
                        
                        lineNumberColor = encodeColor(item.lineNumberColor)
                        lineNumberColorDark = encodeColor(item.lineNumberColorDark)
                        
                        selectedLineBackgroundColor = encodeColor(item.selectedLineBackgroundColor)
                        selectedLineBackgroundColorDark = encodeColor(item.selectedLineBackgroundColorDark)
                        
                        selectedLinesLineNumberColor = encodeColor(item.selectedLinesLineNumberColor)
                        selectedLinesLineNumberColorDark = encodeColor(item.selectedLinesLineNumberColorDark)
                        
                        selectedLinesGutterBackgroundColor = encodeColor(item.selectedLinesGutterBackgroundColor)
                        selectedLinesGutterBackgroundColorDark = encodeColor(item.selectedLinesGutterBackgroundColorDark)
                        
                        markedTextBackgroundColor = encodeColor(item.markedTextBackgroundColor)
                        markedTextBackgroundColorDark = encodeColor(item.markedTextBackgroundColorDark)
                        
                        colorKeyword = encodeColor(item.colorKeyword)
                        colorKeywordDark = encodeColor(item.colorKeywordDark)
                        
                        colorComment = encodeColor(item.colorComment)
                        colorCommentDark = encodeColor(item.colorCommentDark)
                        
                        colorString = encodeColor(item.colorString)
                        colorStringDark = encodeColor(item.colorStringDark)
                        
                        colorNumber = encodeColor(item.colorNumber)
                        colorNumberDark = encodeColor(item.colorNumberDark)
                        
                        colorRegex = encodeColor(item.colorRegex)
                        colorRegexDark = encodeColor(item.colorRegexDark)
                        
                        colorFunction = encodeColor(item.colorFunction)
                        colorFunctionDark = encodeColor(item.colorFunctionDark)
                        
                        colorOperator = encodeColor(item.colorOperator)
                        colorOperatorDark = encodeColor(item.colorOperatorDark)
                        
                        colorProperty = encodeColor(item.colorProperty)
                        colorPropertyDark = encodeColor(item.colorPropertyDark)
                        
                        colorPunctuation = encodeColor(item.colorPunctuation)
                        colorPunctuationDark = encodeColor(item.colorPunctuationDark)
                        
                        colorDirective = encodeColor(item.colorDirective)
                        colorDirectiveDark = encodeColor(item.colorDirectiveDark)
                        
                        colorType = encodeColor(item.colorType)
                        colorTypeDark = encodeColor(item.colorTypeDark)
                        
                        colorConstantBuiltin = encodeColor(item.colorConstantBuiltin)
                        colorConstantBuiltinDark = encodeColor(item.colorConstantBuiltinDark)
                        
                        font = item.font
                        toolbar = item.toolbar
                        showlines = item.showlines
                        showspace = item.showspace
                        showtab = item.showtab
                        showreturn = item.showreturn
                        wraplines = item.wraplines
                        deftab = item.deftab
                        defspace = item.defspace
                        defreturn = item.defreturn
                        tab = item.tab
                        space = item.space
                        ret = item.ret
                    }) {
                        Text("Apply")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                }
            }
        }
        .onDisappear {
            storeCEJSON(themes)
        }
    }
}

struct NeoEditorSettings: View {
    @State private var CEJson: CodeEditorThemeJSON = CodeEditorThemeJSON(list: [])
    
    @State private var presented: Bool = false
    @State private var name: String = ""
    
    var body: some View {
        List(CEJson.list.indices, id: \.self) { index in
            //Text("\(item.name)")
            
            NavigationLink(destination: CodeEditorThemeSettings(themes: $CEJson, item: $CEJson.list[index])) {
                Text(CEJson.list[index].name)
            }
        }
        .navigationTitle("Code Editor")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(InsetGroupedListStyle())
        .accentColor(Color.blue)
        .tint(Color.blue)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button( action: {
                    presented.toggle()
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $presented) {
            BottomPopupView {
                POHeader(title: "Create Theme")
                POTextField(title: "Name", content: $name)
                POButtonBar(cancel: cancelAction, confirm: confirmAction)
            }
            .background(BackgroundClearView())
            .edgesIgnoringSafeArea([.bottom])
        }
        .onAppear(perform: { CEJson = parseCEJSON() })
    }
    
    func cancelAction() -> Void {
        name = ""
        presented.toggle()
    }
    
    func confirmAction() -> Void {
        CEJson.list.append(baseThemeGenerate(name: name))
        storeCEJSON(CEJson)
        name = ""
        presented.toggle()
    }
}


///
/// Extension to make this game way easier than before
///
extension Color: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let colorString = encodeColor(self)
        try container.encode(colorString)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let colorString = try container.decode(String.self)
        self = decodeColor(colorString)
    }
}
