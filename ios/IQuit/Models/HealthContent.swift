import Foundation

struct HealthSource: Identifiable, Hashable {
    let id: String
    let org: String
    let title: LocalizedText
    let url: String
}

enum HealthSourceCatalog {
    static let all: [HealthSource] = [
        HealthSource(
            id: "who",
            org: "WHO",
            title: LocalizedText(
                ru: "Tobacco: health benefits of smoking cessation",
                en: "Tobacco: health benefits of smoking cessation"
            ),
            url: "https://www.who.int/news-room/questions-and-answers/item/tobacco-health-benefits-of-smoking-cessation"
        ),
        HealthSource(
            id: "cdc",
            org: "CDC",
            title: LocalizedText(ru: "Benefits of Quitting Smoking", en: "Benefits of Quitting Smoking"),
            url: "https://www.cdc.gov/tobacco/about/benefits-of-quitting.html"
        ),
        HealthSource(
            id: "nhs",
            org: "NHS",
            title: LocalizedText(ru: "Quit smoking — Better Health", en: "Quit smoking — Better Health"),
            url: "https://www.nhs.uk/better-health/quit-smoking/"
        ),
        HealthSource(
            id: "acs",
            org: "American Cancer Society",
            title: LocalizedText(
                ru: "Health Benefits of Quitting Smoking Over Time",
                en: "Health Benefits of Quitting Smoking Over Time"
            ),
            url: "https://www.cancer.org/cancer/risk-prevention/tobacco/guide-quitting-smoking/benefits-of-quitting-smoking-over-time.html"
        ),
        HealthSource(
            id: "ala",
            org: "American Lung Association",
            title: LocalizedText(ru: "Benefits of Quitting", en: "Benefits of Quitting"),
            url: "https://www.lung.org/quit-smoking/i-want-to-quit/benefits-of-quitting"
        ),
        HealthSource(
            id: "cleveland",
            org: "Cleveland Clinic",
            title: LocalizedText(
                ru: "What Happens to Your Body When You Quit Smoking?",
                en: "What Happens to Your Body When You Quit Smoking?"
            ),
            url: "https://health.clevelandclinic.org/happens-body-quit-smoking"
        ),
        HealthSource(
            id: "medline",
            org: "MedlinePlus",
            title: LocalizedText(ru: "Benefits of quitting tobacco", en: "Benefits of quitting tobacco"),
            url: "https://medlineplus.gov/ency/article/007532.htm"
        )
    ]

    static let byID: [String: HealthSource] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
}

enum MilestoneGroup: String, CaseIterable, Identifiable {
    case hours
    case days
    case months
    case years

    var id: String { rawValue }

    var labelKey: String {
        switch self {
        case .hours: return "groupHours"
        case .days: return "groupDays"
        case .months: return "groupMonths"
        case .years: return "groupYears"
        }
    }
}

struct HealthMilestone: Identifiable, Hashable {
    let id: String
    let at: TimeInterval
    let group: MilestoneGroup
    let icon: String
    let time: LocalizedText
    let title: LocalizedText
    let desc: LocalizedText
    let long: LocalizedText
    let sources: [String]
}

enum HealthMilestones {
    private static let day: TimeInterval = 86_400
    private static let year: TimeInterval = 365 * 86_400

