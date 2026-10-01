import SwiftUI

// MARK: - 共享小熊场景（主页 & 房间页共用）
struct BearRoomScene: View {
    @ObservedObject var store = BearStore.shared
    var height: CGFloat = 300

    var body: some View {
        GeometryReader { g -> AnyView in
            let w = g.size.width
            return AnyView(ZStack {
                Rectangle()
                    .fill(Color(red: 0.96, green: 0.90, blue: 0.81))
                    .frame(height: height*0.30)
                    .position(x: w/2, y: height - height*0.15)

                // 墙贴（最底层背景上）
                if (store.equipped["wall"] ?? "none") != "none" {
                    wallView.position(x: w*0.30, y: height*0.20)
                }
                if (store.equipped["rug"] ?? "none") != "none" {
                    rugView.position(x: w/2, y: height*0.80)
                }
                if (store.equipped["table"] ?? "none") != "none" {
                    let tid = store.equipped["table"] ?? ""
                    let ty: CGFloat = tid == "balloonL" ? height*0.54
                                    : tid == "spoonCat" ? height*0.78
                                    : height*0.70
                    tableView.position(x: w*0.20, y: ty)
                }
                if (store.equipped["lamp"] ?? "none") != "none" {
                    let lid = store.equipped["lamp"] ?? ""
                    let ly: CGFloat = lid == "sundaeGlass" ? height*0.72
                                    : lid == "donutLamp2" ? height*0.48
                                    : lid == "balloonR" ? height*0.44
                                    : height*0.40
                    lampView.position(x: w*0.75, y: ly)
                }
                let seatH = seatHeight(store.equipped["seat"] ?? "seat-default")
                seatView.position(x: w/2, y: height*0.94 - seatH/2)
                ForEach(0..<store.trash, id: \.self) { i in
                    Image(uiImage: BearAssets.trashBall)
                        .resizable().frame(width: 32, height: 32)
                        .position(x: w*(0.84 + 0.05*CGFloat(i % 3)),
                                  y: height*0.88 + 6*CGFloat(i / 3))
                }
            })
        }
        .frame(height: height)
    }

    var wallView: some View {
        let id = store.equipped["wall"] ?? "none"
        let img: UIImage = id == "stickerTea" ? BearAssets.stickerTea
                         : id == "stickerCone" ? BearAssets.stickerCone
                         : BearAssets.stickerNote
        let wmap: [String: CGFloat] = ["stickerTea": 72, "stickerCone": 62, "stickerNote": 70]
        return Image(uiImage: img).resizable().scaledToFit()
            .frame(width: wmap[id] ?? 70)
            .opacity(0.9)
    }

    var rugView: some View {
        let id = store.equipped["rug"] ?? "none"
        let img: UIImage = id == "rug-cookie" ? BearAssets.rugCookie
                         : id == "rug-pink" ? BearAssets.rugPink
                         : id == "rug-leaf" ? BearAssets.rugLeaf
                         : id == "rugFloral" ? BearAssets.rugFloral
                         : BearAssets.rugPurple
        return Image(uiImage: img).resizable().scaledToFit().frame(width: 330)
    }

    var tableView: some View {
        let id = store.equipped["table"] ?? "decoTable2"
        let img: UIImage = id == "plantTable" ? BearAssets.plantTable
                         : id == "roundTable" ? BearAssets.roundTable
                         : id == "balloonL" ? BearAssets.balloonL
                         : id == "spoonCat" ? BearAssets.spoonCat
                         : id == "redCab2" ? BearAssets.redCab2
                         : id == "stonePot" ? BearAssets.stonePot
                         : id == "pumpkin" ? BearAssets.pumpkin
                         : BearAssets.decoTable2
        // 气球用高度控制（高款），其余用宽度（小一点）
        if id == "balloonL" {
            return AnyView(Image(uiImage: img).resizable().scaledToFit()
                .frame(height: 185))
        }
        let wmap: [String: CGFloat] = ["plantTable": 115, "roundTable": 105,
                                       "spoonCat": 42, "redCab2": 115,
                                       "stonePot": 110, "pumpkin": 95]
        return AnyView(Image(uiImage: img).resizable().scaledToFit()
            .frame(width: wmap[id] ?? 110))
    }

    var lampView: some View {
        let id = store.equipped["lamp"] ?? "deco-lamp"
        let img: UIImage = id == "twinLamp" ? BearAssets.twinLamp
                         : id == "greenLamp" ? BearAssets.greenLamp
                         : id == "balloonR" ? BearAssets.balloonR
                         : id == "donutLamp2" ? BearAssets.donutLamp2
                         : id == "sundaeGlass" ? BearAssets.sundaeGlass
                         : id == "streetLamp" ? BearAssets.streetLamp
                         : id == "curveLamp" ? BearAssets.curveLamp
                         : BearAssets.lampDefault
        // 灯具一律按高度给足（灯要大、完整）
        let hmap: [String: CGFloat] = ["twinLamp": 205, "greenLamp": 200,
                                       "balloonR": 190, "donutLamp2": 150,
                                       "sundaeGlass": 90, "streetLamp": 210,
                                       "curveLamp": 205]
        return Image(uiImage: img).resizable().scaledToFit()
            .frame(height: hmap[id] ?? 200)
    }

