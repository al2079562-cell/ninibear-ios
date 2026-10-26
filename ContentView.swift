import SwiftUI

private enum NiniTab: Int, CaseIterable {
    case focus, room, notes, settings
    var label: String {
        switch self {
        case .focus: return "专注"
        case .room: return "房间"
        case .notes: return "便签"
        case .settings: return "设置"
        }
    }
    var image: UIImage {
        switch self {
        case .focus: return BearAssets.tabFocus
        case .room: return BearAssets.tabRoom
        case .notes: return UIImage(named: "tab-gray-bear") ?? UIImage()
        case .settings: return BearAssets.tabSettings
        }
    }
}

struct ContentView: View {
    @State private var selected: NiniTab = .focus
    var body: some View {
        ZStack {
            FocusView().opacity(selected == .focus ? 1 : 0).allowsHitTesting(selected == .focus)
            RoomView().opacity(selected == .room ? 1 : 0).allowsHitTesting(selected == .room)
            NotesView().opacity(selected == .notes ? 1 : 0).allowsHitTesting(selected == .notes)
            SettingsView().opacity(selected == .settings ? 1 : 0).allowsHitTesting(selected == .settings)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack(spacing: 0) {
                ForEach(NiniTab.allCases, id: \.self) { tab in
                    Button {
                        selected = tab
                    } label: {
                        Image(uiImage: tab.image)
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(width: 34, height: 34)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .contentShape(Rectangle())
                            .opacity(selected == tab ? 1 : 0.78)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(tab.label)
                    .accessibilityAddTraits(selected == tab ? [.isSelected] : [])
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 5)
            .background {
                Color.white
                    .ignoresSafeArea(edges: .bottom)
                    .overlay(alignment: .top) { Color.brown.opacity(0.12).frame(height: 0.5) }
            }
        }
    }
}
