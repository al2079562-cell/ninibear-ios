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
                .tabItem { Label("专注", systemImage: "timer") }
            RoomView()
                .tabItem { Label("房间", systemImage: "house") }
            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape") }
        }
        .accentColor(Color(red: 0.95, green: 0.70, blue: 0.24))
    }
}
