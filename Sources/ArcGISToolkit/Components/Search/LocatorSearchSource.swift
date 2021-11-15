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

import Foundation
import ArcGIS

/// Uses a Locator to provide search and suggest results. Most configuration should be done on the
/// `GeocodeParameters` directly.
public class LocatorSearchSource: ObservableObject, SearchSource {
    /// Creates a locator search source.
    /// - Parameters:
    ///   - name: The name to show when presenting this source in the UI.
    ///   - locatorTask: The `LocatorTask` to use for searching.
    ///   - maximumResults: The maximum results to return when performing a search. Most sources default to 6.
    ///   - maximumSuggestions: The maximum suggestions to return. Most sources default to 6.
    public init(
        name: String = "Locator",
        locatorTask: LocatorTask = LocatorTask(
            url: URL(
                string: "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
            )!
        ),
        maximumResults: Int32 = 6,
        maximumSuggestions: Int32 = 6
    ) {
        self.name = name
        self.locatorTask = locatorTask
        self.maximumResults = maximumResults
        self.maximumSuggestions = maximumSuggestions
        
        self.geocodeParameters.addResultAttributeName("*")
    }
    
    /// The name to show when presenting this source in the UI.
    public var name: String
    
    /// The maximum results to return when performing a search. Most sources default to 6
    public var maximumResults: Int32 {
        get {
            geocodeParameters.maxResults
        }
        set {
            geocodeParameters.maxResults = newValue
        }
    }
    
    /// The maximum suggestions to return. Most sources default to 6.
    public var maximumSuggestions: Int32 {
        get {
            suggestParameters.maxResults
        }
        set {
            suggestParameters.maxResults = newValue
        }
    }
    
    /// The locator used by this search source.
    public let locatorTask: LocatorTask
    
    /// Parameters used for geocoding. Some properties on parameters will be updated automatically
    /// based on searches.
    public let geocodeParameters: GeocodeParameters = GeocodeParameters()
    
    /// Parameters used for getting suggestions. Some properties will be updated automatically
    /// based on searches.
    public let suggestParameters: SuggestParameters = SuggestParameters()
    
    public func repeatSearch(
        _ queryString: String,
        searchExtent: Envelope
    ) async throws -> [SearchResult] {
        try await internalSearch(
            queryString,
            searchArea: searchExtent
        )
    }
    
    public func search(
        _ queryString: String,
        searchArea: Geometry?,
        preferredSearchLocation: Point?
    ) async throws -> [SearchResult] {
        try await internalSearch(
            queryString,
            searchArea: searchArea,
            preferredSearchLocation: preferredSearchLocation
        )
    }
    
    public func search(
        _ searchSuggestion: SearchSuggestion,
        searchArea: Geometry?,
        preferredSearchLocation: Point?
    ) async throws -> [SearchResult] {
        guard let suggestResult = searchSuggestion.suggestResult else { return [] }
        
        geocodeParameters.searchArea = searchArea
        geocodeParameters.preferredSearchLocation = preferredSearchLocation
        
        let geocodeResults = try await locatorTask.geocode(
            suggestResult: suggestResult,
            parameters: geocodeParameters
        )
        
        // Convert to SearchResults and return.
        return geocodeResults.map {
            SearchResult(geocodeResult: $0, searchSource: self)
        }
    }
    
    public func suggest(
        _ queryString: String,
        searchArea: Geometry?,
        preferredSearchLocation: Point?
    ) async throws -> [SearchSuggestion] {
        suggestParameters.searchArea = searchArea
        suggestParameters.preferredSearchLocation = preferredSearchLocation
        
        let geocodeResults = try await locatorTask.suggest(
            searchText: queryString,
            parameters: suggestParameters
        )
        // Convert to SearchSuggestions and return.
        return geocodeResults.map {
            SearchSuggestion(suggestResult: $0, searchSource: self)
        }
    }
}

extension LocatorSearchSource {
    private func internalSearch(
        _ queryString: String,
        searchArea: Geometry?,
        preferredSearchLocation: Point? = nil
    ) async throws -> [SearchResult] {
        geocodeParameters.searchArea = searchArea
        geocodeParameters.preferredSearchLocation = preferredSearchLocation
        
        let geocodeResults = try await locatorTask.geocode(
            searchText: queryString,
            parameters: geocodeParameters
        )
        
        // Convert to SearchResults and return.
        return geocodeResults.map {
            SearchResult(geocodeResult: $0, searchSource: self)
        }
    }
}
