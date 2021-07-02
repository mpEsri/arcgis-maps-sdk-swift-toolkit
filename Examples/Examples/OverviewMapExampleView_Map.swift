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

struct OverviewMapExampleView_Map: View {
    let map = Map(basemap: .imageryWithLabels())
    @State private var viewpoint: Viewpoint?
    @State private var visibleArea: ArcGIS.Polygon?
    
    var body: some View {
        VStack {
            MapView(map: map)
                .onViewpointChanged(type: .centerAndScale) { viewpoint = $0 }
                .onVisibleAreaChanged { visibleArea = $0 }
                .overlay(
                    OverviewMap(viewpoint: viewpoint,
                                visibleArea: visibleArea
                               )
                        .frame(width: 200, height: 132)
                        .padding(),
                    alignment: .topTrailing
                )
        }
    }
}

struct OverviewMapExampleView_Map_Previews: PreviewProvider {
    static var previews: some View {
        OverviewMapExampleView_Map()
    }
}
