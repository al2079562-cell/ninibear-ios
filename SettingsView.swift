import SwiftUI

struct SettingsView: View {
    @ObservedObject var store = BearStore.shared

    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.965, blue: 0.925).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    Text("⚙️ 设置").font(.title3).bold()
                        .foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("⏰ 活动间隔：每 \(store.intervalMin) 分钟").font(.headline)
                            .foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                        Slider(value: Binding(
                            get: { Double(store.intervalMin) },
                            set: { store.intervalMin = Int($0 / 5) * 5 }
                        ), in: 25...45, step: 5)
                        .accentColor(Color(red: 0.949, green: 0.702, blue: 0.239))
                    }
                    .padding(16)
                    .background(Color.white.cornerRadius(18))
                    .shadow(color: .brown.opacity(0.1), radius: 8, y: 4)

                    VStack(spacing: 4) {
                        Toggle("🔔 到点提示音", isOn: $store.soundOn)
                        Divider()
                        Toggle("😾 严格模式（中途放弃 -5🍯）", isOn: $store.strictMode)
                    }
                    .padding(16)
                    .background(Color.white.cornerRadius(18))
                    .shadow(color: .brown.opacity(0.1), radius: 8, y: 4)
                    .foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))

                    VStack(alignment: .leading, spacing: 6) {
                        Text("📖 玩法说明").font(.headline)
                            .foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                        Text("· 完成一次专注：+10 蜂蜜，清理一个垃圾\n· 早晚两次打卡：+5 蜂蜜\n· 中途重置专注：房间出现一个垃圾 🗑️\n· 蜂蜜可在「房间」页买家具，布置小熊的家")
                            .font(.caption).foregroundColor(.brown.opacity(0.6))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.cornerRadius(18))
                    .shadow(color: .brown.opacity(0.1), radius: 8, y: 4)

                    Text("Ninibear 动动钟 v0.1 · 个人学习作品 🐻")
                        .font(.caption2).foregroundColor(.brown.opacity(0.4))
                        .padding(.bottom, 8)
                }
                .padding(.horizontal)
            }
        }
    }
}
