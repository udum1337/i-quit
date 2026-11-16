import Foundation
import UserNotifications

enum NotificationService {
    private static let milestoneIdentifier = "iquit.next-milestone"
    private static let achievementIdentifier = "iquit.next-achievement"

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func cancelAll() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [milestoneIdentifier, achievementIdentifier])
        center.removeAllDeliveredNotifications()
    }

    static func reschedule(for plan: UserPlan, language: AppLanguage) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [milestoneIdentifier, achievementIdentifier])
        guard plan.notificationsEnabled else { return }
        let elapsed = plan.elapsed(at: .now)

        if let next = plan.milestoneState(at: .now).next {
            let content = UNMutableNotificationContent()
            content.title = L10n.t("newMilestone", language: language)
            content.body = next.title.value(language)
            content.sound = .default
            let interval = max(60, next.at - elapsed)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: milestoneIdentifier, content: content, trigger: trigger)
            center.add(request, withCompletionHandler: nil)
        }

        if let achievement = Achievements.all
            .filter({ $0.type == .time && $0.value > elapsed })
            .min(by: { $0.value < $1.value }) {
            let content = UNMutableNotificationContent()
            content.title = L10n.t("newAchievement", language: language)
            content.body = achievement.title.value(language)
            content.sound = .default
            let interval = max(60, achievement.value - elapsed)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: achievementIdentifier, content: content, trigger: trigger)
            center.add(request, withCompletionHandler: nil)
        }
    }
}
