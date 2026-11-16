import SwiftUI
import WidgetKit

struct IQuitEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct IQuitProvider: TimelineProvider {
    func placeholder(in context: Context) -> IQuitEntry {
        IQuitEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (IQuitEntry) -> Void) {
        let snapshot = context.isPreview ? WidgetSnapshot.placeholder : (WidgetStore.load() ?? .placeholder)
        completion(IQuitEntry(date: .now, snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<IQuitEntry>) -> Void) {
        let now = Date()
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: now)
            ?? now.addingTimeInterval(1_800)
        completion(
            Timeline(entries: [IQuitEntry(date: now, snapshot: WidgetStore.load())], policy: .after(next))
        )
    }
}

struct IQuitWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: IQuitEntry

    var body: some View {
        Group {
            if let snapshot = entry.snapshot {
                switch family {
                case .systemMedium:
                    MediumWidgetView(snapshot: snapshot, date: entry.date)
                case .accessoryCircular:
                    AccessoryCircularView(snapshot: snapshot, date: entry.date)
                case .accessoryRectangular:
                    AccessoryRectangularView(snapshot: snapshot, date: entry.date)
                case .accessoryInline:
                    AccessoryInlineView(snapshot: snapshot, date: entry.date)
                default:
                    SmallWidgetView(snapshot: snapshot, date: entry.date)
                }
            } else {
                EmptyWidgetView()
            }
        }
    }
}

// MARK: - Home screen widgets

private struct SmallWidgetView: View {
    let snapshot: WidgetSnapshot
    let date: Date

    var body: some View {
        let days = snapshot.currentDays(at: date)

        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                StreakRing(
                    days: days,
                    unit: snapshot.dayWord(for: days),
                    progress: snapshot.progress(at: date),
                    size: 70,
                    lineWidth: 6,
                    tint: .white,
                    track: .white.opacity(0.24)
                )
                Spacer(minLength: 4)
                Image(systemName: "nosign")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white.opacity(0.8))
            }

            Spacer(minLength: 6)

            Text(snapshot.statusLabel)
                .font(.system(size: 11.5, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(spacing: 4) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 8, weight: .semibold))
                Text("\(snapshot.bestLabel): \(snapshot.bestDays(at: date))")
                    .font(.system(size: 9.5, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(.white.opacity(0.82))
            .padding(.top, 2)
        }
        .containerBackground(for: .widget) {
            WidgetBackground()
        }
    }
}

private struct MediumWidgetView: View {
    let snapshot: WidgetSnapshot
    let date: Date

    var body: some View {
        let days = snapshot.currentDays(at: date)
        let next = snapshot.nextMilestone(at: date)

        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 6) {
                StreakRing(
                    days: days,
                    unit: snapshot.dayWord(for: days),
                    progress: snapshot.progress(at: date),
                    size: 78,
                    lineWidth: 7,
                    tint: .white,
                    track: .white.opacity(0.24)
                )
                Text(snapshot.statusLabel)
                    .font(.system(size: 9.5, weight: .bold))
                    .foregroundStyle(.white.opacity(0.86))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: 84)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    Text(snapshot.savedLabel.uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .tracking(0.7)
                        .foregroundStyle(.white.opacity(0.65))
                    Spacer(minLength: 6)
                    Text(snapshot.moneyText(at: date))
                        .font(.system(size: 18, weight: .heavy))
                        .tracking(-0.5)
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }

                Spacer(minLength: 8)

                Text(snapshot.nextLabel.uppercased())
                    .font(.system(size: 8, weight: .bold))
                    .tracking(0.7)
                    .foregroundStyle(.white.opacity(0.65))

                Text(next?.title ?? snapshot.allDoneText)
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .padding(.top, 2)

                ProgressBar(progress: snapshot.progress(at: date))
                    .padding(.top, 7)

                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 8, weight: .semibold))
                    Text("\(snapshot.bestLabel): \(snapshot.bestDays(at: date))")
                        .font(.system(size: 9, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer(minLength: 0)
                }
                .foregroundStyle(.white.opacity(0.78))
                .padding(.top, 6)
            }
        }
        .containerBackground(for: .widget) {
            WidgetBackground()
        }
    }
}

