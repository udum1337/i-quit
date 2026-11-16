import SwiftUI

struct SourcesSheet: View {
    @EnvironmentObject private var app: AppState

    private var language: AppLanguage { app.language }

    var body: some View {
        SheetChrome {
            SheetIcon(icon: "checkmark.shield.fill")

            SheetTitle(text: app.t("sourcesTitle"))

            SheetBodyText(text: app.t("sourcesSub"))
                .padding(.top, 10)

            VStack(spacing: 8) {
                ForEach(HealthSourceCatalog.all) { source in
                    SourceLinkRow(source: source, language: language)
                }
            }
            .padding(.top, 20)

            SheetBodyText(text: app.t("settingsFooter"), tertiary: true)
                .padding(.top, 16)
        }
    }
}

struct DisclaimerSheet: View {
    @EnvironmentObject private var app: AppState

    var body: some View {
        SheetChrome {
            SheetIcon(icon: "info.circle", accent: false)

            SheetTitle(text: app.t("disclaimerTitle"))

            SheetBodyText(text: app.t("disclaimerText"))
                .padding(.top, 12)

            SecondarySheetButton(title: app.t("close")) {
                app.sheet = nil
            }
            .padding(.top, 24)
        }
    }
}