    static let all: [HealthMilestone] = [
        HealthMilestone(
            id: "m20m", at: 20 * 60, group: .hours, icon: "heart.fill",
            time: LocalizedText(ru: "20 минут", en: "20 minutes"),
            title: LocalizedText(ru: "Пульс приходит в норму", en: "Heart rate normalizes"),
            desc: LocalizedText(
                ru: "Пульс и давление снижаются, кровоток в кистях и стопах улучшается.",
                en: "Heart rate and blood pressure drop, and blood flow to hands and feet improves."
            ),
            long: LocalizedText(
                ru: "Никотин сужает сосуды и заставляет сердце биться чаще. Уже через 20 минут после последней сигареты пульс и артериальное давление начинают снижаться, а сосуды постепенно расширяются.",
                en: "Nicotine narrows blood vessels and makes your heart work harder. Within 20 minutes of your last cigarette, heart rate and blood pressure start to drop, and blood vessels begin to relax."
            ),
            sources: ["who", "nhs", "cleveland"]
        ),
        HealthMilestone(
            id: "m8h", at: 8 * 3_600, group: .hours, icon: "wind",
            time: LocalizedText(ru: "8 часов", en: "8 hours"),
            title: LocalizedText(ru: "Кислород возвращается", en: "Oxygen levels rise"),
            desc: LocalizedText(
                ru: "Угарный газ в крови снижается примерно вдвое, уровень кислорода растёт.",
                en: "Carbon monoxide in your blood drops by about half, and oxygen levels rise."
            ),
            long: LocalizedText(
                ru: "Угарный газ из дыма занимает место кислорода в крови. Через 8 часов его уровень снижается примерно вдвое, и тканям начинает доставаться больше кислорода.",
                en: "Carbon monoxide from smoke takes the place of oxygen in your blood. After 8 hours, its level drops by about half, and your tissues get more oxygen."
            ),
            sources: ["nhs", "cleveland"]
        ),
        HealthMilestone(
            id: "m12_24h", at: 12 * 3_600, group: .hours, icon: "drop.fill",
            time: LocalizedText(ru: "12–24 часа", en: "12–24 hours"),
            title: LocalizedText(ru: "Никотин покидает кровь", en: "Nicotine leaves your blood"),
            desc: LocalizedText(
                ru: "Угарный газ приходит к норме, никотин падает до нуля. Риск инфаркта начинает снижаться.",
                en: "Carbon monoxide returns to normal and nicotine drops to zero. Heart attack risk starts to fall."
            ),
            long: LocalizedText(
                ru: "Уровень угарного газа в крови возвращается к норме, а никотин практически полностью выводится. Одновременно начинает снижаться риск сердечного приступа.",
                en: "Carbon monoxide levels return to normal, and nicotine is almost completely cleared. At the same time, your risk of a heart attack starts to decrease."
            ),
            sources: ["who", "cdc", "acs", "ala"]
        ),
        HealthMilestone(
            id: "m48h", at: 48 * 3_600, group: .days, icon: "leaf.fill",
            time: LocalizedText(ru: "48 часов", en: "48 hours"),
            title: LocalizedText(ru: "Лёгкие начинают очищаться", en: "Your lungs start to clear"),
            desc: LocalizedText(
                ru: "Организм выводит слизь и продукты горения. Вкус и запах становятся ярче.",
                en: "Your body clears mucus and smoke residue. Taste and smell improve."
            ),
            long: LocalizedText(
                ru: "Лёгкие начинают избавляться от слизи и продуктов горения. Восстанавливаются нервные окончания, поэтому вкус и запах ощущаются ярче.",
                en: "Your lungs begin to clear mucus and smoke residue. Nerve endings start to recover, so taste and smell become more vivid."
            ),
            sources: ["nhs", "cleveland"]
        ),
        HealthMilestone(
            id: "m72h", at: 72 * 3_600, group: .days, icon: "lungs.fill",
            time: LocalizedText(ru: "72 часа", en: "72 hours"),
            title: LocalizedText(ru: "Дышать легче", en: "Breathing gets easier"),
            desc: LocalizedText(
                ru: "Бронхи расслабляются, дыхание становится свободнее, энергии больше.",
                en: "Bronchial tubes relax, breathing feels easier, and energy levels rise."
            ),
            long: LocalizedText(
                ru: "Бронхи расслабляются после постоянного раздражения дымом. Дыхание становится свободнее, а уровень энергии — выше.",
                en: "Your bronchial tubes relax after constant irritation from smoke. Breathing feels easier, and energy levels increase."
            ),
            sources: ["nhs", "cleveland"]
        ),
        HealthMilestone(
            id: "m2w", at: 14 * day, group: .months, icon: "waveform.path.ecg",
            time: LocalizedText(ru: "2 недели", en: "2 weeks"),
            title: LocalizedText(ru: "Кровообращение улучшается", en: "Circulation improves"),
            desc: LocalizedText(
                ru: "Кровообращение и функция лёгких улучшаются. Нагрузки переносятся легче.",
                en: "Circulation and lung function improve. Physical activity feels easier."
            ),
            long: LocalizedText(
                ru: "Кровообращение улучшается, а функция лёгких начинает расти. Ходьба и физические нагрузки переносятся заметно легче.",
                en: "Circulation improves, and lung function begins to increase. Walking and physical activity feel noticeably easier."
            ),
            sources: ["who", "ala", "cleveland"]
        ),
        HealthMilestone(
            id: "m1m", at: 30 * day, group: .months, icon: "wind",
            time: LocalizedText(ru: "1 месяц", en: "1 month"),
            title: LocalizedText(ru: "Кашель и одышка отступают", en: "Cough and breathlessness ease"),
            desc: LocalizedText(
                ru: "Кашель и одышка уменьшаются. Реснички в лёгких восстанавливаются.",
                en: "Coughing and shortness of breath decrease. Cilia in your lungs recover."
            ),
            long: LocalizedText(
                ru: "Кашель и одышка уменьшаются. Реснички в дыхательных путях восстанавливаются и снова помогают очищать лёгкие от слизи.",
                en: "Coughing and shortness of breath decrease. Cilia in your airways recover and start helping clear mucus from your lungs again."
            ),
            sources: ["ala", "medline", "cleveland"]
        ),
        HealthMilestone(
            id: "m3m", at: 90 * day, group: .months, icon: "heart.fill",
            time: LocalizedText(ru: "3 месяца", en: "3 months"),
            title: LocalizedText(ru: "Риск инфаркта снижается", en: "Heart attack risk drops"),
            desc: LocalizedText(
                ru: "Риск инфаркта начинает снижаться, переносимость нагрузок растёт.",
                en: "Heart attack risk starts to fall, and exercise tolerance improves."
            ),
            long: LocalizedText(
                ru: "Риск сердечного приступа начинает снижаться, а переносимость физических нагрузок продолжает расти.",
                en: "Your risk of a heart attack begins to decrease, and exercise tolerance continues to improve."
            ),
            sources: ["ala", "cleveland"]
        ),
        HealthMilestone(
            id: "m9m", at: 270 * day, group: .months, icon: "checkmark.shield.fill",
            time: LocalizedText(ru: "9 месяцев", en: "9 months"),
            title: LocalizedText(ru: "Реснички восстановились", en: "Cilia have recovered"),
            desc: LocalizedText(
                ru: "Реснички работают нормально: меньше кашля, слизи и инфекций.",
                en: "Cilia work normally: less coughing, mucus, and infection."
            ),
            long: LocalizedText(
                ru: "Реснички в лёгких снова работают нормально. Они выводят слизь и вместе с ней — часть бактерий и раздражителей, поэтому реже беспокоят кашель и инфекции.",
                en: "Cilia in your lungs are working normally again. They move mucus — and some bacteria and irritants with it — out of your airways, so coughing and infections become less frequent."
            ),
            sources: ["ala", "cleveland", "medline"]
        ),
        HealthMilestone(
            id: "m1y", at: year, group: .years, icon: "star.fill",
            time: LocalizedText(ru: "1 год", en: "1 year"),
            title: LocalizedText(ru: "Сердце вдвое спокойнее", en: "Heart risk halves"),
            desc: LocalizedText(
                ru: "Добавочный риск ишемической болезни сердца вдвое ниже, чем у курящего.",
                en: "Added risk of coronary heart disease is half that of someone who smokes."
            ),
            long: LocalizedText(
                ru: "Добавочный риск ишемической болезни сердца становится вдвое ниже, чем у человека, который продолжает курить.",
                en: "Your added risk of coronary heart disease is half that of someone who continues to smoke."
            ),
            sources: ["who", "cdc", "nhs"]
        ),
        HealthMilestone(
            id: "m2y", at: 2 * year, group: .years, icon: "waveform.path.ecg",
            time: LocalizedText(ru: "2 года", en: "2 years"),
            title: LocalizedText(ru: "Риск инфаркта падает резко", en: "Heart attack risk drops sharply"),
            desc: LocalizedText(
                ru: "Риск инфаркта снижается резко и продолжает падать дальше.",
                en: "Heart attack risk drops sharply and continues to decline."
            ),
            long: LocalizedText(
                ru: "Через 1–2 года после отказа риск сердечного приступа снижается резко. Дальше он продолжает уменьшаться постепенно.",
                en: "One to two years after quitting, your risk of a heart attack drops sharply. After that, it continues to decline gradually."
            ),
            sources: ["cdc", "acs"]
        ),
        HealthMilestone(
            id: "m3_6y", at: 3 * year, group: .years, icon: "checkmark.shield.fill",
            time: LocalizedText(ru: "3–6 лет", en: "3–6 years"),
            title: LocalizedText(ru: "Коронарный риск снижается вдвое", en: "Coronary risk halves"),
            desc: LocalizedText(
                ru: "Добавочный риск ишемической болезни сердца снижается вдвое.",
                en: "Added risk of coronary heart disease drops by half."
            ),
            long: LocalizedText(
                ru: "Через 3–6 лет после отказа добавочный риск ишемической болезни сердца снижается вдвое по сравнению с продолжением курения.",
                en: "Three to six years after quitting, your added risk of coronary heart disease is half what it would be if you kept smoking."
            ),
            sources: ["cdc"]
        ),
        HealthMilestone(
            id: "m5y", at: 5 * year, group: .years, icon: "trophy.fill",
            time: LocalizedText(ru: "5 лет", en: "5 years"),
            title: LocalizedText(ru: "Инсульт — как у некурящих", en: "Stroke risk approaches normal"),
            desc: LocalizedText(
                ru: "Риск инсульта приближается к норме. Риск рака полости рта и гортани ниже вдвое.",
                en: "Stroke risk approaches normal. Mouth and throat cancer risk is cut in half."
            ),
            long: LocalizedText(
                ru: "Риск инсульта приближается к уровню человека, который никогда не курил. Риск рака полости рта, глотки и гортани снижается примерно вдвое.",
                en: "Stroke risk approaches that of someone who never smoked. Risk of mouth, throat, and voice box cancers is cut roughly in half."
            ),
            sources: ["who", "ala", "cdc"]
        ),
        HealthMilestone(
            id: "m10y", at: 10 * year, group: .years, icon: "lungs.fill",
            time: LocalizedText(ru: "10 лет", en: "10 years"),
            title: LocalizedText(ru: "Рак лёгких — вдвое ниже", en: "Lung cancer risk halves"),
            desc: LocalizedText(
                ru: "Риск смерти от рака лёгких вдвое ниже. Снижается риск рака мочевого пузыря и почек.",
                en: "Lung cancer death risk is about half. Bladder and kidney cancer risks decrease."
            ),
            long: LocalizedText(
                ru: "Риск смерти от рака лёгких примерно вдвое ниже, чем у продолжающего курить. Также снижается риск рака мочевого пузыря, пищевода и почек.",
                en: "Your risk of dying from lung cancer is about half that of someone who keeps smoking. Risks of bladder, esophagus, and kidney cancer also decrease."
            ),
            sources: ["who", "cdc", "acs"]
        ),
        HealthMilestone(
            id: "m15y", at: 15 * year, group: .years, icon: "heart.fill",
            time: LocalizedText(ru: "15 лет", en: "15 years"),
            title: LocalizedText(ru: "Сердце как у некурящего", en: "Heart like a non-smoker"),
            desc: LocalizedText(
                ru: "Риск ишемической болезни сердца близок к уровню некурящих.",
                en: "Coronary heart disease risk is close to that of a non-smoker."
            ),
            long: LocalizedText(
                ru: "Риск ишемической болезни сердца становится близким к уровню человека, который никогда не курил.",
                en: "Your risk of coronary heart disease becomes close to that of someone who never smoked."
            ),
            sources: ["cdc", "who"]
        ),
        HealthMilestone(
            id: "m20y", at: 20 * year, group: .years, icon: "rosette",
            time: LocalizedText(ru: "20 лет", en: "20 years"),
            title: LocalizedText(ru: "Риск рака — как у некурящих", en: "Cancer risk approaches normal"),
            desc: LocalizedText(
                ru: "Риск рака полости рта, гортани и поджелудочной близок к норме.",
                en: "Mouth, throat, larynx, and pancreatic cancer risks approach normal."
            ),
            long: LocalizedText(
                ru: "Риск рака полости рта, гортани, глотки и поджелудочной железы становится близким к уровню некурящих. Риск рака шейки матки снижается примерно вдвое.",
                en: "Risk of mouth, throat, larynx, and pancreatic cancers becomes close to that of a non-smoker. Cervical cancer risk is about half."
            ),
            sources: ["cdc", "acs"]
        )
    ]