// MARK: - Lock screen widgets

private struct AccessoryCircularView: View {
    let snapshot: WidgetSnapshot
    let date: Date

    var body: some View {
        let days = snapshot.currentDays(at: date)
        let progress = snapshot.progress(at: date)

        ZStack {
            AccessoryWidgetBackground()
            Circle()
                .stroke(.primary.opacity(0.22), lineWidth: 4)
                .padding(4)
            Circle()
                .trim(from: 0, to: max(0.001, progress))
                .stroke(.primary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(4)
            VStack(spacing: 0) {
                Text("\(days)")
                    .font(.system(size: 19, weight: .heavy))
                    .monospacedDigit()
                Text(shortUnit)
                    .font(.system(size: 7, weight: .semibold))
                    .opacity(0.7)
            }
        }
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
    }

    private var shortUnit: String {
        snapshot.languageCode == "ru" ? "дн" : "d"
    }
}

private struct AccessoryRectangularView: View {
    let snapshot: WidgetSnapshot
    let date: Date

    var body: some View {
        let days = snapshot.currentDays(at: date)
        let next = snapshot.nextMilestone(at: date)

        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(days)")
                    .font(.system(size: 20, weight: .heavy))
                    .monospacedDigit()
                Text("\(snapshot.dayWord(for: days)) · \(snapshot.statusLabel)")
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }

            HStack(spacing: 4) {
                Image(systemName: "banknote.fill")
                    .font(.system(size: 9, weight: .semibold))
                Text(snapshot.moneyText(at: date))
                    .font(.system(size: 11, weight: .bold))
                Text("·")
                    .opacity(0.6)
                Text(next?.title ?? snapshot.allDoneText)
                    .font(.system(size: 10))
                    .lineLimit(1)
            }
            .opacity(0.8)

            ProgressBar(progress: snapshot.progress(at: date), height: 3)
                .padding(.top, 3)
        }
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
    }
}

private struct AccessoryInlineView: View {
    let snapshot: WidgetSnapshot
    let date: Date

    var body: some View {
        let days = snapshot.currentDays(at: date)
        Text("\(days) \(snapshot.dayWord(for: days)) · \(snapshot.moneyText(at: date)) · \(snapshot.statusLabel)")
    }
}

// MARK: - Empty state

private struct EmptyWidgetView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "nosign")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white.opacity(0.85))
            Spacer(minLength: 0)
            Text(LocalizedStringKey("widgetEmptyTitle"))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
            Text(LocalizedStringKey("widgetEmptyText"))
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(2)
        }
        .containerBackground(for: .widget) {
            WidgetBackground()
        }
    }
}

// MARK: - Components

private struct StreakRing: View {
    let days: Int
    let unit: String
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let tint: Color
    let track: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(track, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.002, min(1, progress)))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(days)")
                    .font(.system(size: size * 0.34, weight: .heavy))
                    .tracking(-1)
                    .monospacedDigit()
                    .foregroundStyle(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(unit)
                    .font(.system(size: size * 0.105, weight: .semibold))
                    .foregroundStyle(tint.opacity(0.78))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, lineWidth + 2)
        }
        .frame(width: size, height: size)
    }
}

private struct ProgressBar: View {
    let progress: Double
    var height: CGFloat = 5

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.22))
                Capsule()
                    .fill(Color.white)
                    .frame(width: max(0, min(1, progress)) * geometry.size.width)
            }
        }
        .frame(height: height)
    }
}

private struct WidgetBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.72, blue: 0.65),
                    Color(red: 0.04, green: 0.62, blue: 0.86),
                    Color(red: 0.04, green: 0.52, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 210, height: 210)
                .offset(x: 120, y: -90)
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 150, height: 150)
                .offset(x: -100, y: 100)
        }
    }
}

// MARK: - Widget

struct IQuitWidget: Widget {
    let kind = "IQuitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IQuitProvider()) { entry in
            IQuitWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(LocalizedStringKey("widgetName"))
        .description(LocalizedStringKey("widgetDescription"))
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

@main
struct IQuitWidgetBundle: WidgetBundle {
    var body: some Widget {
        IQuitWidget()
    }
}
