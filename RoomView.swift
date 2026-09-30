import SwiftUI

struct ShopItem: Identifiable {
    let id: String
    let cat: String
    let name: String
    let price: Int
    let img: UIImage
}

struct RoomView: View {
    @ObservedObject var store = BearStore.shared
    @State private var cat = "seat"
    @State private var showCheer = false
    @State private var cheerText = "真棒！"
    @State private var cheerWiggle = false

    let cats: [(String, String)] = [("seat", "🪑 座椅"), ("rug", "🧶 地毯"), ("deco", "摆件")]

    var allItems: [ShopItem] {
        [
            ShopItem(id: "seat-default", cat: "seat", name: "默认绿椅", price: 0, img: BearAssets.idle),
            ShopItem(id: "seat-blue", cat: "seat", name: "蓝绒沙发", price: 35, img: BearAssets.seatBlue),
            ShopItem(id: "seat-brown", cat: "seat", name: "复古皮转椅", price: 45, img: BearAssets.seatBrown),
            ShopItem(id: "rug-none", cat: "rug", name: "素净地板", price: 0, img: UIImage()),
            ShopItem(id: "rug-cookie", cat: "rug", name: "奶油饼干毯", price: 15, img: BearAssets.rugCookie),
            ShopItem(id: "rug-pink", cat: "rug", name: "蓝粉漩涡毯", price: 20, img: BearAssets.rugPink),
            ShopItem(id: "rug-leaf", cat: "rug", name: "大绿叶垫", price: 12, img: BearAssets.rugLeaf),
            ShopItem(id: "deco-none", cat: "deco", name: "留白", price: 0, img: UIImage()),
            ShopItem(id: "deco-cake", cat: "deco", name: "生日蛋糕", price: 25, img: BearAssets.decoCake),
            ShopItem(id: "deco-table", cat: "deco", name: "木桌黑灯", price: 40, img: BearAssets.decoTable),
            ShopItem(id: "deco-red", cat: "deco", name: "红柜甜甜圈灯", price: 45, img: BearAssets.decoRed),
            ShopItem(id: "deco-basket", cat: "deco", name: "猫篮落地灯", price: 45, img: BearAssets.decoBasket),
        ]
    }

    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.965, blue: 0.925).ignoresSafeArea()

            VStack(spacing: 10) {
                // 状态栏
                HStack {
                    Label("\(store.honey) 🍯", systemImage: "drop.fill")
                    Spacer()
                    if store.trash > 0 {
                        Label("乱线团 ×\(store.trash)", systemImage: "circle.fill")
                            .foregroundColor(.red.opacity(0.7))
                    } else {
                        Label("房间很干净 ✨", systemImage: "sparkles")
                            .foregroundColor(.green.opacity(0.7))
                    }
                }
                .font(.subheadline).bold()
                .foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                .padding(.horizontal).padding(.top, 8)

                // 预览舞台
                previewStage
                    .padding(.horizontal)

                // 分类标签
                HStack(spacing: 10) {
                    ForEach(cats, id: \.0) { c in
                        Button(action: { cat = c.0 }) {
                            Text(c.1)
                                .font(.callout).bold()
                                .padding(.horizontal, 14).padding(.vertical, 7)
                                .background(cat == c.0
                                            ? Color(red: 0.949, green: 0.702, blue: 0.239)
                                            : Color.white)
                                .foregroundColor(cat == c.0
                                                 ? Color(red: 0.36, green: 0.23, blue: 0.09)
                                                 : Color(red: 0.545, green: 0.369, blue: 0.235))
                                .cornerRadius(16)
                                .shadow(color: .brown.opacity(0.08), radius: 4, y: 2)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // 商品横滑
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(allItems.filter { $0.cat == cat }) { item in
                            itemCard(item)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 150)

                Text("完成专注 +10🍯 · 早晚打卡 +5🍯 · 中途放弃会留下乱线团")
                    .font(.caption2).foregroundColor(.brown.opacity(0.5))
                    .padding(.bottom, 8)
            }

            // 庆祝动画
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

    // MARK: 预览舞台
    var previewStage: some View {
        GeometryReader { g in
            let w = g.size.width
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.996, green: 0.965, blue: 0.918))
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(red: 0.922, green: 0.863, blue: 0.784), lineWidth: 2)

                if (store.equipped["rug"] ?? "none") != "none" {
                    rugView.position(x: w/2, y: 212)
                }
                if (store.equipped["deco"] ?? "none") != "none" {
                    decoView.position(x: w*0.27, y: 108)
                }
                seatView.position(x: w/2, y: 168)
                ForEach(0..<store.trash, id: \.self) { i in
                    Image(uiImage: BearAssets.trashBall)
                        .resizable().frame(width: 38, height: 38)
                        .position(x: w*(0.72 + 0.09*CGFloat(i % 3)),
                                  y: 252 + 8*CGFloat(i / 3))
                }
            }
        }
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    var rugView: some View {
        let id = store.equipped["rug"] ?? "none"
        let img: UIImage = id == "rug-cookie" ? BearAssets.rugCookie
                         : id == "rug-pink" ? BearAssets.rugPink
                         : BearAssets.rugLeaf
        return Image(uiImage: img).resizable().scaledToFit().frame(width: 250)
    }

    var decoView: some View {
        let id = store.equipped["deco"] ?? "none"
        let img: UIImage = id == "deco-cake" ? BearAssets.decoCake
                         : id == "deco-table" ? BearAssets.decoTable
                         : id == "deco-red" ? BearAssets.decoRed
                         : BearAssets.decoBasket
        let w: CGFloat = id == "deco-cake" ? 95 : 190
        return Image(uiImage: img).resizable().scaledToFit().frame(width: w)
    }

    var seatView: some View {
        let id = store.equipped["seat"] ?? "seat-default"
        let img: UIImage = id == "seat-blue" ? BearAssets.seatBlue
                         : id == "seat-brown" ? BearAssets.seatBrown
                         : BearAssets.idle
        return Image(uiImage: img).resizable().scaledToFit()
            .frame(maxWidth: 300, maxHeight: 245)
    }

    // MARK: 商品卡片
    func itemCard(_ it: ShopItem) -> some View {
        let owned = it.price == 0 || store.owned.contains(it.id)
        let isEquipped = store.equipped[it.cat] == it.id
        return VStack(spacing: 6) {
            if it.img.size.width == 0 {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.98, green: 0.96, blue: 0.93))
                    .frame(width: 84, height: 62)
                    .overlay(Text("无").font(.caption).foregroundColor(.brown.opacity(0.4)))
            } else {
                Image(uiImage: it.img).resizable().scaledToFit().frame(width: 84, height: 62)
            }
            Text(it.name).font(.caption).bold()
                .foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                .lineLimit(1)
            Button(action: {
                if owned { store.equip(it.cat, it.id) } else { buy(it) }
            }) {
                Text(isEquipped ? "已装备" : owned ? "装备" : "\(it.price) 🍯")
                    .font(.caption2).bold()
                    .frame(width: 84, height: 24)
                    .background(isEquipped ? Color.gray.opacity(0.25)
                                : owned ? Color(red: 0.61, green: 0.80, blue: 0.53)
                                : (store.honey >= it.price ? Color(red: 0.949, green: 0.702, blue: 0.239)
                                                           : Color.gray.opacity(0.4)))
                    .foregroundColor(isEquipped ? .gray
                                     : owned ? Color(red: 0.24, green: 0.42, blue: 0.18)
                                     : (store.honey >= it.price ? Color(red: 0.36, green: 0.23, blue: 0.09) : .white))
                    .cornerRadius(12)
            }
            .disabled(isEquipped)
        }
        .frame(width: 96)
        .padding(.vertical, 8)
        .background(Color.white.cornerRadius(16))
        .shadow(color: .brown.opacity(0.08), radius: 6, y: 3)
    }

    private func buy(_ it: ShopItem) {
        guard store.honey >= it.price else { return }
        store.honey -= it.price
        store.owned.append(it.id)
        store.equip(it.cat, it.id)
        cheerText = "买下了「\(it.name)」！"
        withAnimation { showCheer = true }
    }
}
