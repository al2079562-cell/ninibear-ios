import SwiftUI
import UIKit

// v0.2.2: transparent original decoration, full lavender page and ruled editable area.
struct NotesView: View {
    @ObservedObject private var notes = NotesStore.shared
    @State private var mode: NoteMode = .free
    @State private var showFullEditor = false
    @FocusState private var focusedTodo: UUID?

    private let ink = Color(red: 0.37, green: 0.27, blue: 0.30)
    private let lavender = Color(red: 0.929, green: 0.870, blue: 0.933)
    private let paper = Color(red: 1.0, green: 0.917, blue: 0.889)
    private let rule = Color(red: 0.69, green: 0.54, blue: 0.56)

    private enum NoteMode: String, CaseIterable {
        case free = "自由记录"
        case todo = "待办清单"
    }

    var body: some View {
        ZStack {
            lavender.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 10) {
                    Text("🧸 小熊便签")
                        .font(.system(size: 23, weight: .bold, design: .rounded))
                        .foregroundStyle(ink)
                        .padding(.top, 9)

                    HStack(spacing: 12) {
                        ForEach(NoteMode.allCases, id: \.self) { item in
                            Button {
                                focusedTodo = nil
                                mode = item
                            } label: {
                                Text(item.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(ink)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 9)
                                    .background(mode == item ? Color(red: 0.97, green: 0.74, blue: 0.80) : Color.white.opacity(0.78))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    GeometryReader { geo in
                        let w = geo.size.width
                        let h = geo.size.height
                        // The paper follows the cloud silhouette, NEVER a rectangular card.
                        // Keep it under the transparent original decoration.
                        MemoCloudPaper()
                            .fill(paper)
                            .frame(width: w, height: h)
                            .allowsHitTesting(false)

                        // Prefer the directly bundled PNG. This avoids relying solely
                        // on asset-catalog compilation (which failed on the test IPA).
                        if let decoration = MemoDecorationLoader.image {
                            Image(uiImage: decoration)
                                .resizable()
                                .interpolation(.high)
                                .frame(width: w, height: h)
                                .allowsHitTesting(false)
                                .accessibilityHidden(true)
                        } else {
                            Text("便签插画资源未加载，请检查 memo-decoration.png 是否上传到项目根目录")
                                .font(.system(size: 11))
                                .foregroundStyle(.red)
                                .frame(width: w * 0.8, height: 50)
                                .position(x: w * 0.5, y: h * 0.13)
                        }

                        // The left writing area deliberately avoids the illustrated boy.
                        // Lines are drawn beneath the editor, not embedded in the image.
                        ZStack(alignment: .topLeading) {
                            if mode == .free {
                                VStack(spacing: 4) {
                                    // Read-only cloud preview: one text layout owns BOTH
                                    // wrapping and ruled lines, including while scrolling.
                                    LinedNoteTextView(text: $notes.freeText, editable: false)
                                        .accessibilityLabel("自由便签预览")
                                    Button {
                                        showFullEditor = true
                                    } label: {
                                        Label("展开编辑", systemImage: "arrow.up.left.and.arrow.down.right")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(ink)
                                    }
                                    .buttonStyle(.plain)
                                }
                            } else {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach($notes.todos) { $todo in
                                            HStack(alignment: .top, spacing: 5) {
                                                Button { todo.done.toggle() } label: {
                                                    Image(systemName: todo.done ? "checkmark.square.fill" : "square")
                                                        .font(.system(size: 16))
                                                        .foregroundStyle(ink)
                                                }
                                                .buttonStyle(.plain)
                                                TextField("写下一件小事…", text: $todo.text, axis: .vertical)
                                                    .lineLimit(1...4)
                                                    .font(.system(size: 14))
                                                    .foregroundStyle(ink)
                                                    .strikethrough(todo.done)
                                                    .focused($focusedTodo, equals: todo.id)
                                                Button { notes.deleteTodo(todo.id) } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 12))
                                                        .foregroundStyle(ink.opacity(0.55))
                                                }
                                                .buttonStyle(.plain)
                                            }
                                            .padding(.vertical, 5)
                                        }
                                        Button {
                                            notes.addTodo()
                                            if let last = notes.todos.last { focusedTodo = last.id }
                                        } label: {
                                            Label("添加一项", systemImage: "plus.circle")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(ink)
                                        }
                                    }
                                    .padding(.horizontal, 3)
                                }
                                .scrollIndicators(.hidden)
                            }
                        }
                        .frame(width: w * 0.45, height: h * 0.47)
                        .position(x: w * 0.365, y: h * 0.505)
                    }
                    .aspectRatio(2048.0 / 2016.0, contentMode: .fit)
                    .padding(.horizontal, 2)
                    .padding(.top, 78) // shift square illustration toward screen center, no stretching

                    Text("每一件小事，都值得被好好记住 ♡")
                        .font(.system(size: 12))
                        .foregroundStyle(ink.opacity(0.65))
                        .padding(.bottom, 14)
                }
                .frame(maxWidth: 540)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .sheet(isPresented: $showFullEditor) {
                NavigationStack {
                    LinedNoteTextView(text: $notes.freeText, editable: true)
                        .padding(.horizontal, 18)
                        .padding(.top, 12)
                        .background(Color(red: 1, green: 0.96, blue: 0.96))
                        .navigationTitle("我的自由记录")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("完成") { showFullEditor = false }
                            }
                        }
                }
            }
        }
    }
}

