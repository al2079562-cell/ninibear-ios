import SwiftUI
import UserNotifications
import AudioToolbox

struct FocusView: View {
    @ObservedObject var store = BearStore.shared
    @State private var remaining: Int
    @State private var endDate: Date? = nil
    @State private var running = false
    @State private var showBreak = false
    @State private var breathe = false
    @State private var now = Date()
    @Environment(\.scenePhase) private var scenePhase

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init() {
        _remaining = State(initialValue: BearStore.shared.intervalMin * 60)
    }

    private func left(at date: Date) -> Int {
        if running, let e = endDate {
            return max(0, Int(e.timeIntervalSince(date)))
        }
        return remaining
    }

    private func fmt(_ sec: Int) -> String {
        String(format: "%02d:%02d", sec / 60, sec % 60)
    }

    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.965, blue: 0.925).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    // 标题
                    VStack(spacing: 2) {
                        Text("🐻 Ninibear 动动钟").font(.title3).bold().foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                        HStack(spacing: 6) {
                            if running {
                                Image(uiImage: BearAssets.working).resizable().frame(width: 24, height: 24)
                                    .offset(y: workingHop ? -3 : 3)
                                    .animation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true), value: workingHop)
                                    .onAppear { workingHop = true }
                            }
                            Text(running ? "专注中…到点小熊会喊你" : "每 \(store.intervalMin) 分钟起来活动一次")
                        }
                        .font(.caption).foregroundColor(.brown.opacity(0.6))
                    }
                    .padding(.top, 8)

                    // 小熊舞台（待机呼吸）
                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(RadialGradient(colors: [Color.white, Color(red: 0.984, green: 0.933, blue: 0.859)], center: .center, startRadius: 20, endRadius: 180))
                            .frame(width: 290, height: 240)
                            .shadow(color: .brown.opacity(0.12), radius: 10, y: 6)
                        Image(uiImage: BearAssets.idle)
                            .resizable().scaledToFit().frame(width: 250, height: 210)
                            .scaleEffect(breathe ? 1.03 : 1.0)
                            .offset(y: breathe ? -4 : 0)
                            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: breathe)
                            .onAppear { breathe = true }
                    }

                    // 计时器
                    Text(fmt(left(at: now)))
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                        .monospacedDigit()

                    // 按钮
                    HStack(spacing: 14) {
                        Button(action: toggle) {
                            Text(running ? "暂停" : (remaining < store.intervalMin * 60 ? "继续" : "开始"))
                                .font(.headline).frame(width: 120, height: 50)
                                .background(Color(red: 0.949, green: 0.702, blue: 0.239))
                                .foregroundColor(Color(red: 0.36, green: 0.23, blue: 0.09))
                                .cornerRadius(25)
                        }
                        Button(action: reset) {
                            Text("重置").font(.headline).frame(width: 120, height: 50)
                                .background(Color(red: 0.953, green: 0.894, blue: 0.824))
                                .foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                                .cornerRadius(25)
                        }
                    }
                    .padding(.bottom, 4)

                    // 吃药打卡
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("💊 今天吃药了吗").font(.headline).foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                            Spacer()
                            Text(BearStore.today()).font(.caption2).foregroundColor(.brown.opacity(0.5))
                        }
                        HStack(spacing: 12) {
                            medButton(which: "morning", icon: "🌅", name: "早上", done: store.todayMed.morning)
                            medButton(which: "evening", icon: "🌙", name: "晚上", done: store.todayMed.evening)
                        }
                    }
                    .padding(16)
                    .background(Color.white.cornerRadius(18))
                    .shadow(color: .brown.opacity(0.1), radius: 8, y: 4)

                    // 今日小结
                    HStack(spacing: 10) {
                        statCard(num: "\(store.todayLog.stretch)", label: "起来活动")
                        statCard(num: "\(store.streak)", label: "连续全勤")
                        statCard(num: "\(store.todayLog.focus)", label: "专注次数")
                        statCard(num: "\(store.honey)🍯", label: "我的蜂蜜")
                    }

                    Text("💡 基于真实时间计时：切去别的 app、锁屏，时间照走，到点系统通知必响。")
                        .font(.caption2).foregroundColor(.brown.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal)
            }

            // 到点弹层
            if showBreak {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack(spacing: 10) {
                    Image(uiImage: BearAssets.cup).resizable().scaledToFit().frame(width: 150)
                        .rotationEffect(.degrees(wiggle ? -4 : 4))
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: wiggle)
                        .onAppear { wiggle = true }
                    Text("🐻 起来动动啦！").font(.title2).bold().foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                    Text("小熊伸了个懒腰：喝口水、活动一下肩颈和腰，2 分钟后再回来～")
                        .font(.subheadline).foregroundColor(.brown.opacity(0.6))
                        .multilineTextAlignment(.center)
                    Button(action: { showBreak = false }) {
                        Text("我起来啦 ✔").font(.headline).frame(maxWidth: .infinity).frame(height: 50)
                            .background(Color(red: 0.949, green: 0.702, blue: 0.239))
                            .foregroundColor(Color(red: 0.36, green: 0.23, blue: 0.09))
                            .cornerRadius(25)
                    }
                    .padding(.top, 6)
                }
                .padding(24)
                .background(Color(red: 1.0, green: 0.965, blue: 0.925).cornerRadius(24))
                .shadow(radius: 20)
                .padding(30)
            }
        }
        .onReceive(timer) { t in
            now = t
            if running, let e = endDate, t >= e { complete() }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                now = Date()
                if running, let e = endDate, now >= e { complete() }
            }
        }
    }

    @State private var wiggle = false
    @State private var workingHop = false

    private func medButton(which: String, icon: String, name: String, done: Bool) -> some View {
        Button(action: { store.toggleMed(which) }) {
            VStack(spacing: 4) {
                Text(icon).font(.system(size: 26))
                Text(name).font(.subheadline).bold().foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                HStack(spacing: 4) {
                    Image(uiImage: done ? BearAssets.link : BearAssets.help).resizable().frame(width: 18, height: 18)
                    Text(done ? "已吃 ✔ 真棒！" : "点我打卡")
                }
                .font(.caption2)
                    .foregroundColor(done ? Color(red: 0.37, green: 0.60, blue: 0.28) : .brown.opacity(0.5))
            }
            .frame(maxWidth: .infinity).padding(.vertical, 12)
            .background(done ? Color(red: 0.945, green: 0.973, blue: 0.925) : Color(red: 1.0, green: 0.984, blue: 0.96))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(done ? Color(red: 0.61, green: 0.80, blue: 0.53) : Color(red: 0.922, green: 0.863, blue: 0.784), lineWidth: 2))
            .cornerRadius(14)
        }
    }

    private func statCard(num: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(num).font(.title3).bold().foregroundColor(Color(red: 0.949, green: 0.702, blue: 0.239))
            Text(label).font(.caption2).foregroundColor(.brown.opacity(0.5))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 10)
        .background(Color(red: 1.0, green: 0.984, blue: 0.96).cornerRadius(12))
    }

    // MARK: 计时控制
    private func toggle() {
        if running {
            remaining = left(at: Date())
            running = false
            endDate = nil
            cancelNotif()
        } else {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
            running = true
            endDate = Date().addingTimeInterval(TimeInterval(remaining))
            scheduleNotif(seconds: remaining)
        }
    }

    private func reset() {
        if running {                       // 中途放弃 = 惩罚
            store.trash += 1
            if store.strictMode { store.honey = max(0, store.honey - 5) }
        }
        running = false
        endDate = nil
        remaining = store.intervalMin * 60
        cancelNotif()
    }

    private func complete() {
        running = false
        endDate = nil
        let k = BearStore.today()
        var l = store.log[k] ?? DayLog()
        l.stretch += 1; l.focus += 1
        store.log[k] = l
        store.honey += 10                 // 完成专注 +10 蜂蜜
        if store.trash > 0 { store.trash -= 1 }   // 清理一个垃圾
        cancelNotif()
        if store.soundOn { AudioServicesPlaySystemSound(1007) }
        showBreak = true
        remaining = store.intervalMin * 60
    }

    private func scheduleNotif(seconds: Int) {
        let c = UNMutableNotificationContent()
        c.title = "🐻 Ninibear 喊你起来动动！"
        c.body = "喝口水，活动一下肩颈和腰～"
        c.sound = .default
        let r = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "nb_break", content: c, trigger: r))
    }

    private func cancelNotif() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["nb_break"])
    }
}
