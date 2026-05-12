//
//  AppIconView.swift
//  lara
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct AppIconView: View {
@EnvironmentObject var mgr: laramgr
@State private var showImagePicker: Bool = false
@State private var selectedImage: UIImage? = nil
@State private var statusMessage: String? = nil
@State private var showStatus: Bool = false

```
// The bundle ID of this app
private var bundleID: String {
    Bundle.main.bundleIdentifier ?? "com.roooot.lara"
}

// Where iOS caches app icons (readable via VFS)
private var iconCachePath: String {
    "/var/containers/Bundle/Application"
}

var body: some View {
    List {
        Section(header: Text("Current Icon")) {
            HStack {
                Spacer()
                if let img = selectedImage {
                    Image(uiImage: img)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(radius: 4)
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "app.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.secondary)
                        )
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }

        Section(header: Text("Custom Icon"), footer: Text("Pick any PNG from your photo library. lara will overwrite the app icon using VFS. A respring is required to apply the change.")) {
            Button("Choose PNG from Photos") {
                showImagePicker = true
            }

            if selectedImage != nil {
                Button("Apply Icon") {
                    applyIcon()
                }
                .foregroundColor(.accentColor)

                Button("Reset to Default") {
                    resetIcon()
                }
                .foregroundColor(.red)
            }
        }
    }
    .navigationTitle("App Icon")
    .sheet(isPresented: $showImagePicker) {
        ImagePickerView(image: $selectedImage)
    }
    .alert("Result", isPresented: $showStatus) {
        Button("OK") { showStatus = false }
    } message: {
        Text(statusMessage ?? "")
    }
}

// MARK: - Apply Icon

private func applyIcon() {
    guard let image = selectedImage,
          let pngData = image.pngData() else {
        statusMessage = "Failed to convert image to PNG."
        showStatus = true
        return
    }

    // Find the app's bundle container UUID
    guard let appBundlePath = findAppBundlePath() else {
        statusMessage = "Could not locate app bundle. Make sure VFS is initialized."
        showStatus = true
        return
    }

    let iconNames = [
        "AppIcon60x60@2x.png",
        "AppIcon60x60@3x.png",
        "AppIcon76x76~ipad.png",
        "AppIcon76x76@2x~ipad.png"
    ]

    var success = false
    for iconName in iconNames {
        let targetPath = "\(appBundlePath)/\(iconName)"
        let result = writeData(pngData, toPath: targetPath)
        if result { success = true }
    }

    if success {
        statusMessage = "Icon applied! Respring to see the change."
    } else {
        statusMessage = "Failed to write icon. Make sure VFS is ready."
    }
    showStatus = true
}

// MARK: - Reset Icon

private func resetIcon() {
    selectedImage = nil
    statusMessage = "Reset to default. Respring to apply."
    showStatus = true
}

// MARK: - Helpers

private func findAppBundlePath() -> String? {
    // Walk /var/containers/Bundle/Application to find our bundle
    let fm = FileManager.default
    guard let uuids = try? fm.contentsOfDirectory(atPath: iconCachePath) else { return nil }
    for uuid in uuids {
        let base = "\(iconCachePath)/\(uuid)"
        guard let contents = try? fm.contentsOfDirectory(atPath: base) else { continue }
        for item in contents where item.hasSuffix(".app") {
            let infoPlist = "\(base)/\(item)/Info.plist"
            if let dict = NSDictionary(contentsOfFile: infoPlist),
               let bid = dict["CFBundleIdentifier"] as? String,
               bid == bundleID {
                return "\(base)/\(item)"
            }
        }
    }
    return nil
}

private func writeData(_ data: Data, toPath path: String) -> Bool {
    // Use lara's VFS overwrite (same mechanism as Custom Overwrite feature)
    return data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> Bool in
        guard let base = ptr.baseAddress else { return false }
        let result = vfs_overwrite(path, base, UInt64(data.count))
        return result == 0
    }
}
```

}

// MARK: - Image Picker

struct ImagePickerView: UIViewControllerRepresentable {
@Binding var image: UIImage?
@Environment(.dismiss) private var dismiss

```
func makeCoordinator() -> Coordinator {
    Coordinator(self)
}

func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    picker.sourceType = .photoLibrary
    picker.allowsEditing = true
    return picker
}

func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let parent: ImagePickerView

    init(_ parent: ImagePickerView) {
        self.parent = parent
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let edited = info[.editedImage] as? UIImage {
            parent.image = edited
        } else if let original = info[.originalImage] as? UIImage {
            parent.image = original
        }
        parent.dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.dismiss()
    }
}
```

}
