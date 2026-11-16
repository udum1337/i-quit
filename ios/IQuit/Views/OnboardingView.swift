import SwiftUI
import SwiftData

struct OnboardingView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let existingPlan: UserPlan?
    let isEdit: Bool

    @State private var step: Int
    @State private var draft: PlanDraft
    @State private var unitsText: String
    @State private var priceText: String
    @State private var packText: String
    @State private var isSaving = false

    init(existingPlan: UserPlan?, isEdit: Bool) {
        self.existingPlan = existingPlan
        self.isEdit = isEdit

        let initial = existingPlan.map(PlanDraft.init(plan:)) ?? PlanDraft()
        _draft = State(initialValue: initial)
        _step = State(initialValue: isEdit ? 2 : 1)
        _unitsText = State(initialValue: Self.text(initial.units))
        _priceText = State(initialValue: Self.text(initial.price))
        _packText = State(initialValue: Self.text(initial.pack))
    }

    private var language: AppLanguage { app.language }

    private var canGoBack: Bool {
        step > 1 && !(isEdit && step == 2)
    }

    private var footerTitle: String {
        if step == 1 { return app.t("obStart") }
        if step == 5 { return app.t(isEdit ? "obSave" : "obFinish") }
        return app.t("next")
    }

    private var calculatedCost: Double {
        let units = Self.parse(unitsText)
        let price = Self.parse(priceText)
        let pack = Self.parse(packText)
        if draft.product.isPerWeek {
            return max(0, price) * (max(0, units) / 7)
        }
        return max(0, price) / max(1, pack) * max(0, units)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, 18)
                .padding(.top, 8)

            ScrollView {
                stepContent
                    .padding(.horizontal, 22)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)

            footer
                .padding(.horizontal, 22)
                .padding(.top, 10)
                .padding(.bottom, 26)
                .background(
                    LinearGradient(
                        colors: [Color.appBackground.opacity(0), Color.appBackground],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
        }
        .background(Color.appBackground)
    }

    // MARK: - Chrome

    private var topBar: some View {
        HStack(spacing: 10) {
            Button {
                back()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.appFill))
            }
            .buttonStyle(.plain)
            .opacity(canGoBack ? 1 : 0)
            .disabled(!canGoBack)
            .accessibilityLabel(app.t("back"))

            Spacer(minLength: 4)

            HStack(spacing: 5) {
                ForEach(1...5, id: \.self) { index in
                    Capsule()
                        .fill(index == step ? Color.appAccent : Color.appFill)
                        .frame(width: index == step ? 18 : 5, height: 5)
                        .animation(.easeInOut(duration: 0.2), value: step)
                }
            }

            Spacer(minLength: 4)

            Button {
                skip()
            } label: {
                Text(isEdit ? app.t("cancel") : app.t("obSkip"))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(6)
            }
            .buttonStyle(.plain)
        }
    }

    private var footer: some View {
        Button {
            advance()
        } label: {
            ZStack {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(footerTitle)
                        .font(.system(size: 15, weight: .bold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.buttonGradient)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
            .shadow(color: Color(hex: 0x0A84FF).opacity(0.24), radius: 13, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(isSaving)
        .opacity(isSaving ? 0.7 : 1)
    }

    // MARK: - Steps

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 1: welcomeStep
        case 2: productStep
        case 3: dateStep
        case 4: moneyStep
        default: notificationsStep
        }
    }

    private var welcomeStep: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color.heroGradient)
                    .frame(width: 150, height: 150)
                    .shadow(color: Color(hex: 0x0A84FF).opacity(0.22), radius: 25, y: 14)
                Circle()
                    .stroke(Color.appAccent.opacity(0.22), lineWidth: 1)
                    .frame(width: 174, height: 174)
                Image(systemName: "nosign")
                    .font(.system(size: 62, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(.top, 18)
            .padding(.bottom, 22)

            Text(app.t("obWelcomeTitle"))
                .font(.system(size: 28, weight: .heavy))
                .tracking(-1.2)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextPrimary)

            Text(app.t("obWelcomeSub"))
                .font(.system(size: 13))
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextSecondary)
                .frame(maxWidth: 300)
                .padding(.top, 10)

            VStack(spacing: 10) {
                feature(icon: "trophy.fill", text: app.t("obFeature1"))
                feature(icon: "heart.fill", text: app.t("obFeature2"))
                feature(icon: "banknote.fill", text: app.t("obFeature3"))
            }
            .padding(.top, 24)
            .padding(.bottom, 8)
        }
    }

    private func feature(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appAccent)
                .frame(width: 30, height: 30)
                .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(Color.appAccentSoft))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.appCard, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var productStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(isEdit ? app.t("obEditTitle") : app.t("obProductTitle"))
                .font(.system(size: 25, weight: .heavy))
                .tracking(-1)
                .foregroundStyle(Color.appTextPrimary)
                .padding(.top, 6)

            Text(app.t("obProductSub"))
                .font(.system(size: 12.5))
                .lineSpacing(3)
                .foregroundStyle(Color.appTextSecondary)
                .padding(.top, 8)

            VStack(spacing: 9) {
                HStack(spacing: 9) {
                    ForEach(Array(ProductKind.allCases.prefix(4))) { product in
                        productOption(product)
                    }
                }
                productOption(.snus, horizontal: true)
            }
            .padding(.top, 18)
        }
    }

    private func productOption(_ product: ProductKind, horizontal: Bool = false) -> some View {
        let selected = draft.product == product
        return Button {
            selectProduct(product)
        } label: {
            Group {
                if horizontal {
                    HStack(spacing: 10) {
                        productIcon(product, selected: selected)
                        Text(product.name.value(language))
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer(minLength: 0)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        productIcon(product, selected: selected)
                        Text(product.name.value(language))
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundStyle(Color.appTextPrimary)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(selected ? Color.appAccentSoft : Color.appCard)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selected ? Color.appAccent : Color.clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }

    private func productIcon(_ product: ProductKind, selected: Bool) -> some View {
        Image(systemName: product.icon)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(selected ? .white : Color.appTextSecondary)
            .frame(width: 38, height: 38)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(selected ? Color.appAccent : Color.appFill)
            )
    }

    private var dateStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(app.t("obQuitTitle"))
                .font(.system(size: 25, weight: .heavy))
                .tracking(-1)
                .foregroundStyle(Color.appTextPrimary)
                .padding(.top, 6)

            Text(app.t("obQuitSub"))
                .font(.system(size: 12.5))
                .lineSpacing(3)
                .foregroundStyle(Color.appTextSecondary)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel(app.t("quitDate"))
                DatePicker(
                    "",
                    selection: $draft.quitDate,
                    in: ...Date(),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .environment(\.locale, language.locale)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appCard, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.appSeparator, lineWidth: 1)
                }
            }
            .padding(.top, 18)

            HStack(spacing: 6) {
                quickChip(days: 0, label: app.t("obQuickNow"))
                quickChip(days: 1, label: app.t("obQuickYesterday"))
                quickChip(days: 3, label: app.t("obQuick3"))
                quickChip(days: 7, label: app.t("obQuickWeek"))
            }
            .padding(.top, 12)

            Text(app.t("obNoteDate"))
                .font(.system(size: 10.5))
                .lineSpacing(2)
                .foregroundStyle(Color.appTextTertiary)
                .padding(.top, 12)
        }
    }

    private func quickChip(days: Int, label: String) -> some View {
        let target = Date().addingTimeInterval(-Double(days) * 86_400)
        let active = abs(draft.quitDate.timeIntervalSince(target)) < 5 * 60
        return Button {
            draft.quitDate = target
        } label: {
            Text(label)
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundStyle(active ? Color.appAccent : Color.appTextSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Capsule().fill(active ? Color.appAccentSoft : Color.appFill))
        }
        .buttonStyle(.plain)
    }

    private var moneyStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(app.t("obMoneyTitle"))
                .font(.system(size: 25, weight: .heavy))
                .tracking(-1)
                .foregroundStyle(Color.appTextPrimary)
                .padding(.top, 6)

            Text(app.t("obMoneySub"))
                .font(.system(size: 12.5))
                .lineSpacing(3)
                .foregroundStyle(Color.appTextSecondary)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel(draft.product.unitLabel.value(language))
                inputField($unitsText)
            }
            .padding(.top, 16)

            VStack(alignment: .leading, spacing: 6) {
                fieldLabel(app.t("currency"))
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4),
                    spacing: 6
                ) {
                    ForEach(CurrencyCode.allCases) { currency in
                        currencyChip(currency)
                    }
                }
                Text(app.t("currencyHint"))
                    .font(.system(size: 10.5))
                    .lineSpacing(2)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.horizontal, 2)
                    .padding(.top, 2)
            }
            .padding(.top, 16)

            HStack(alignment: .top, spacing: 9) {
                VStack(alignment: .leading, spacing: 6) {
                    fieldLabel(draft.product.priceLabel.value(language))
                    inputField($priceText)
                }
                if let packLabel = draft.product.packLabel {
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel(packLabel.value(language))
                        inputField($packText)
                    }
                }
            }
            .padding(.top, 16)

            HStack {
                Text(app.t("obPerDay"))
                    .font(.system(size: 11.5))
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text(Format.money(calculatedCost, currency: draft.currency, language: language))
                    .font(.system(size: 15, weight: .heavy))
                    .tracking(-0.3)
                    .monospacedDigit()
                    .foregroundStyle(Color.appTextPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Color.appCard, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
            .padding(.top, 14)

            Text(app.t("obNoteMoney"))
                .font(.system(size: 10.5))
                .lineSpacing(2)
                .foregroundStyle(Color.appTextTertiary)
                .padding(.top, 12)
        }
    }

    private var notificationsStep: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color.appAccentSoft)
                    .frame(width: 130, height: 130)
                Image(systemName: "bell.fill")
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
            }
            .padding(.top, 30)
            .padding(.bottom, 26)

            Text(app.t("obNotificationsTitle"))
                .font(.system(size: 25, weight: .heavy))
                .tracking(-1)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextPrimary)

            Text(app.t("obNotificationsSub"))
                .font(.system(size: 12.5))
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextSecondary)
                .padding(.top, 8)

            HStack(spacing: 11) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(width: 28, height: 28)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.appFill))
                Text(app.t("obBell"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Toggle("", isOn: $draft.notifications)
                    .labelsHidden()
                    .tint(Color.appAccent)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.appCard, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(.top, 20)

            Text(app.t("obNoteNotifications"))
                .font(.system(size: 10.5))
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextTertiary)
                .padding(.top, 12)
        }
    }

    private func currencyChip(_ currency: CurrencyCode) -> some View {
        let selected = draft.currency == currency
        return Button {
            draft.currency = currency
        } label: {
            HStack(spacing: 4) {
                Text(currency.symbol)
                    .font(.system(size: 13, weight: .heavy))
                Text(currency.rawValue)
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundStyle(Color.appTextPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(selected ? Color.appAccentSoft : Color.appFill)
            )
            .overlay {
                if selected {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .stroke(Color.appAccent, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10.5, weight: .bold))
            .tracking(0.6)
            .textCase(.uppercase)
            .foregroundStyle(Color.appTextTertiary)
            .padding(.horizontal, 2)
    }

    private func inputField(_ text: Binding<String>) -> some View {
        TextField("0", text: text)
            .keyboardType(.decimalPad)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Color.appTextPrimary)
            .padding(14)
            .background(Color.appCard, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.appSeparator, lineWidth: 1)
            }
    }

    // MARK: - Actions

    private func advance() {
        switch step {
        case 1:
            go(to: 2)
        case 2:
            go(to: 3)
        case 3:
            guard draft.quitDate <= Date() else {
                app.showToast(app.t("obNoteDate"))
                return
            }
            go(to: 4)
        case 4:
            syncMoneyFields()
            guard draft.isValidMoney else {
                app.showToast(app.t("obErrorMoney"))
                return
            }
            go(to: 5)
        default:
            Task { await finish() }
        }
    }

    private func back() {
        guard canGoBack else { return }
        go(to: step - 1)
    }

    private func go(to newStep: Int) {
        withAnimation(.easeInOut(duration: 0.22)) {
            step = min(5, max(1, newStep))
        }
    }

    private func skip() {
        if isEdit {
            dismiss()
            return
        }
        if step < 5 {
            draft.notifications = false
            syncMoneyFields()
            if !draft.isValidMoney {
                draft.units = draft.product.defaults.units
                draft.price = draft.product.defaults.price
                draft.pack = draft.product.defaults.pack
                unitsText = Self.text(draft.units)
                priceText = Self.text(draft.price)
                packText = Self.text(draft.pack)
            }
        }
        Task { await finish() }
    }

    private func selectProduct(_ product: ProductKind) {
        draft.applyDefaults(for: product)
        unitsText = Self.text(draft.units)
        priceText = Self.text(draft.price)
        packText = Self.text(draft.pack)
    }

    private func syncMoneyFields() {
        draft.units = Self.parse(unitsText)
        draft.price = Self.parse(priceText)
        draft.pack = Self.parse(packText)
    }

    @MainActor
    private func finish() async {
        guard !isSaving else { return }
        syncMoneyFields()
        guard draft.isValidMoney else {
            app.showToast(app.t("obErrorMoney"))
            return
        }
        guard draft.quitDate <= Date() else {
            app.showToast(app.t("obNoteDate"))
            return
        }

        isSaving = true
        let granted: Bool
        if draft.notifications {
            granted = await NotificationService.requestAuthorization()
        } else {
            granted = false
        }

        let now = Date()
        let plan: UserPlan
        if let existingPlan {
            plan = existingPlan
        } else {
            plan = UserPlan()
            context.insert(plan)
        }

        let wasEdit = isEdit

        plan.product = draft.product
        plan.quitDate = min(draft.quitDate, now)
        plan.unitsPerDay = draft.unitsPerDay
        plan.pricePerPackage = max(0, draft.price)
        plan.unitsPerPackage = draft.unitsPerPackage
        plan.currency = draft.currency
        plan.notificationsEnabled = draft.notifications && granted

        if wasEdit {
            plan.savedBase = (plan.priorCleanSeconds / 86_400) * plan.costPerDay
            plan.avoidedBase = (plan.priorCleanSeconds / 86_400) * plan.unitsPerDay
        } else {
            plan.priorCleanSeconds = 0
            plan.bestStreakSeconds = 0
            plan.savedBase = 0
            plan.avoidedBase = 0
            plan.slips = 0
            plan.unlockedIDs = []
        }

        plan.hasCompletedOnboarding = true
        plan.syncAchievements(at: now)
        try? context.save()

        app.updateWidget(for: plan, at: now)
        app.rescheduleNotifications(for: plan)
        isSaving = false

        if wasEdit {
            dismiss()
        }
        app.showToast(app.t(wasEdit ? "planUpdated" : "journeyStarted"))
    }

    private static func parse(_ text: String) -> Double {
        Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private static func text(_ value: Double) -> String {
        if value == value.rounded() {
            return String(Int(value))
        }
        return String(format: "%.1f", value)
    }
}
