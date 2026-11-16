import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var app: AppState

    @Query(sort: \UserPlan.createdAt, order: .forward) private var plans: [UserPlan]
    @State private var selectedTab: AppTab = .home
    @State private var lastWidgetUpdate: Date = .distantPast

    private var plan: UserPlan? { plans.first }

    private var minuteStamp: Int {
        Int(app.now.timeIntervalSince1970 / 60)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if let plan, plan.hasCompletedOnboarding {
                MainTabView(plan: plan, selectedTab: $selectedTab)
                    .transition(.opacity)
            } else {
                OnboardingView(existingPlan: plan, isEdit: false)
                    .transition(.opacity)
            }
        }
        .sheet(item: $app.sheet) { route in
            SheetHost(route: route, plan: plan)
                .presentationDragIndicator(.visible)
                .presentationDetents(detents(for: route))
                .presentationBackground(Color.appElevated)
        }
        .overlay(alignment: .bottom) {
            if let toast = app.toast {
                ToastView(
                    item: toast,
                    onAction: {
                        app.dismissToast()
                        toast.action?()
                    },
                    onDismiss: {
                        app.dismissToast()
                    }
                )
                .padding(.bottom, plan?.hasCompletedOnboarding == true ? 80 : 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(50)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refresh(scheduleNotifications: true) }
        }
        .onChange(of: minuteStamp) { _, _ in
            refresh()
        }
        .onChange(of: plan?.hasCompletedOnboarding) { _, completed in
            if completed == true { selectedTab = .home }
        }
        .onChange(of: plan?.id) { _, id in
            if id == nil { selectedTab = .home }
        }
        .task {
            refresh(scheduleNotifications: true)
        }
    }

    private func detents(for route: SheetRoute) -> Set<PresentationDetent> {
        switch route {
        case .milestone, .sources, .disclaimer, .currency:
            return [.large]
        case .achievement, .slip, .reset:
            return [.medium]
        }
    }

    private func refresh(scheduleNotifications: Bool = false) {
        guard let plan, plan.hasCompletedOnboarding else { return }
        let now = app.now

        let newAchievements = plan.syncAchievements(at: now)
        if !newAchievements.isEmpty {
            try? context.save()
            if let last = newAchievements.last {
                app.showToast("\(app.t("newAchievement")): \(last.title.value(app.language))")
            }
        }

        if now.timeIntervalSince(lastWidgetUpdate) >= 1_800 {
            app.updateWidget(for: plan, at: now)
            lastWidgetUpdate = now
        }

        if scheduleNotifications {
            app.rescheduleNotifications(for: plan)
        }
    }
}
