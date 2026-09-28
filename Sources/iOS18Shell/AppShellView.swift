import SwiftUI

/// Native iOS 18 tab and sidebar shell. Declare `Tab` and `TabSection`
/// statically in the content builder; Xcode 16's `ForEach` view builder
/// cannot emit `TabContent` from an array of tabs.
public struct AppShellView<Content: TabContent<String>>: View {
    private let tabIDs: [String]
    private let initialSelection: String?
    private let content: () -> Content

    @ObservedObject private var navigator: AppShellNavigator
    @AppStorage("iOS18Shell.tabCustomization") private var customization = TabViewCustomization()
    @SceneStorage("iOS18Shell.selectedTab") private var storedSelection = ""

    /// `tabIDs` must contain every tab value declared in `content`, in
    /// display order, including tabs inside sections. The app owns its
    /// navigator so deep links and tab content can share the same state.
    public init(
        tabIDs: [String],
        navigator: AppShellNavigator,
        initialSelection: String? = nil,
        @TabContentBuilder<String> content: @escaping () -> Content
    ) {
        self.tabIDs = tabIDs
        self.initialSelection = initialSelection
        self.navigator = navigator
        self.content = content
    }

    public var body: some View {
        tabView
            .applySidebarAdaptableStyle(customization: $customization)
            .onAppear(perform: restoreSelectionIfNeeded)
            .onChange(of: navigator.selection) { _, newValue in
                selectionDidChange(newValue)
            }
            .onChange(of: tabIDs) { _, newIDs in
                if !newIDs.contains(navigator.selection) {
                    navigator.selection = newIDs.first ?? ""
                }
            }
    }

    private var tabView: some View {
        TabView(selection: $navigator.selection) {
            content()
        }
    }

    private func selectionDidChange(_ newValue: String) {
        guard !newValue.isEmpty else { return }
        guard tabIDs.contains(newValue) else {
            navigator.selection = tabIDs.first ?? ""
            return
        }
        storedSelection = newValue
    }

    private func restoreSelectionIfNeeded() {
        if tabIDs.contains(navigator.selection) { return }
        if tabIDs.contains(storedSelection) {
            navigator.selection = storedSelection
        } else if let initialSelection, tabIDs.contains(initialSelection) {
            navigator.selection = initialSelection
        } else {
            navigator.selection = tabIDs.first ?? ""
        }
    }
}

/// Converts one app tab model into Apple's native `TabContent`. Call
/// this once per destination in `AppShellView`'s content builder.
@MainActor
public func appShellTab(_ tab: AppTab, navigator: AppShellNavigator) -> some TabContent<String> {
    Tab(tab.title, systemImage: tab.systemImage, value: tab.id, role: tab.role.native) {
        AppShellTabContent(tab: tab, navigator: navigator)
    }
    .customizationID("shell.tab.\(tab.id)")
}

private struct AppShellTabContent: View {
    let tab: AppTab
    @ObservedObject var navigator: AppShellNavigator

    var body: some View {
        NavigationStack(path: navigator.path(for: tab.id)) {
            Group {
                if tab.role == .search {
                    tab.content()
                        .environment(\.appShellSearchQuery, navigator.searchText(for: tab.id).wrappedValue)
                        .searchable(text: navigator.searchText(for: tab.id), prompt: tab.title)
                } else {
                    tab.content()
                }
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func applySidebarAdaptableStyle(customization: Binding<TabViewCustomization>) -> some View {
        #if os(iOS) || os(macOS) || os(visionOS)
        self
            .tabViewStyle(.sidebarAdaptable)
            .tabViewCustomization(customization)
        #else
        self
        #endif
    }
}