    // 每把椅子的绝对显示高度（pt）：房间和主页完全一致
    // 已按画布留白校准视觉大小：绿椅175 / 沙发250 / 转椅235 / 摇椅245 / 蛋糕165
    func seatHeight(_ id: String) -> CGFloat {
        switch id {
        case "seat-blue": return 196
        case "seatBerry": return 201
        case "seat-brown": return 207
        case "seatRock": return 197
        case "seatCake": return 235
        default: return 181
        }
    }

    var seatView: some View {
        let id = store.equipped["seat"] ?? "seat-default"
        let img: UIImage = id == "seat-blue" ? BearAssets.seatBlue
                         : id == "seat-brown" ? BearAssets.seatBrown
                         : id == "seatRock" ? BearAssets.seatRock
                         : id == "seatBerry" ? BearAssets.seatBerry
                         : id == "seatCake" ? BearAssets.seatCake
                         : BearAssets.seatDefault
        return Image(uiImage: img).resizable().scaledToFit()
            .frame(maxWidth: 270, maxHeight: seatHeight(id))
    }
}

// MARK: - 商品
struct ShopItem: Identifiable {
    let id: String
    let cat: String
    let name: String
    let price: Int
    let img: UIImage
    let card: UIImage
}

struct RoomView: View {
    @ObservedObject var store = BearStore.shared
    @State private var cat = "seat"
    @State private var showCheer = false
    @State private var cheerText = "真棒！"
    @State private var cheerWiggle = false

    let cats: [(String, String)] = [("seat", "🪑"), ("rug", "🧶"), ("table", "🍵"),
                                    ("lamp", "💡"), ("wall", "🖼")]

