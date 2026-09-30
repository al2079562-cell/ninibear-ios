import SwiftUI

struct RoomItem: Identifiable {
    let id: String
    let emoji: String
    let name: String
    let price: Int
    let x: CGFloat      // 房间里的位置（0~1）
    let y: CGFloat
}

struct RoomView: View {
    @ObservedObject var store = BearStore.shared
    @State private var breathe = false
    @State private var showCheer = false
    @State private var cheerText = "真棒！"

    let items: [RoomItem] = [
        RoomItem(id: "candle", emoji: "🕯️", name: "香薰蜡烛", price: 10, x: 0.82, y: 0.62),
        RoomItem(id: "plant",  emoji: "🪴", name: "小盆栽",   price: 15, x: 0.15, y: 0.60),
        RoomItem(id: "lamp",   emoji: "💡", name: "落地灯",   price: 20, x: 0.85, y: 0.30),
        RoomItem(id: "rug",    emoji: "🧶", name: "毛线地毯", price: 25, x: 0.50, y: 0.86),
        RoomItem(id: "bed",    emoji: "🛏️", name: "软软小床", price: 30, x: 0.22, y: 0.82),
        RoomItem(id: "sofa",   emoji: "🛋️", name: "小沙发",   price: 40, x: 0.78, y: 0.82),
    ]

    let cheers = ["真棒！", "小熊为你鼓掌 👏", "坚持住，最棒了！", "夸夸你！🍯", "好乖好乖～"]

    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.965, blue: 0.925).ignoresSafeArea()

            VStack(spacing: 0) {
                // 房间场景
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient(colors: [Color(red: 0.984, green: 0.933, blue: 0.859),
                                                      Color(red: 0.953, green: 0.894, blue: 0.824)],
                                             startPoint: .top, endPoint: .bottom))
                        .frame(height: 300)
                        .shadow(color: .brown.opacity(0.12), radius: 10, y: 6)

                    // 已拥有的家具
                    ForEach(items) { item in
                        if store.owned.contains(item.id) {
                            Text(item.emoji).font(.system(size: 44))
                                .position(x: item.x * UIScreen.main.bounds.width,
                                          y: 150 + (item.y - 0.5) * 260)
                        }
                    }
                    // 垃圾（惩罚）
                    ForEach(0..<store.trash, id: \.self) { i in
                        Text("🗑️").font(.system(size: 30))
                            .position(x: UIScreen.main.bounds.width * (0.35 + 0.15 * CGFloat(i % 3)),
                                      y: 200 + 20 * CGFloat(i / 3))
                    }
                    // 小熊
                    Image(uiImage: BearAssets.idle)
                        .resizable().scaledToFit().frame(width: 120, height: 120)
                        .position(x: UIScreen.main.bounds.width * 0.5, y: 210)
                        .scaleEffect(breathe ? 1.04 : 1.0)
                        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: breathe)
                        .onAppear { breathe = true }
                }
                .padding(.horizontal)

                // 状态栏
                HStack {
                    Label("\(store.honey) 🍯", systemImage: "drop.fill")
                    Spacer()
                    if store.trash > 0 {
                        Label("垃圾 ×\(store.trash)", systemImage: "trash.fill").foregroundColor(.red.opacity(0.7))
                    } else {
                        Label("房间很干净 ✨", systemImage: "sparkles").foregroundColor(.green.opacity(0.7))
                    }
                }
                .font(.subheadline).bold()
                .foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                .padding(.horizontal).padding(.vertical, 10)

                // 商店
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(items) { item in
                            let ownedIt = store.owned.contains(item.id)
                            VStack(spacing: 6) {
                                Text(item.emoji).font(.system(size: 34))
                                Text(item.name).font(.caption).bold().foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                                Button(action: { buy(item) }) {
                                    Text(ownedIt ? "已拥有" : "\(item.price) 🍯")
                                        .font(.caption2).bold()
                                        .frame(maxWidth: .infinity).frame(height: 26)
                                        .background(ownedIt ? Color.gray.opacity(0.25)
                                                    : (store.honey >= item.price ? Color(red: 0.949, green: 0.702, blue: 0.239) : Color.gray.opacity(0.4)))
                                        .foregroundColor(ownedIt ? .gray : (store.honey >= item.price ? Color(red: 0.36, green: 0.23, blue: 0.09) : .white))
                                        .cornerRadius(13)
                                }
                                .disabled(ownedIt || store.honey < item.price)
                            }
                            .padding(10)
                            .background(Color.white.cornerRadius(16))
                            .shadow(color: .brown.opacity(0.08), radius: 6, y: 3)
                        }
                    }
                    .padding(.horizontal)
                    Text("完成专注 +10🍯，早晚打卡 +5🍯；中途放弃会出现垃圾 🗑️")
                        .font(.caption2).foregroundColor(.brown.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }

            // 挥手熊庆祝
            if showCheer {
                VStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(uiImage: BearAssets.wave).resizable().scaledToFit().frame(width: 100)
                            .rotationEffect(.degrees(cheerWiggle ? -8 : 8))
                            .animation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true), value: cheerWiggle)
                        Text(cheerText).font(.callout).bold()
                            .padding(.horizontal, 14).padding(.vertical, 5)
                            .background(Color.white.cornerRadius(14))
                            .shadow(radius: 6)
                            .foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                    }
                    .padding(.bottom, 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        cheerWiggle = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                            withAnimation { showCheer = false }
                        }
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCheer)
            }
        }
    }

    @State private var cheerWiggle = false

    private func buy(_ item: RoomItem) {
        guard store.honey >= item.price else { return }
        store.honey -= item.price
        store.owned.append(item.id)
        cheerText = "买下了 \(item.name)！"
        withAnimation { showCheer = true }
    }
}
