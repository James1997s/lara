//
//  lara.swift
//  lara
//
//  Created by ruter on 23.03.26.
//

import SwiftUI
import UniformTypeIdentifiers

enum TabOptions {
    case applying, tweaks, files, logs
}

let g_isunsupported: Bool = isunsupported()
var weOnADebugBuild: Bool = false

@main
struct lara: App {
    @StateObject private var mgr = laramgr.shared
    @StateObject private var iconThemeMgr = IconThemeManager.shared
    @AppStorage("selectedMethod") private var selectedMethod: method = .hybrid
    @Environment(\.scenePhase) var scenePhase
    // connect new key to settings
    @AppStorage("keepAlive") private var keepAlive: Bool = false
    @AppStorage("showFMInTabs") private var showFMInTabs: Bool = true
    @AppStorage("showLogsInTabs") private var showLogsInTabs: Bool = false
    
    @State private var selectedTab: TabOptions = .applying
    
    init() {
        #if DEBUG
        weOnADebugBuild = true
        #endif
        // fix file picker
        let fixMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, #selector(UIDocumentPickerViewController.fix_init(forOpeningContentTypes:asCopy:)))!
        let origMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, #selector(UIDocumentPickerViewController.init(forOpeningContentTypes:asCopy:)))!
        method_exchangeImplementations(origMethod, fixMethod)
        
        if keepAlive {
            toggleka()
        }
        
        globallogger.capture()
    }
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                ContentView()
                    .tabItem {
                        Image(systemName: "wrench.and.screwdriver.fill")
                    }
                    .tag(TabOptions.applying)
                
                // this has gotta fucking go
                TweaksView(mgr: mgr)
                    .tabItem {
                        Image(systemName: "ant.fill")
                    }
                    .tag(TabOptions.tweaks)
                
                
                // i'm gonna strangle you root (the weight of your actions will crush you)
                if showFMInTabs {
                    SantanderView(startPath: "/")
                        .tabItem {
                            Image(systemName: "folder.fill")
                        }
                        .tag(TabOptions.files)
                }
                
                // this too
                if showLogsInTabs {
                    LogsView(logger: globallogger)
                        .tabItem {
                            Image(systemName: "terminal")
                        }
                        .tag(TabOptions.logs)
                }
            }
            .environmentObject(mgr)
            .overlay {
                if mgr.showrespring {
                    respringview()
                        .brightness(-1.0)
                        .ignoresSafeArea()
                }
            }
            .sheet(isPresented: $mgr.showLogs) {
                LogsView(logger: globallogger)
            }
            .sheet(isPresented: $iconThemeMgr.showFixupSheet) {
                IconThemeFixupView()
            }
            .onAppear {
                if !isunsupported() {
                    init_offsets()
                    offsets_init()
                    iconThemeMgr.startPendingFixupIfPossible()
                    // beautiful name root
                    mgr.hasOffsets = emergencyfixfunctiontobereplacedlateronquestionmark()
                } else {
                    Alertinator.shared.alert(title: "This device is not supported!", body: "We apologize, but this device is not supported by lara and never will be. lara only supports iOS 16.0 - iOS 18.7.1, and iOS 26.0 - iOS 26.0.1. This error could also be caused by a debugger being attached.", actionLabel: "Exit App", action: { exitinator() })
                }
            }
            .onChange(of: scenePhase, perform: handleScenePhase)
            .onChange(of: mgr.sbxready) { ready in
                if ready {
                    iconThemeMgr.startPendingFixupIfPossible()
                }
            }
        }
    }
    
    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .inactive, .background:
            handlebg()
            globallogger.stopcapture()

        case .active:
            globallogger.capture()
            iconThemeMgr.startPendingFixupIfPossible()

        @unknown default:
            break
        }
    }

    private func handlebg() {
        guard mgr.rcready else { return }

        var bgTask: UIBackgroundTaskIdentifier = .invalid

        bgTask = UIApplication.shared.beginBackgroundTask(withName: "RemoteCallCleanup") {
            endbgtask(&bgTask)
        }

        mgr.rcdestroy {
            self.endbgtask(&bgTask)
        }
    }

    private func endbgtask(_ task: inout UIBackgroundTaskIdentifier) {
        guard task != .invalid else { return }
        UIApplication.shared.endBackgroundTask(task)
        task = .invalid
    }
}

// file picker fixes
extension UIDocumentPickerViewController {
    @objc func fix_init(forOpeningContentTypes contentTypes: [UTType], asCopy: Bool) -> UIDocumentPickerViewController {
        return fix_init(forOpeningContentTypes: contentTypes, asCopy: true)
    }
}
