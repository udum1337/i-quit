import SwiftUI
import SwiftData

@main
struct IQuitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()

    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: UserPlan.self)
        } catch {
            fatalError("Unable to create the SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .tint(Color.appAccent)
                .preferredColorScheme(appState.theme.colorScheme)
        }
        .modelContainer(container)
    }
}
