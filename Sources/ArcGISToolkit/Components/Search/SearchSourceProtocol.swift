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

import ArcGIS
import Foundation

/// Defines the contract for a search result provider.
public protocol SearchSourceProtocol {
    /// Name to show when presenting this source in the UI.
    var displayName: String { get set }
    
    /// The maximum results to return when performing a search. Most sources default to 6.
    var maximumResults: Int32 { get set }
    
    /// The maximum suggestions to return. Most sources default to 6.
    var maximumSuggestions: Int32 { get set }
    
    /// Area to be used as a constraint for searches and suggestions.
    var searchArea: Geometry? { get set }
    
    /// Point to be used as an input to searches and suggestions.
    var preferredSearchLocation: Point? { get set }
    
    /// Gets suggestions.
    /// - Parameters:
    ///   - queryString: Text to be used for query.
    /// - Returns: The array of suggestions.
    func suggest(_ queryString: String) async throws -> [SearchSuggestion]
    
    /// Gets search results.
    /// - Parameters:
    ///   - queryString: Text to be used for query.
    /// - Returns: Array of `SearchResult`s
    func search(_ queryString: String) async throws -> [SearchResult]
    
    /// Gets search results. If `area` is not `nil`, search is restricted to that area. Otherwise, the
    /// `searchArea` property may be consulted but does not need to be used as a strict limit.
    /// - Parameters:
    ///   - searchSuggestion: Suggestion to be used as basis for search.
    ///   - area: Area to be used to constrain search results.
    /// - Returns: Array of `SearchResult`s
    func search(
        _ searchSuggestion: SearchSuggestion
    ) async throws -> [SearchResult]
    
    /// Repeats the last search.
    /// - Parameters:
    ///   - queryString: Text to be used for query.
    ///   - queryExtent: Extent used to limit the results.
    /// - Returns: Array of `SearchResult`s
    func repeatSearch(_ queryString: String, queryExtent: Envelope) async throws -> [SearchResult]
}
