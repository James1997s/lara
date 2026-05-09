//
//  lara.swift
//  lara
//
//  Created by ruter on 23.03.26.
//

import SwiftUI
import UniformTypeIdentifiers

let g_isunsupported: Bool = isunsupported()

extension UIDocumentPickerViewController {
    @objc func fixinit(
        forOpeningContentTypes contentTypes: [UTType],
        asCopy: Bool
    ) -> UIDocumentPickerViewController {
        return fixinit(forOpeningContentTypes: contentTypes, asCopy: true)
    }
}

@main
struct lara: App {
    @StateObject private var mgr = laramgr.shared
    @StateObject private var iconthememgr = IconThemeManager.shared
    @Environment(\.scenePhase) private var scenephase
    @State private var showunsupported = g_isunsupported
    @State private var selectedtab = 0
    @AppStorage("showfmintabs") private var showfmintabs: Bool = true
    @AppStorage("selectedmethod") private var selectedmethod: method = .hybrid

    private let kakay = "keepalive"

    init() {
        swizzledocspicker()
        setupka()

        globallogger.capture()
        
        if g_isunsupported {
            print("(lara) device may be unsupported")
        } else {
            print("(lara) device should be supported")
        }
    }

    private func swizzledocspicker() {
        let fixMethod = class_getInstanceMethod(
            UIDocumentPickerViewController.self,
            #selector(UIDocumentPickerViewController.fixinit(forOpeningContentTypes:asCopy:))
        )!

        let origMethod = class_getInstanceMethod(
            UIDocumentPickerViewController.self,
            #selector(UIDocumentPickerViewController.init(forOpeningContentTypes:asCopy:))
        )!

        method_exchangeImplementations(origMethod, fixMethod)
    }

    private func setupka() {
        guard UserDefaults.standard.bool(forKey: kakay), !kaenabled else { return }
        toggleka()
    }

    var body: some Scene {
        WindowGroup {
            maintabview
                .overlay(respringoverlay)
                .sheet(isPresented: $mgr.showLogs) {
                    LogsView(logger: globallogger)
                }
                .sheet(isPresented: $iconthememgr.showFixupSheet) {
                    IconThemeFixupView()
                }
                .onAppear(perform: onappear)
                .onChange(of: scenephase, perform: handlescenphase)
                .onChange(of: mgr.sbxready) { ready in
                    if ready {
                        iconthememgr.startPendingFixupIfPossible()
                    }
                }
                .alert("Unsupported", isPresented: $showunsupported) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("""
                    Lara is currently not supported on this device.

                    Possible reasons:
                    - Unsupported iOS version
                    - Device restrictions (MIE)
                    - Debugger attached

                    Lara will probably not work correctly.
                    """)
                }
        }
    }

    private var maintabview: some View {
        TabView(selection: $selectedtab) {
            ContentView()
                .tabItem { Image(systemName: "wrench.and.screwdriver.fill") }
                .tag(0)

            TweaksView(mgr: mgr)
                .tabItem { Image(systemName: "ant.fill") }
                .tag(1)

            SantanderView(startPath: "/")
                .tabItem { Image(systemName: "folder.fill") }
                .tag(2)
        }
    }

    private var respringoverlay: some View {
        Group {
            if mgr.showrespring {
                respringview()
                    .brightness(-1.0)
                    .ignoresSafeArea()
            }
        }
    }
    
    private func onappear() {
        if g_isunsupported {
            showunsupported = true
        }

        init_offsets()
        offsets_init()
        iconthememgr.startPendingFixupIfPossible()
    }

    private func handlescenphase(_ phase: ScenePhase) {
        switch phase {
        case .inactive, .background:
            handlebg()
            globallogger.stopcapture()

        case .active:
            globallogger.capture()
            iconthememgr.startPendingFixupIfPossible()

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
