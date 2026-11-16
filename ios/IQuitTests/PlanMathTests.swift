import XCTest
@testable import IQuit

final class PlanMathTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    private func makePlan(
        product: ProductKind = .cigarettes,
        quitAgo: TimeInterval = 12 * 86_400,
        unitsPerDay: Double = 20,
        price: Double = 250,
        unitsPerPackage: Double = 20
    ) -> UserPlan {
        UserPlan(
            product: product,
            quitDate: now.addingTimeInterval(-quitAgo),
            unitsPerDay: unitsPerDay,
            pricePerPackage: price,
            unitsPerPackage: unitsPerPackage
        )
    }

    func testCostPerDayForCigarettes() {
        let plan = makePlan()
        XCTAssertEqual(plan.costPerDay, 250, accuracy: 0.001)
    }

    func testCostPerDayForVape() {
        let plan = makePlan(
            product: .vape,
            unitsPerDay: 3,
            price: 900,
            unitsPerPackage: 30
        )
        XCTAssertEqual(plan.costPerDay, 90, accuracy: 0.001)
    }

    func testCostPerDayForHookahUsesWeeklySessions() {
        let plan = makePlan(
            product: .hookah,
            unitsPerDay: 3.0 / 7.0,
            price: 500,
            unitsPerPackage: 1
        )
        XCTAssertEqual(plan.costPerDay, 500 * 3 / 7, accuracy: 0.0001)
    }

    func testSavedAndAvoidedTotals() {
        let plan = makePlan()
        XCTAssertEqual(plan.savedTotal(at: now), 3_000, accuracy: 0.01)
        XCTAssertEqual(plan.avoidedTotal(at: now), 240, accuracy: 0.01)
        XCTAssertEqual(plan.currentDays(at: now), 12)
        XCTAssertEqual(plan.totalDays(at: now), 12)
        XCTAssertEqual(plan.bestDays(at: now), 12)
    }

    func testMilestoneStateAtThirteenDays() {
        let plan = makePlan(quitAgo: 13 * 86_400)
        let state = plan.milestoneState(at: now)

        XCTAssertEqual(state.unlocked.count, 5)
        XCTAssertEqual(state.previous?.id, "m72h")
        XCTAssertEqual(state.next?.id, "m2w")
        XCTAssertEqual(state.progress, 10.0 / 11.0, accuracy: 0.0001)
    }

    func testMilestoneStateAfterAllMilestones() {
        let plan = makePlan(quitAgo: 21 * 365 * 86_400)
        let state = plan.milestoneState(at: now)

        XCTAssertEqual(state.unlocked.count, HealthMilestones.all.count)
        XCTAssertNil(state.next)
        XCTAssertEqual(state.progress, 1, accuracy: 0.0001)
    }

    func testAchievementsAtPrototypeDemoState() {
        let plan = makePlan(quitAgo: 12 * 86_400 + 4 * 3_600 + 32 * 60)
        let newlyUnlocked = plan.syncAchievements(at: now)

        XCTAssertEqual(newlyUnlocked.count, 7)
        XCTAssertEqual(plan.unlockedAchievements(at: now).count, 7)
        XCTAssertEqual(plan.lockedAchievements(at: now).count, 10)
        XCTAssertTrue(plan.unlockedIDs.contains("a1w"))
        XCTAssertTrue(plan.unlockedIDs.contains("money1k"))
        XCTAssertFalse(plan.unlockedIDs.contains("slip"))
    }

    func testSyncAchievementsIsIdempotent() {
        let plan = makePlan()
        let first = plan.syncAchievements(at: now)
        let second = plan.syncAchievements(at: now)

        XCTAssertGreaterThan(first.count, 0)
        XCTAssertEqual(second.count, 0)
        XCTAssertEqual(plan.unlockedIDs.count, Set(plan.unlockedIDs).count)
    }

    func testMoneyAchievementDescriptionReplacesAmount() {
        let plan = makePlan()
        guard let achievement = Achievements.byID["money10k"] else {
            return XCTFail("Missing money10k achievement")
        }

        let text = plan.achievementDescription(achievement, language: .ru)
        XCTAssertFalse(text.contains("{amount}"))
        XCTAssertTrue(text.contains("₽"))
    }

    func testSlipFreezesStreakAndUndoRestoresIt() {
        let plan = makePlan(quitAgo: 10 * 86_400)
        plan.savedBase = 500

        let snapshot = plan.recordSlip(at: now)

        XCTAssertEqual(plan.slips, 1)
        XCTAssertEqual(plan.elapsed(at: now), 0, accuracy: 0.001)
        XCTAssertEqual(plan.priorCleanSeconds, 10 * 86_400, accuracy: 0.001)
        XCTAssertEqual(plan.bestStreakSeconds, 10 * 86_400, accuracy: 0.001)
        XCTAssertEqual(plan.savedTotal(at: now), 3_000, accuracy: 0.01)
        XCTAssertEqual(plan.avoidedTotal(at: now), 200, accuracy: 0.01)
        XCTAssertTrue(plan.unlockedIDs.contains("slip"))

        plan.restore(snapshot)

        XCTAssertEqual(plan.slips, 0)
        XCTAssertEqual(plan.savedBase, 500, accuracy: 0.001)
        XCTAssertEqual(plan.elapsed(at: now), 10 * 86_400, accuracy: 0.001)
        XCTAssertFalse(plan.unlockedIDs.contains("slip"))
    }

    func testSecondSlipKeepsLifetimeTotals() {
        let plan = makePlan(quitAgo: 5 * 86_400)
        plan.recordSlip(at: now)
        let secondSlipTime = now.addingTimeInterval(2 * 86_400)

        plan.recordSlip(at: secondSlipTime)

        XCTAssertEqual(plan.slips, 2)
        XCTAssertEqual(plan.priorCleanSeconds, 7 * 86_400, accuracy: 0.001)
        XCTAssertEqual(plan.bestStreakSeconds, 5 * 86_400, accuracy: 0.001)
        XCTAssertEqual(plan.totalDays(at: secondSlipTime), 7)
        XCTAssertEqual(plan.currentDays(at: secondSlipTime), 0)
    }

    func testPlanDraftValidationAndWeeklyConversion() {
        var draft = PlanDraft(product: .hookah, currency: .USD)
        draft.units = 3
        draft.price = 500

        XCTAssertEqual(draft.unitsPerDay, 3.0 / 7.0, accuracy: 0.0001)
        XCTAssertEqual(draft.calculatedCostPerDay, 500 * 3 / 7, accuracy: 0.0001)
        XCTAssertTrue(draft.isValidMoney)

        draft.units = 0
        XCTAssertFalse(draft.isValidMoney)
    }

    func testPlanDraftRoundTrip() {
        let plan = makePlan(product: .hookah, quitAgo: 7 * 86_400, unitsPerDay: 2.0 / 7.0, price: 400, unitsPerPackage: 1)
        plan.currency = .KZT
        plan.notificationsEnabled = false

        let draft = PlanDraft(plan: plan)

        XCTAssertEqual(draft.product, .hookah)
        XCTAssertEqual(draft.units, 2, accuracy: 0.0001)
        XCTAssertEqual(draft.currency, .KZT)
        XCTAssertFalse(draft.notifications)
    }

    func testWidgetSnapshotPluralizationAndMoney() {
        var snapshot = WidgetSnapshot.placeholder
        snapshot.languageCode = "ru"

        XCTAssertEqual(snapshot.dayWord(for: 1), "день")
        XCTAssertEqual(snapshot.dayWord(for: 2), "дня")
        XCTAssertEqual(snapshot.dayWord(for: 5), "дней")
        XCTAssertEqual(snapshot.dayWord(for: 11), "дней")
        XCTAssertEqual(snapshot.dayWord(for: 21), "день")
        XCTAssertTrue(snapshot.moneyText(at: now).contains("₽"))

        snapshot.languageCode = "en"
        snapshot.dayOne = "day"
        snapshot.dayFew = "days"
        snapshot.dayMany = "days"
        XCTAssertEqual(snapshot.dayWord(for: 1), "day")
        XCTAssertEqual(snapshot.dayWord(for: 2), "days")
    }

    func testWidgetSnapshotProgress() {
        var snapshot = WidgetSnapshot.placeholder
        snapshot.quitDate = now.addingTimeInterval(-12 * 86_400)

        XCTAssertEqual(snapshot.currentDays(at: now), 12)
        XCTAssertEqual(snapshot.progress(at: now), 9.0 / 11.0, accuracy: 0.0001)
        XCTAssertEqual(snapshot.nextMilestone(at: now)?.id, "m2w")
        XCTAssertEqual(snapshot.currentMilestone(at: now)?.id, "m72h")
    }
}