// UITextView controls wrapping and scrolling; its background line layer is
// positioned from the SAME font metrics and content offset. No independent
// SwiftUI line stack to drift across Chinese wrapped lines.
private struct LinedNoteTextView: UIViewRepresentable {
    @Binding var text: String
    let editable: Bool

    func makeUIView(context: Context) -> RuledUITextView {
        let view = RuledUITextView()
        view.delegate = context.coordinator
        view.isEditable = editable
        view.isSelectable = editable
        view.backgroundColor = .clear
        view.textColor = UIColor(red: 0.37, green: 0.27, blue: 0.30, alpha: 1)
        view.font = UIFont.systemFont(ofSize: editable ? 17 : 15)
        view.textContainerInset = UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0)
        view.textContainer.lineFragmentPadding = 0
        view.showsVerticalScrollIndicator = editable
        view.alwaysBounceVertical = true
        view.keyboardDismissMode = .interactive
        view.apply(text: text)
        return view
    }

    func updateUIView(_ view: RuledUITextView, context: Context) {
        if view.isEditable != editable { view.isEditable = editable }
        if view.text != text { view.apply(text: text) }
        view.refreshLines()
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }
    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: LinedNoteTextView
        init(_ parent: LinedNoteTextView) { self.parent = parent }
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            (textView as? RuledUITextView)?.refreshLines()
        }
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            (scrollView as? RuledUITextView)?.refreshLines()
        }
    }
}

private final class RuledUITextView: UITextView {
    private let lines = CAShapeLayer()
    private let lineGap: CGFloat = 11

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        lines.strokeColor = UIColor(red: 0.73, green: 0.59, blue: 0.60, alpha: 0.65).cgColor
        lines.fillColor = nil
        lines.lineWidth = 0.7
        layer.insertSublayer(lines, at: 0)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func apply(text: String) {
        let font = self.font ?? UIFont.systemFont(ofSize: 15)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineGap
        attributedText = NSAttributedString(string: text, attributes: [
            .font: font, .foregroundColor: textColor ?? UIColor.darkGray,
            .paragraphStyle: style
        ])
        refreshLines()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        refreshLines()
    }

    func refreshLines() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        let font = self.font ?? UIFont.systemFont(ofSize: 15)
        let step = font.lineHeight + lineGap
        let top = textContainerInset.top + font.lineHeight + 5 - contentOffset.y
        let path = UIBezierPath()
        var y = top.truncatingRemainder(dividingBy: step)
        if y < 0 { y += step }
        while y < bounds.height {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: bounds.width, y: y))
            y += step
        }
        lines.frame = bounds
        lines.path = path.cgPath
    }
}

// Approximate inner boundary of the original scalloped cloud illustration.
// Coordinates are relative to the illustration, so this scales with iPhone width.
private struct MemoCloudPaper: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: rect.minX + x*w, y: rect.minY + y*h) }
        var path = Path()
        path.move(to: p(0.14, 0.10))
        path.addQuadCurve(to: p(0.29, 0.06), control: p(0.18, 0.01))
        path.addQuadCurve(to: p(0.44, 0.07), control: p(0.35, 0.015))
        path.addQuadCurve(to: p(0.60, 0.07), control: p(0.52, 0.015))
        path.addQuadCurve(to: p(0.76, 0.08), control: p(0.68, 0.015))
        path.addQuadCurve(to: p(0.91, 0.16), control: p(0.88, 0.03))
        path.addQuadCurve(to: p(0.93, 0.30), control: p(0.98, 0.22))
        path.addQuadCurve(to: p(0.94, 0.47), control: p(0.98, 0.38))
        path.addQuadCurve(to: p(0.93, 0.65), control: p(0.99, 0.57))
        path.addQuadCurve(to: p(0.91, 0.83), control: p(0.98, 0.77))
        path.addQuadCurve(to: p(0.78, 0.93), control: p(0.89, 0.96))
        path.addQuadCurve(to: p(0.62, 0.92), control: p(0.71, 0.98))
        path.addQuadCurve(to: p(0.47, 0.93), control: p(0.55, 0.99))
        path.addQuadCurve(to: p(0.30, 0.93), control: p(0.38, 0.99))
        path.addQuadCurve(to: p(0.12, 0.86), control: p(0.16, 0.97))
        path.addQuadCurve(to: p(0.08, 0.68), control: p(0.01, 0.80))
        path.addQuadCurve(to: p(0.08, 0.50), control: p(0.01, 0.60))
        path.addQuadCurve(to: p(0.09, 0.33), control: p(0.01, 0.42))
        path.addQuadCurve(to: p(0.14, 0.10), control: p(0.03, 0.18))
        path.closeSubpath()
        return path
    }
}


// Resolve both resource delivery paths. A root-level PNG is the primary path;
// the xcassets image is kept as a secondary fallback for existing projects.
private enum MemoDecorationLoader {
    static let image: UIImage? = {
        if let url = Bundle.main.url(forResource: "memo-decoration", withExtension: "png"),
           let image = UIImage(contentsOfFile: url.path) { return image }
        if let image = UIImage(named: "memo-decoration") { return image }
        return UIImage(named: "MemoDecoration")
    }()
}
