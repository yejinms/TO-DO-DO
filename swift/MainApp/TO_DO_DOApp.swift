import SwiftUI
import WidgetKit

@main
struct TO_DO_DOApp: App {
    @StateObject private var store = TodoStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    WidgetCenter.shared.reloadAllTimelines()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 420, height: 700)
    }
}