    var allItems: [ShopItem] {
        [
            ShopItem(id: "seat-default", cat: "seat", name: "经典绿椅", price: 0, img: BearAssets.seatDefault, card: BearAssets.seatDefaultClean),
            ShopItem(id: "seat-blue", cat: "seat", name: "蓝绒沙发", price: 35, img: BearAssets.seatBlue, card: BearAssets.seatBlueClean),
            ShopItem(id: "seat-brown", cat: "seat", name: "复古皮转椅", price: 45, img: BearAssets.seatBrown, card: BearAssets.seatBrownClean),
            ShopItem(id: "seatRock", cat: "seat", name: "奶奶的摇椅", price: 40, img: BearAssets.seatRock, card: BearAssets.seatRockClean),
            ShopItem(id: "seatBerry", cat: "seat", name: "草莓味沙发", price: 35, img: BearAssets.seatBerry, card: BearAssets.seatBerryClean),
            ShopItem(id: "seatCake", cat: "seat", name: "生日蛋糕座", price: 50, img: BearAssets.seatCake, card: BearAssets.seatCakeClean),
            ShopItem(id: "rug-purple", cat: "rug", name: "紫色圆毯", price: 0, img: BearAssets.rugPurple, card: BearAssets.rugPurple),
            ShopItem(id: "rug-none", cat: "rug", name: "素净地板", price: 0, img: UIImage(), card: UIImage()),
            ShopItem(id: "rug-cookie", cat: "rug", name: "奶油饼干毯", price: 15, img: BearAssets.rugCookie, card: BearAssets.rugCookie),
            ShopItem(id: "rug-pink", cat: "rug", name: "蓝粉漩涡毯", price: 20, img: BearAssets.rugPink, card: BearAssets.rugPink),
            ShopItem(id: "rug-leaf", cat: "rug", name: "大绿叶垫", price: 12, img: BearAssets.rugLeaf, card: BearAssets.rugLeaf),
            ShopItem(id: "rugFloral", cat: "rug", name: "外婆家的地毯", price: 20, img: BearAssets.rugFloral, card: BearAssets.rugFloral),
            ShopItem(id: "decoTable2", cat: "table", name: "橙橙小边桌", price: 0, img: BearAssets.decoTable2, card: BearAssets.decoTable2),
            ShopItem(id: "plantTable", cat: "table", name: "边几盆栽", price: 20, img: BearAssets.plantTable, card: BearAssets.plantTable),
            ShopItem(id: "roundTable", cat: "table", name: "小圆边几", price: 20, img: BearAssets.roundTable, card: BearAssets.roundTable),
            ShopItem(id: "balloonL", cat: "table", name: "缤纷气球组", price: 25, img: BearAssets.balloonL, card: BearAssets.balloonL),
            ShopItem(id: "spoonCat", cat: "table", name: "猫耳木勺", price: 10, img: BearAssets.spoonCat, card: BearAssets.spoonCat),
            ShopItem(id: "redCab2", cat: "table", name: "复古红柜", price: 25, img: BearAssets.redCab2, card: BearAssets.redCab2),
            ShopItem(id: "stonePot", cat: "table", name: "石质花钵", price: 25, img: BearAssets.stonePot, card: BearAssets.stonePot),
            ShopItem(id: "pumpkin", cat: "table", name: "拼布南瓜", price: 15, img: BearAssets.pumpkin, card: BearAssets.pumpkin),
            ShopItem(id: "table-none", cat: "table", name: "留白", price: 0, img: UIImage(), card: UIImage()),
            ShopItem(id: "deco-lamp", cat: "lamp", name: "暖黄落地灯", price: 0, img: BearAssets.lampDefault, card: BearAssets.lampDefault),
            ShopItem(id: "twinLamp", cat: "lamp", name: "双头落地灯", price: 20, img: BearAssets.twinLamp, card: BearAssets.twinLamp),
            ShopItem(id: "greenLamp", cat: "lamp", name: "绿罩落地灯", price: 20, img: BearAssets.greenLamp, card: BearAssets.greenLamp),
            ShopItem(id: "balloonR", cat: "lamp", name: "星星气球组", price: 25, img: BearAssets.balloonR, card: BearAssets.balloonR),
            ShopItem(id: "donutLamp2", cat: "lamp", name: "甜甜圈气球灯", price: 25, img: BearAssets.donutLamp2, card: BearAssets.donutLamp2),
            ShopItem(id: "sundaeGlass", cat: "lamp", name: "冰品玻璃杯", price: 15, img: BearAssets.sundaeGlass, card: BearAssets.sundaeGlass),
            ShopItem(id: "streetLamp", cat: "lamp", name: "复古双头路灯", price: 30, img: BearAssets.streetLamp, card: BearAssets.streetLamp),
            ShopItem(id: "curveLamp", cat: "lamp", name: "弯杆落地灯", price: 25, img: BearAssets.curveLamp, card: BearAssets.curveLamp),
            ShopItem(id: "lamp-none", cat: "lamp", name: "留白", price: 0, img: UIImage(), card: UIImage()),
            ShopItem(id: "wall-none", cat: "wall", name: "留白", price: 0, img: UIImage(), card: UIImage()),
            ShopItem(id: "stickerTea", cat: "wall", name: "茶杯贴纸", price: 10, img: BearAssets.stickerTea, card: BearAssets.stickerTea),
            ShopItem(id: "stickerCone", cat: "wall", name: "甜筒贴纸", price: 10, img: BearAssets.stickerCone, card: BearAssets.stickerCone),
            ShopItem(id: "stickerNote", cat: "wall", name: "便签贴纸", price: 8, img: BearAssets.stickerNote, card: BearAssets.stickerNote),
        ]
    }

    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.965, blue: 0.925).ignoresSafeArea()

            VStack(spacing: 10) {
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

                BearRoomScene(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(red: 0.922, green: 0.863, blue: 0.784), lineWidth: 2))
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(cats, id: \.0) { c in
                            Button(action: { cat = c.0 }) {
                                Text(c.1)
                                    .font(.title3)
                                    .frame(width: 52, height: 40)
                                    .background(cat == c.0
                                                ? Color(red: 0.949, green: 0.702, blue: 0.239)
                                                : Color.white)
                                    .cornerRadius(14)
                                    .shadow(color: .brown.opacity(0.08), radius: 4, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 44)

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

            if showCheer {
                VStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(uiImage: BearAssets.cheerHeart).resizable().scaledToFit().frame(width: 110)
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

    func itemCard(_ it: ShopItem) -> some View {
        let owned = it.price == 0 || store.owned.contains(it.id)
        let isEquipped = store.equipped[it.cat] == it.id
        return Button(action: {
            if isEquipped { return }
            if owned { store.equip(it.cat, it.id) } else { buy(it) }
        }) {
            VStack(spacing: 6) {
                if it.card.size.width == 0 {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.98, green: 0.96, blue: 0.93))
                        .frame(width: 84, height: 62)
                        .overlay(Text("无").font(.caption).foregroundColor(.brown.opacity(0.4)))
                } else {
                    Image(uiImage: it.card).resizable().scaledToFit().frame(width: 84, height: 62)
                }
                Text(it.name).font(.caption).bold()
                    .foregroundColor(Color(red: 0.545, green: 0.369, blue: 0.235))
                    .lineLimit(1)
                Text(isEquipped ? "✓ 已装备" : owned ? "点我装备" : "\(it.price) 🍯 购买")
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
            .frame(width: 96)
            .padding(.vertical, 8)
            .background(Color.white.cornerRadius(16))
            .shadow(color: .brown.opacity(0.08), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
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
