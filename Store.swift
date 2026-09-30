import Foundation
import Combine

struct MedDay: Codable {
    var morning = false
    var evening = false
    var rewarded = false   // 当天双重打卡奖励是否已领取
}

struct DayLog: Codable {
    var stretch = 0
    var focus = 0
}

final class BearStore: ObservableObject {
    static let shared = BearStore()
    private let ud = UserDefaults.standard

    @Published var intervalMin: Int   { didSet { ud.set(intervalMin, forKey: "intervalMin") } }
    @Published var honey: Int         { didSet { ud.set(honey, forKey: "honey") } }
    @Published var trash: Int         { didSet { ud.set(trash, forKey: "trash") } }
    @Published var strictMode: Bool   { didSet { ud.set(strictMode, forKey: "strict") } }
    @Published var soundOn: Bool      { didSet { ud.set(soundOn, forKey: "sound") } }
    @Published var meds: [String: MedDay] { didSet { BearStore.save(meds, key: "meds") } }
    @Published var log: [String: DayLog]  { didSet { BearStore.save(log, key: "log") } }
    @Published var owned: [String]    { didSet { ud.set(owned, forKey: "owned") } }
    @Published var equipped: [String: String] { didSet { ud.set(equipped, forKey: "equipped") } }

    private init() {
        intervalMin = ud.object(forKey: "intervalMin") as? Int ?? 35
        honey       = ud.object(forKey: "honey") as? Int ?? 0
        trash       = ud.object(forKey: "trash") as? Int ?? 0
        strictMode  = ud.object(forKey: "strict") as? Bool ?? false
        soundOn     = ud.object(forKey: "sound") as? Bool ?? true
        owned       = ud.object(forKey: "owned") as? [String] ?? []
        equipped    = ud.object(forKey: "equipped") as? [String: String]
                      ?? ["seat": "seat-default", "rug": "rug-purple", "deco": "deco-lamp"]
        meds        = BearStore.load([String: MedDay].self, key: "meds") ?? [:]
        log         = BearStore.load([String: DayLog].self, key: "log") ?? [:]
    }

    private static func save<T: Encodable>(_ v: T, key: String) {
        if let d = try? JSONEncoder().encode(v) { UserDefaults.standard.set(d, forKey: key) }
    }
    private static func load<T: Decodable>(_ t: T.Type, key: String) -> T? {
        guard let d = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(t, from: d)
    }

    static func today() -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    var todayMed: MedDay { meds[BearStore.today()] ?? MedDay() }
    var todayLog: DayLog { log[BearStore.today()] ?? DayLog() }

    var streak: Int {
        var s = 0
        var d = Date()
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        while let m = meds[f.string(from: d)], m.morning && m.evening {
            s += 1
            d = Calendar.current.date(byAdding: .day, value: -1, to: d) ?? d
        }
        return s
    }

    func equip(_ cat: String, _ id: String) {
        equipped[cat] = id
    }

    func toggleMed(_ which: String) {
        let k = BearStore.today()
        var m = meds[k] ?? MedDay()
        if which == "morning" { m.morning.toggle() } else { m.evening.toggle() }
        if m.morning && m.evening && !m.rewarded {
            honey += 5
            m.rewarded = true   // 每天只能领一次，反复打卡不再加蜂蜜
        }
        meds[k] = m
    }
}
