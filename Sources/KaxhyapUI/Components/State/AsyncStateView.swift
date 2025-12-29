//
//  AsyncStateView.swift
//  KaxhyapUI
//
//  Created by Sachin Kaxhyap on 29/12/2025.
//

import SwiftUI

// MARK: - AsyncState Enum

/// Represents the state of an asynchronous operation.
public enum AsyncState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)
    case empty
    
    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    public var data: T? {
        if case .success(let value) = self { return value }
        return nil
    }
    
    public var error: Error? {
        if case .failure(let error) = self { return error }
        return nil
    }
}

// MARK: - AsyncStateView

/// A view that displays different content based on the current async state.
///
/// Use this view to handle loading, success, error, and empty states in a consistent way.
///
/// ```swift
/// AsyncStateView(state: viewModel.state) { data in
///     List(data) { item in
///         Text(item.name)
///     }
/// } retry: {
///     viewModel.load()
/// }
/// .emptyState(title: "No Items", systemImage: "folder")
/// ```
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct AsyncStateView<Data, Content: View>: View {
    let state: AsyncState<Data>
    let content: (Data) -> Content
    let retry: (() -> Void)?
    
    // Customization options
    var emptyTitle: String = "No Data"
    var emptySystemImage: String = "tray"
    var emptyDescription: String? = "There's nothing to display"
    
    var errorTitle: String = "Something Went Wrong"
    var errorSystemImage: String = "exclamationmark.triangle"
    
    public init(
        state: AsyncState<Data>,
        @ViewBuilder content: @escaping (Data) -> Content,
        retry: (() -> Void)? = nil
    ) {
        self.state = state
        self.content = content
        self.retry = retry
    }
    
    public var body: some View {
        switch state {
        case .idle:
            EmptyView()
            
        case .loading:
            ContentUnavailableView {
                ProgressView()
                    .controlSize(.large)
            } description: {
                Text("Loading")
            }
            
        case .success(let data):
            content(data)
            
        case .empty:
            ContentUnavailableView(
                emptyTitle,
                systemImage: emptySystemImage,
                description: emptyDescription.map { Text($0) }
            )
            
        case .failure(let error):
            ContentUnavailableView {
                Label(errorTitle, systemImage: errorSystemImage)
            } description: {
                Text(error.localizedDescription)
            } actions: {
                if let retry {
                    if #available(iOS 26.0, *) {
                        Button {
                            retry()
                        } label: {
                            Text("Retry")
                                .padding()
                                .padding(.horizontal)
                                .foregroundStyle(.white)
                                .bold()
                                .background(.blue)
                                .clipShape(Capsule())
                                .glassEffect(.clear.interactive())
                        }
                    } else {
                        Button("Retry", action: retry)
                                .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
}

// MARK: - Customization Modifiers

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension AsyncStateView {
    /// Customizes the empty state appearance.
    public func emptyState(
        title: String,
        systemImage: String,
        description: String? = nil
    ) -> AsyncStateView {
        var view = self
        view.emptyTitle = title
        view.emptySystemImage = systemImage
        view.emptyDescription = description
        return view
    }
    
    /// Customizes the error state appearance.
    public func errorState(
        title: String,
        systemImage: String
    ) -> AsyncStateView {
        var view = self
        view.errorTitle = title
        view.errorSystemImage = systemImage
        return view
    }
}
