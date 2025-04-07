//
//  Project.swift
//  Mini FCM
//
//  Created by fridakitten on 04.12.24.
//

import SwiftUI
import Foundation

class Project: Identifiable, Equatable, ObservableObject {
    let id: UUID = UUID()
    @Published var name: String
    @Published var type: String
    @Published var path: String
    
    init(name: String, path: String, type: String) {
        self.name = name
        self.path = path
        self.type = type
    }
    
    static func ==(lhs: Project, rhs: Project) -> Bool {
        return lhs.name == rhs.name && lhs.path == rhs.path && lhs.type == rhs.type
    }
}

func MakeMiniProject(Name: String, type: Int) -> Int {
    let v2uuid: UUID = UUID()
    let ProjectPath: String = "\(NSHomeDirectory())/Documents/\(v2uuid)"

    let spcstr: String = "    "
    
    do {
        try FileManager.default.createDirectory(atPath: ProjectPath, withIntermediateDirectories: true)

        let dontTouchMePlistData: [String: Any] = [
            "NAME": Name,
            "TYPE": type
        ]

        let dontTouchMePlistPath = "\(ProjectPath)/DontTouchMe.plist"
        let dontTouchMePlistDataSerialized = try PropertyListSerialization.data(fromPropertyList: dontTouchMePlistData, format: .xml, options: 0)
        FileManager.default.createFile(atPath: dontTouchMePlistPath, contents: dontTouchMePlistDataSerialized, attributes: nil)

        switch(type) {
        case 1: // Nyxian
            FileManager.default.createFile(atPath: "\(ProjectPath)/main.nx", contents: Data("\(authorgen(file: "main.nx"))include(\"io\");\n\nfunction print(msg) {\n  io.write(STDOUT_FILENO, msg, msg.length)\n}\n\nprint(\"Hello, World!\\n\");".utf8))
            break
        case 2: // C
            FileManager.default.createFile(atPath: "\(ProjectPath)/main.c", contents: Data("\(authorgen(file: "main.c"))#include <stdio.h>\n \nint main(void) {\n    printf(\"Hello, World!\\n\");\n    return 0;\n}".utf8))
            break
        case 3: // LUA
            FileManager.default.createFile(atPath: "\(ProjectPath)/main.lua", contents: Data("print(\"Hello, World!\")".utf8))
            break
        case 4: // WebServer
            FileManager.default.createFile(atPath: "\(ProjectPath)/index.html", contents: Data("<html>\n    <head>\n        </meta charset=\"UTF-8\">\n    </head>\n    <body>\n        <p>Hello, World</p>\n    </body>\n</html>".utf8))
            break
        case 5: // Cpp
            FileManager.default.createFile(atPath: "\(ProjectPath)/main.cpp", contents: Data("""
\(authorgen(file: "main.cpp"))
extern "C" void dprintf(int fd, const char* fmt, ...);

int main() {
    dprintf(6, "Hello World Motherfuckers\n");
    return 0;
}
""".utf8))
            break
        case 6: // ObjC App
                FileManager.default.createFile(atPath: "\(ProjectPath)/main.m", contents: Data("\(authorgen(file: "main.m"))#import <Foundation/Foundation.h>\n#import \"myAppDelegate.h\"\n\nint main(int argc, char *argv[]) {\n\(spcstr)@autoreleasepool {\n\(spcstr)\(spcstr)return UIApplicationMain(argc, argv, nil, NSStringFromClass(myAppDelegate.class));\n\(spcstr)}\n}".utf8))
                FileManager.default.createFile(atPath: "\(ProjectPath)/myAppDelegate.h", contents: Data("\(authorgen(file: "myAppDelegate.h"))#import <UIKit/UIKit.h>\n \n@interface myAppDelegate : UIResponder <UIApplicationDelegate>\n \n@property (nonatomic, strong) UIWindow *window;\n@property (nonatomic, strong) UINavigationController *rootViewController;\n \n@end".utf8))
                FileManager.default.createFile(atPath: "\(ProjectPath)/myAppDelegate.m", contents: Data("\(authorgen(file: "myAppDelegate.m"))#import \"myAppDelegate.h\"\n#import \"myRootViewController.h\"\n\n@implementation myAppDelegate\n\n- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {\n\(spcstr)_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];\n\(spcstr)_rootViewController = [[UINavigationController alloc] initWithRootViewController:[[myRootViewController alloc] init]];\n\(spcstr)_window.rootViewController = _rootViewController;\n\(spcstr)[_window makeKeyAndVisible];\n\(spcstr)return YES;\n}\n\n@end".utf8))
                FileManager.default.createFile(atPath: "\(ProjectPath)/myRootViewController.h", contents: Data("\(authorgen(file: "myRootViewController.h"))#import <UIKit/UIKit.h>\n \n@interface myRootViewController : UIViewController\n \n@end".utf8))
                FileManager.default.createFile(atPath: "\(ProjectPath)/myRootViewController.m", contents: Data("\(authorgen(file: "myRootViewController.m"))#import \"myRootViewController.h\"\n@interface myRootViewController () <UITableViewDataSource>\n@property (nonatomic, strong) UITableView *logTableView;\n@property (nonatomic, strong) NSMutableArray *logEntries;\n@end\n\n@implementation myRootViewController\n- (void)viewDidLoad {\n\(spcstr)[super viewDidLoad];\n\(spcstr)self.title = @\"ObjectiveC support!\";\n\(spcstr)self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped:)];\n\(spcstr)self.logTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];\n\(spcstr)self.logTableView.dataSource = self;\n\(spcstr)[self.view addSubview:self.logTableView];\n\(spcstr)self.logEntries = [NSMutableArray array];\n}\n- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {\n\(spcstr)return self.logEntries.count;\n}\n- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {\n\(spcstr)static NSString *CellIdentifier = @\"Cell\";\n\(spcstr)UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];\n\(spcstr)if (!cell) {\n\(spcstr)\(spcstr)cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];\n\(spcstr)}\n\(spcstr)cell.textLabel.text = self.logEntries[indexPath.row];\n\(spcstr)return cell;\n}\n- (void)addButtonTapped:(id)sender {\n\(spcstr)@try {\n\(spcstr)\(spcstr)NSString *logEntry = @\"Hello, World!\";\n\(spcstr)\(spcstr)[self.logEntries insertObject:logEntry atIndex:0];\n\(spcstr)\(spcstr)[self.logTableView reloadData];\n\(spcstr)} @catch (NSException *exception) {\n\(spcstr)\(spcstr)NSLog(@\"Exception: %@\", exception);\n\(spcstr)} @finally {\n\(spcstr)\(spcstr)NSLog(@\"Add button tapped\");\n\(spcstr)}\n}\n@end".utf8))
                break
        default:
            return 2
        }
    } catch {
        print(error)
        return 1
    }

    return 0
}

