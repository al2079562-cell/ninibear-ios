import SwiftUI

struct ContentView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            FocusView()
                .tabItem {
                    Image(uiImage: BearAssets.working).renderingMode(.original)
                    Text("专注")
                }
            RoomView()
                .tabItem {
                    Image(uiImage: BearAssets.tabNormal).renderingMode(.original)
                    Text("房间")
                }
            SettingsView()
                .tabItem {
                    Image(uiImage: BearAssets.help).renderingMode(.original)
                    Text("设置")
                }
        }
        .accentColor(Color(red: 0.95, green: 0.70, blue: 0.24))
    }
}
