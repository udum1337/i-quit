import SwiftUI
import SwiftData

struct SlipSheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let plan: UserPlan

    var body: some View {
        SheetChrome {
            SheetIcon(icon: "arrow.clockwise", danger: true)

            SheetTitle(text: app.t("slipTitle"))

            SheetBodyText(text: app.t("slipText"))
                .padding(.top, 12)

            VStack(spacing: 9) {
                PrimarySheetButton(title: app.t("slipConfirm"), danger: true) {
                    confirmSlip()
                }
                SecondarySheetButton(title: app.t("slipCancel")) {
                    dismiss()
                }
            }
            .padding(.top, 24)

            Text(app.t("slipBadge"))
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundStyle(Color.appTextTertiary)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
        }
    }

    private func confirmSlip() {
        let now = app.now
        let snapshot = plan.recordSlip(at: now)
        try? context.save()

        app.updateWidget(for: plan, at: now)
        app.rescheduleNotifications(for: plan)
        dismiss()

        app.showToast(app.t("slipToast"), actionTitle: app.t("undo")) {
            plan.restore(snapshot)
            try? context.save()
            app.updateWidget(for: plan, at: .now)
            app.rescheduleNotifications(for: plan)
            app.showToast(app.t("slipUndone"))
        }
    }
}

struct ResetSheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let plan: UserPlan

    var body: some View {
        SheetChrome {
            SheetIcon(icon: "trash", danger: true)

            SheetTitle(text: app.t("resetTitle"))

            SheetBodyText(text: app.t("resetText"))
                .padding(.top, 12)

            VStack(spacing: 9) {
                PrimarySheetButton(title: app.t("resetConfirm"), danger: true) {
                    reset()
                }
                SecondarySheetButton(title: app.t("resetCancel")) {
                    dismiss()
                }
            }
            .padding(.top, 24)
        }
    }

    private func reset() {
        app.sheet = nil
        NotificationService.cancelAll()
        app.clearWidget()
        context.delete(plan)
        try? context.save()
        app.showToast(app.t("resetToast"))
    }
}

struct CurrencySheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let plan: UserPlan

    private var language: AppLanguage { app.language }

    var body: some View {
        SheetChrome {
            SheetTitle(text: app.t("currency"))

            SheetBodyText(text: app.t("currencySheetSub"))
                .padding(.top, 8)

            VStack(spacing: 8) {
                ForEach(CurrencyCode.allCases) { currency in
                    currencyRow(currency)
                }
            }
            .padding(.top, 18)

            SheetBodyText(text: app.t("currencyHint"), tertiary: true)
                .padding(.top, 14)
        }
    }

    private func currencyRow(_ currency: CurrencyCode) -> some View {
        let selected = plan.currency == currency
        return Button {
            select(currency)
        } label: {
            HStack(spacing: 11) {
                Text(currency.symbol)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(selected ? .white : Color.appTextPrimary)
                    .frame(width: 42, height: 42)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(selected ? Color.appAccent : Color.appFill)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(currency.rawValue)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(currency.label.value(language))
                        .font(.system(size: 10.5))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer(minLength: 6)

                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Color.appAccent)
                }
            }
            .padding(11)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(selected ? Color.appAccentSoft.opacity(0.7) : Color.appCard)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selected ? Color.appAccent.opacity(0.5) : Color.appSeparator, lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func select(_ currency: CurrencyCode) {
        plan.currency = currency
        try? context.save()
        app.updateWidget(for: plan, at: app.now)
        dismiss()
        app.showToast(app.t("currencyChanged"))
    }
}