func GetProjectsBind(Projects: Binding<[Project]>) -> Void {
    DispatchQueue.global(qos: .background).async {
        do {
            let currentProjects = Projects.wrappedValue
            var foundProjectNames = Set<String>()

            for Item in try FileManager.default.contentsOfDirectory(atPath: "\(NSHomeDirectory())/Documents") {
                if Item == "Inbox" || Item == "lib" {
                    continue
                }

                foundProjectNames.insert(Item)

                do {
                    let dontTouchMePlistPath = "\(NSHomeDirectory())/Documents/\(Item)/DontTouchMe.plist"

                    var NAME = "Unknown"
                    var TYPE = "Unknown"

                    if let Info2 = NSDictionary(contentsOfFile: dontTouchMePlistPath) {
                        if let extractedName = Info2["NAME"] as? String {
                            NAME = extractedName
                        }
                        if let extractedType  = Info2["TYPE"] as? Int {
                            TYPE = "\(extractedType)"
                        }
                    }

                    let newProject = Project(name: NAME, path: Item, type: TYPE)

                    if let existingIndex = currentProjects.firstIndex(where: { $0.path == Item }) {
                        let existingProject = currentProjects[existingIndex]
                        if existingProject != newProject {
                            usleep(500)
                            DispatchQueue.main.async {
                                withAnimation {
                                    Projects.wrappedValue[existingIndex] = newProject
                                }
                            }
                        }
                    } else {
                        usleep(500)
                        DispatchQueue.main.async {
                            withAnimation {
                                Projects.wrappedValue.append(newProject)
                            }
                        }
                    }
                }
            }

            usleep(500)
            DispatchQueue.main.async {
                withAnimation {
                    Projects.wrappedValue.removeAll { project in
                        !foundProjectNames.contains(project.path)
                    }
                }
            }
        } catch {
            print(error)
        }
    }
}
