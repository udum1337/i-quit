import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case timeline
    case progress
    case settings

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .timeline: return "clock"
        case .progress: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var titleKey: String {
        switch self {
        case .home: return "navHome"
        case .timeline: return "navTimeline"
        case .progress: return "navProgress"
        case .settings: return "navSettings"
        }
    }
}

struct MainTabView: View {
    let plan: UserPlan
    @Binding var selectedTab: AppTab
    @EnvironmentObject private var app: AppState
    @State private var showEditPlan = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(plan: plan, onSeeAll: { selectedTab = .progress })
                .tabItem {
                    Label(app.t(AppTab.home.titleKey), systemImage: AppTab.home.icon)
                }
                .tag(AppTab.home)

            TimelineScreen(plan: plan)
                .tabItem {
                    Label(app.t(AppTab.timeline.titleKey), systemImage: AppTab.timeline.icon)
                }
                .tag(AppTab.timeline)

            ProgressScreen(plan: plan, onOpenTimeline: { selectedTab = .timeline })
                .tabItem {
                    Label(app.t(AppTab.progress.titleKey), systemImage: AppTab.progress.icon)
                }
                .tag(AppTab.progress)

            SettingsScreen(plan: plan, onEditPlan: { showEditPlan = true })
                .tabItem {
                    Label(app.t(AppTab.settings.titleKey), systemImage: AppTab.settings.icon)
                }
                .tag(AppTab.settings)
        }
        .tint(Color.appAccent)
        .toolbarBackground(Color.appBackground.opacity(0.94), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .fullScreenCover(isPresented: $showEditPlan) {
            OnboardingView(existingPlan: plan, isEdit: true)
                .environmentObject(app)
        }
    }
}
