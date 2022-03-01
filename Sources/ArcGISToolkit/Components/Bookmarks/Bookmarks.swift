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

import ArcGIS
import SwiftUI

/// `Bookmarks` allows a user to view and select from a set of bookmarks.
public struct Bookmarks: View {
    /// A list of selectable bookmarks.
    @State
    private var bookmarks: [Bookmark] = []

    /// A map or scene containing bookmarks.
    private var geoModel: GeoModel?

    /// Indicates if bookmarks have loaded and are ready for display.
    @State
    private var geoModelIsLoaded = false

    /// Determines if the bookmarks list is currently shown or not.
    @Binding
    private var isPresented: Bool

    /// User defined action to be performed when a bookmark is selected.
    ///
    /// Use this when you prefer to self-manage the response to a bookmark selection. Use either
    /// `onSelectionChanged` or `viewpoint` exclusively.
    var onSelectionChanged: ((Bookmark) -> Void)? = nil

    /// A bookmark that was selected.
    ///
    /// Used to listen for a selection.
    @State
    private var selectedBookmark: Bookmark? = nil

    /// If non-`nil`, this viewpoint is updated when a bookmark is selected.
    private var viewpoint: Binding<Viewpoint?>?

    /// Sets a closure to perform when the bookmark selection changes.
    /// - Parameters:
    ///   - action: The closure to perform when the bookmark selection has changed.
    public func onSelectionChanged(
        perform action: @escaping (Bookmark) -> Void
    ) -> Bookmarks {
        var copy = self
        copy.onSelectionChanged = action
        return copy
    }

    /// Performs the necessary actions when a bookmark is selected.
    ///
    /// This includes indicating that bookmarks should be set to a hidden state, and changing the viewpoint
    /// binding (if provided) or calling the closure provided by the `onSelectionChanged` modifier.
    /// `onSelectionChanged` modifier.
    /// - Parameter bookmark: The bookmark that was selected.
    func selectBookmark(_ bookmark: Bookmark?) {
        guard bookmark != nil else { return }
        isPresented = false
        if let viewpoint = viewpoint {
            viewpoint.wrappedValue = bookmark!.viewpoint
        } else if let onSelectionChanged = onSelectionChanged {
            onSelectionChanged(bookmark!)
        }
    }

    /// Creates a `Bookmarks` component.
    /// - Parameters:
    ///   - isPresented: Determines if the bookmarks list is presented.
    ///   - bookmarks: A list of bookmarks. Use this when displaying bookmarks defined at run-time.
    ///   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected.
    ///   Alternately, you can use the `.onSelectionChanged` modifier to handle bookmark selection.
    public init(
        isPresented: Binding<Bool>,
        bookmarks: [Bookmark],
        viewpoint: Binding<Viewpoint?>? = nil
    ) {
        self.bookmarks = bookmarks
        self.viewpoint = viewpoint
        _isPresented = isPresented
    }

    /// Creates a `Bookmarks` component.
    /// - Parameters:
    ///   - isPresented: Determines if the bookmarks list is presented.
    ///   - mapOrScene: A `GeoModel` authored with pre-existing bookmarks.
    ///   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected.
    ///   Alternately, you can use the `.onSelectionChanged` modifier to handle bookmark selection.
    public init(
        isPresented: Binding<Bool>,
        mapOrScene: GeoModel,
        viewpoint: Binding<Viewpoint?>? = nil
    ) {
        geoModel = mapOrScene
        self.viewpoint = viewpoint
        _isPresented = isPresented
    }

    public var body: some View {
        Group {
            BookmarksHeader(isPresented: $isPresented)
            if geoModel == nil || geoModelIsLoaded {
                BookmarksList(bookmarks: bookmarks)
                .onSelectionChanged {
                    selectBookmark($0)
                }
            } else {
                loadingView
            }
        }
    }

    /// A view that is shown while a `GeoModel` is loading.
    private var loadingView: some View {
        VStack {
            Spacer()
            HStack {
                ProgressView()
                    .padding([.trailing], 5)
                Text("Loading")
            }.task {
                do {
                    try await geoModel?.load()
                    geoModelIsLoaded = true
                    bookmarks = geoModel?.bookmarks ?? []
                } catch {
                    print(error.localizedDescription)
                }
            }
            Spacer()
        }
        .padding()
    }
}
