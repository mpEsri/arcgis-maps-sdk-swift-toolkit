// Copyright 2021 Esri.

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

struct OverviewMapExampleView: View {
    enum MapOrScene {
        /// The example shows a map view.
        case map
        /// The example shows a scene view.
        case scene
    }
    
    @State private var mapOrScene: MapOrScene = .map
    
    var body: some View {
        Group {
            switch mapOrScene {
            case .map:
                OverviewMapForMapView()
            case .scene:
                OverviewMapForSceneView()
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Picker("Map or Scene", selection: $mapOrScene) {
                    Text("Map").tag(MapOrScene.map)
                    Text("Scene").tag(MapOrScene.scene)
                }
                .pickerStyle(.menu)
            }
        })
    }
}

struct OverviewMapForMapView: View {
    @StateObject private var map = Map(basemapStyle: .arcGISImagery)
    
    @State private var viewpoint: Viewpoint?
    
    @State private var visibleArea: ArcGIS.Polygon?
    
    var body: some View {
        MapView(map: map)
            .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
            .onVisibleAreaChanged { visibleArea = $0 }
            .overlay(
                OverviewMap.forMapView(
                    with: viewpoint,
                    visibleArea: visibleArea
                )
                // These modifiers show how you can modify the default
                // values used for the symbol, map, and scaleFactor.
//                    .symbol(.customFillSymbol)
//                    .map(.customOverviewMapForMapView)
//                    .scaleFactor(15.0)
                    .frame(width: 200, height: 132)
                    .padding(),
                alignment: .topTrailing
            )
    }
}

struct OverviewMapForSceneView: View {
    @StateObject private var scene = Scene(basemapStyle: .arcGISImagery)
    
    @State private var viewpoint: Viewpoint?
    
    var body: some View {
        SceneView(scene: scene)
            .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
            .overlay(
                OverviewMap.forSceneView(with: viewpoint)
                // These modifiers show how you can modify the default
                // values used for the symbol, map, and scaleFactor.
//                    .symbol(.customMarkerSymbol)
//                    .map(.customOverviewMapForSceneView)
//                    .scaleFactor(15.0)
                    .frame(width: 200, height: 132)
                    .padding(),
                alignment: .topTrailing
            )
    }
}

struct OverviewMapExampleView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewMapExampleView()
    }
}

// MARK: Extensions

private extension Symbol {
    /// A custom fill symbol.
    static let customFillSymbol: FillSymbol = SimpleFillSymbol(
        style: .diagonalCross,
        color: .blue,
        outline: SimpleLineSymbol(
            style: .solid,
            color: .blue,
            width: 1.0
        )
    )
    
    /// A custom marker symbol.
    static let customMarkerSymbol: MarkerSymbol = SimpleMarkerSymbol(
        style: .x,
        color: .blue,
        size: 16.0
    )
}

private extension Map {
    /// A custom map for the `OverviewMap` used in a MapView.
    static let customOverviewMapForMapView = Map(basemapStyle: .arcGISDarkGray)

    /// A custom map for the `OverviewMap` used in a SceneView.
    static let customOverviewMapForSceneView = Map(basemapStyle: .arcGISDarkGray)
}
