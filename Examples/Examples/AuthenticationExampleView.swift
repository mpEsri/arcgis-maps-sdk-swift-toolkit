// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS
import ArcGISToolkit

struct AuthenticationExampleView: View {
    @MainActor var authenticator = Authenticator(
        promptForUntrustedHosts: true//, oAuthConfigurations: [.arcgisDotCom]
    )
    @State var previousApiKey: APIKey?
    @State private var items = AuthenticationItem.makeAll()
    
    var body: some View {
        VStack {
            if items.isEmpty {
                ProgressView()
            } else {
                List(items) { item in
                    AuthenticationItemView(item: item)
                }
            }
            
            Button("Clear Credential Store") {
                items = []
                Task {
                    await authenticator.clearCredentialStores()
                    items = AuthenticationItem.makeAll()
                }
            }
        }
        .authenticator(authenticator)
        .task {
            try? await authenticator.makePersistent(access: .whenUnlockedThisDeviceOnly)
        }
        .navigationBarTitle(Text("Authentication"), displayMode: .inline)
        .onAppear {
            ArcGISRuntimeEnvironment.authenticationChallengeHandler = authenticator
        }
        // Save and restore the API Key.
        // Note: This is only necessary in this example. Other examples make use of the global
        // api key that is set when the app starts up. Using an api key will prevent an
        // authentication challenge prompt for certain services. Since this example highlights
        // the usage of authentication challenge prompts, we want to set the api key to `nil`
        // when this example appears and restore it when this example disappears.
        .onAppear {
            // Save off the api key
            previousApiKey = ArcGISRuntimeEnvironment.apiKey
            // Set the api key to nil so that the authenticated services will prompt.
            ArcGISRuntimeEnvironment.apiKey = nil
        }
        .onDisappear {
            // Restore api key when exiting this example.
            ArcGISRuntimeEnvironment.apiKey = previousApiKey
        }
    }
}

private struct AuthenticationItemView: View {
    let loadables: [Loadable]
    let title: String
    @State var status = LoadStatus.notLoaded
    
    init(item: AuthenticationItem) {
        self.loadables = item.loadables
        self.title = item.title
    }
    
    var body: some View {
        Button {
            Task {
                status = .loading
                do {
                    try await withThrowingTaskGroup(of: Void.self) { group in
                        for loadable in loadables {
                            group.addTask {
                                try await loadable.load()
                            }
                        }
                        try await group.waitForAll()
                    }
                    status = .loaded
                } catch {
                    status = .failed
                }
            }
        } label: {
            buttonContent
        }
    }
    
    var buttonContent: some View {
        HStack {
            Text(title)
            Spacer()
            switch status {
            case .loading:
                ProgressView()
            case .loaded:
                Text("Loaded")
                    .foregroundColor(.green)
            case .notLoaded:
                Text("Tap to load")
                    .foregroundColor(.secondary)
            case .failed:
                Text("Failed to load")
                    .foregroundColor(.red)
            }
        }
    }
}

private extension URL {
    static let worldImageryMapServer = URL(string: "https://ibasemaps-api.arcgis.com/arcgis/rest/services/World_Imagery/MapServer")!
    static let hostedPointsLayer = URL(string: "https://rt-server107a.esri.com/server/rest/services/Hosted/PointsLayer/FeatureServer/0")!
}

private class AuthenticationItem {
    let title: String
    let loadables: [Loadable]
    
    init(title: String, loadables: [Loadable]) {
        self.title = title
        self.loadables = loadables
    }
}

extension AuthenticationItem: Identifiable {}

extension AuthenticationItem {
    static func makeToken() -> AuthenticationItem {
        AuthenticationItem(
            title: "Token secured resource",
            loadables: [ArcGISTiledLayer(url: .worldImageryMapServer)]
        )
    }
    
    static func makeMultipleToken() -> AuthenticationItem {
        AuthenticationItem(
            title: "Multiple token secured resources",
            loadables: [
                ArcGISTiledLayer(url: .worldImageryMapServer),
                ServiceFeatureTable(url: .hostedPointsLayer)
            ]
        )
    }
    
    static func makeMultipleTokenSame() -> AuthenticationItem {
        AuthenticationItem(
            title: "Two of same token secured resources",
            loadables: [
                ArcGISTiledLayer(url: .worldImageryMapServer),
                ArcGISTiledLayer(url: .worldImageryMapServer)
            ]
        )
    }
    
    static func makePortal() -> AuthenticationItem {
        AuthenticationItem(
            title: "Portal",
            loadables: [
                Portal.arcGISOnline(isLoginRequired: true)
            ]
        )
    }
    
    static func makeIWAPortal() -> AuthenticationItem {
        AuthenticationItem(
            title: "IWA Portal",
            loadables: [Portal.init(url: URL(string: "https://dev0004327.esri.com/portal")!)]
        )
    }
    
    static func makePKIMap() -> AuthenticationItem {
        AuthenticationItem(
            title: "PKI Map",
            loadables: [Map(url: URL(string: "https://dev0002028.esri.com/portal/home/item.html?id=7fd418d5de2e4752b616a6463318cc4e")!)!]
        )
    }
    
    static func makeEricPKIMap() -> AuthenticationItem {
        AuthenticationItem(
            title: "Eric PKI Map",
            loadables: [Map(url: URL(string: "https://enterprise.esrigxdev.com/portal1091/sharing/rest/content/items/3e3b4cec95d143478cf187ba6ea4f7c4")!)!]
        )
    }
    
    static func makeAll() -> [AuthenticationItem]  {
        [
            makeToken(),
            makeMultipleToken(),
            makeMultipleTokenSame(),
            makePortal(),
            makeIWAPortal(),
            makePKIMap(),
            makeEricPKIMap()
        ]
    }
}

private extension OAuthConfiguration {
    static let arcgisDotCom =  OAuthConfiguration(
        portalURL: .arcgisDotCom,
        clientID: "W0DOrjQjPCL1C6LA",
        redirectURL: URL(string: "runtimeswiftexamples://auth")!
    )
}

private extension URL {
    static let arcgisDotCom = URL(string: "https://www.arcgis.com")!
}