    static let byID: [String: HealthMilestone] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
}

enum AchievementType: String, Codable {
    case time
    case money
    case slip
}

struct Achievement: Identifiable, Hashable {
    let id: String
    let type: AchievementType
    let value: Double
    let icon: String
    let title: LocalizedText
    let desc: LocalizedText
}

enum Achievements {
    private static let day: TimeInterval = 86_400

    static let all: [Achievement] = [
        Achievement(id: "a20m", type: .time, value: 20 * 60, icon: "sparkles",
                    title: LocalizedText(ru: "Первый шаг", en: "First step"),
                    desc: LocalizedText(ru: "20 минут без никотина. Сердце уже чувствует разницу.", en: "20 minutes nicotine-free. Your heart already feels the difference.")),
        Achievement(id: "a8h", type: .time, value: 8 * 3_600, icon: "wind",
                    title: LocalizedText(ru: "Кислород", en: "Oxygen"),
                    desc: LocalizedText(ru: "8 часов без никотина. Кислород возвращается в кровь.", en: "8 hours nicotine-free. Oxygen is returning to your blood.")),
        Achievement(id: "a24h", type: .time, value: 24 * 3_600, icon: "sun.max.fill",
                    title: LocalizedText(ru: "Первые сутки", en: "First day"),
                    desc: LocalizedText(ru: "24 часа без никотина. Никотин покидает кровь.", en: "24 hours nicotine-free. Nicotine is leaving your blood.")),
        Achievement(id: "a48h", type: .time, value: 48 * 3_600, icon: "leaf.fill",
                    title: LocalizedText(ru: "Вкус жизни", en: "Taste of life"),
                    desc: LocalizedText(ru: "48 часов без никотина. Вкус и запах становятся ярче.", en: "48 hours nicotine-free. Taste and smell get brighter.")),
        Achievement(id: "a72h", type: .time, value: 72 * 3_600, icon: "lungs.fill",
                    title: LocalizedText(ru: "72 часа", en: "72 hours"),
                    desc: LocalizedText(ru: "Самые тяжёлые часы позади. Дышать легче.", en: "The hardest hours are behind you. Breathing is easier.")),
        Achievement(id: "a1w", type: .time, value: 7 * day, icon: "calendar",
                    title: LocalizedText(ru: "Неделя", en: "One week"),
                    desc: LocalizedText(ru: "7 дней без никотина. Привычка начинает меняться.", en: "7 days nicotine-free. The habit is starting to change.")),
        Achievement(id: "a2w", type: .time, value: 14 * day, icon: "waveform.path.ecg",
                    title: LocalizedText(ru: "Две недели", en: "Two weeks"),
                    desc: LocalizedText(ru: "14 дней без никотина. Кровообращение улучшается.", en: "14 days nicotine-free. Circulation is improving.")),
        Achievement(id: "a1m", type: .time, value: 30 * day, icon: "trophy.fill",
                    title: LocalizedText(ru: "Месяц", en: "One month"),
                    desc: LocalizedText(ru: "30 дней без никотина. Кашель и одышка отступают.", en: "30 days nicotine-free. Cough and breathlessness ease.")),
        Achievement(id: "a3m", type: .time, value: 90 * day, icon: "flame.fill",
                    title: LocalizedText(ru: "Квартал", en: "Three months"),
                    desc: LocalizedText(ru: "3 месяца без никотина. Риск инфаркта снижается.", en: "3 months nicotine-free. Heart attack risk is falling.")),
        Achievement(id: "a6m", type: .time, value: 180 * day, icon: "checkmark.shield.fill",
                    title: LocalizedText(ru: "Полгода", en: "Six months"),
                    desc: LocalizedText(ru: "6 месяцев без никотина. Лёгкие работают лучше.", en: "6 months nicotine-free. Your lungs work better.")),
        Achievement(id: "a1y", type: .time, value: 365 * day, icon: "star.fill",
                    title: LocalizedText(ru: "Год", en: "One year"),
                    desc: LocalizedText(ru: "Год без никотина. Риск болезней сердца вдвое ниже.", en: "One year nicotine-free. Heart disease risk is halved.")),
        Achievement(id: "a5y", type: .time, value: 5 * 365 * day, icon: "rosette",
                    title: LocalizedText(ru: "Пять лет", en: "Five years"),
                    desc: LocalizedText(ru: "5 лет без никотина. Риск инсульта приближается к норме.", en: "5 years nicotine-free. Stroke risk approaches normal.")),
        Achievement(id: "a10y", type: .time, value: 10 * 365 * day, icon: "heart.fill",
                    title: LocalizedText(ru: "Десять лет", en: "Ten years"),
                    desc: LocalizedText(ru: "10 лет без никотина. Риск рака лёгких вдвое ниже.", en: "10 years nicotine-free. Lung cancer risk is halved.")),
        Achievement(id: "money1k", type: .money, value: 1_000, icon: "banknote.fill",
                    title: LocalizedText(ru: "Первая тысяча", en: "First thousand"),
                    desc: LocalizedText(ru: "Сэкономлено {amount}. Они остались с тобой.", en: "{amount} saved. It stays with you.")),
        Achievement(id: "money10k", type: .money, value: 10_000, icon: "banknote.fill",
                    title: LocalizedText(ru: "Десять тысяч", en: "Ten thousand"),
                    desc: LocalizedText(ru: "{amount} остались с тобой.", en: "{amount} stays with you.")),
        Achievement(id: "money100k", type: .money, value: 100_000, icon: "banknote.fill",
                    title: LocalizedText(ru: "Сто тысяч", en: "Hundred thousand"),
                    desc: LocalizedText(ru: "{amount} сэкономлено. Это уже на что-то большое.", en: "{amount} saved. That is something big.")),
        Achievement(id: "slip", type: .slip, value: 1, icon: "arrow.clockwise",
                    title: LocalizedText(ru: "Пережил срыв", en: "Survived a slip"),
                    desc: LocalizedText(ru: "Срыв не отменяет путь. Ты вернулся — это главное.", en: "A slip does not erase the journey. You came back — that is what matters."))
    ]

    static let byID: [String: Achievement] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
}

struct MilestoneState {
    let elapsed: TimeInterval
    let unlocked: [HealthMilestone]
    let next: HealthMilestone?
    let previous: HealthMilestone?
    let progress: Double
}
