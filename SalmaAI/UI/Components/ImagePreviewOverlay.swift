import SwiftUI

struct ImagePreviewOverlay: View {
    let image: UIImage
    @Binding var isPresented: Bool
    var onRetake: (() -> Void)?
    var onUse: (() -> Void)?

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var showControls = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Image with zoom/pan
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(magnificationGesture)
                .gesture(dragGesture)
                .onTapGesture(count: 2) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if scale > 1.0 {
                            scale = 1.0; lastScale = 1.0
                            offset = .zero; lastOffset = .zero
                        } else {
                            scale = 2.0; lastScale = 2.0
                        }
                    }
                }
                .onTapGesture(count: 1) {
                    withAnimation { showControls.toggle() }
                }

            // Controls overlay
            if showControls {
                VStack {
                    // Top bar
                    HStack {
                        Spacer()
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(SalmaDesign.Spacing.md)
                    }

                    Spacer()

                    // Bottom bar
                    if onRetake != nil || onUse != nil {
                        HStack(spacing: SalmaDesign.Spacing.md) {
                            if let retake = onRetake {
                                Button {
                                    retake()
                                    isPresented = false
                                } label: {
                                    Text(L("retake"))
                                        .font(SalmaDesign.Typography.bodyMedium)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(.white.opacity(0.2))
                                        .cornerRadius(SalmaDesign.Radius.md)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: SalmaDesign.Radius.md)
                                                .stroke(.white.opacity(0.4), lineWidth: 1)
                                        )
                                }
                            }

                            if let use = onUse {
                                Button {
                                    use()
                                    isPresented = false
                                } label: {
                                    Text(L("use_photo"))
                                        .font(SalmaDesign.Typography.bodyMedium)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(SalmaDesign.Colors.primary)
                                        .cornerRadius(SalmaDesign.Radius.md)
                                }
                            }
                        }
                        .padding(.horizontal, SalmaDesign.Spacing.md)
                        .padding(.bottom, SalmaDesign.Spacing.xl)
                    }
                }
                .transition(.opacity)
            }
        }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                scale = min(max(newScale, 1.0), 5.0)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1.0 {
                    withAnimation { offset = .zero; lastOffset = .zero }
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1.0 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
}
