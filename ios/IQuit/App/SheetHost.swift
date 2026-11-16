import SwiftUI

struct SheetHost: View {
    let route: SheetRoute
    let plan: UserPlan?

    var body: some View {
        Group {
            switch route {
            case .milestone(let id):
                MilestoneDetailView(milestoneID: id, plan: plan)
            case .achievement(let id):
                AchievementDetailView(achievementID: id, plan: plan)
            case .sources:
                SourcesSheet()
            case .disclaimer:
                DisclaimerSheet()
            case .slip:
                if let plan {
                    SlipSheet(plan: plan)
                }
            case .reset:
                if let plan {
                    ResetSheet(plan: plan)
                }
            case .currency:
                if let plan {
                    CurrencySheet(plan: plan)
                }
            }
        }
    }
}
