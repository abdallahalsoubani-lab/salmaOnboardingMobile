import SwiftUI

struct JourneySelectionView: View {
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var languageManager: LanguageManager

    @Environment(\.colorScheme) private var colorScheme

    @State private var journeys: [PublishedJourney] = []
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var selectedJourneyId: String?

    var body: some View {
        ZStack {
            ThemedColors.background(for: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text(L("choose_journey"))
                    .font(SalmaDesign.Typography.title2)
                    .foregroundColor(ThemedColors.textPrimary(for: colorScheme))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, SalmaDesign.Spacing.lg)
                    .padding(.top, SalmaDesign.Spacing.md)
                    .padding(.bottom, SalmaDesign.Spacing.lg)
                    .animation(AppAnimations.fadeIn, value: isLoading)

                Group {
                    if isLoading {
                        loadingView
                    } else if loadFailed {
                        errorView
                    } else if journeys.isEmpty {
                        emptyView
                    } else {
                        journeyList
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(AppAnimations.fadeIn, value: isLoading)
                .animation(AppAnimations.fadeIn, value: journeys.count)
                .animation(AppAnimations.fadeIn, value: loadFailed)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.presentSheet(.languageSwitch)
                } label: {
                    Image(systemName: "globe")
                        .font(.system(size: 18))
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                }
            }
        }
        .task {
            await loadPublishedJourneys()
        }
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: SalmaDesign.Spacing.lg) {
            Spacer()
            ProgressView()
                .tint(ThemedColors.primary)
                .scaleEffect(1.1)
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            Spacer()
            Image(systemName: "map")
                .font(.system(size: 48))
                .foregroundColor(SalmaDesign.Colors.textTertiary)
            Text(L("no_journeys_available"))
                .font(SalmaDesign.Typography.body)
                .foregroundColor(ThemedColors.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, SalmaDesign.Spacing.xl)
            Spacer()
        }
    }

    private var errorView: some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(SalmaDesign.Colors.warning)
            Text(L("error"))
                .font(SalmaDesign.Typography.body)
                .foregroundColor(ThemedColors.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, SalmaDesign.Spacing.xl)
            SalmaButton(title: L("retry"), style: .secondary) {
                Task { await loadPublishedJourneys() }
            }
            .padding(.horizontal, SalmaDesign.Spacing.xxl)
            Spacer()
        }
    }

    private var journeyList: some View {
        ScrollView {
            LazyVStack(spacing: SalmaDesign.Spacing.md) {
                ForEach(Array(journeys.enumerated()), id: \.element.id) { index, journey in
                    JourneySelectionCard(
                        displayName: displayName(for: journey),
                        stepsLabel: String(format: L("steps_count"), journey.pageCount),
                        isSelected: isCardSelected(journey)
                    ) {
                        select(journey)
                    }
                    .staggeredAppear(index: index)
                }
            }
            .padding(.horizontal, SalmaDesign.Spacing.lg)
            .padding(.bottom, SalmaDesign.Spacing.xl)
        }
    }

    // MARK: - Actions

    private func displayName(for journey: PublishedJourney) -> String {
        return journey.name
    }

    private func isCardSelected(_ journey: PublishedJourney) -> Bool {
        journey.id == selectedJourneyId
    }

    private func select(_ journey: PublishedJourney) {
        flowState.prepareForNewJourney()
        selectedJourneyId = journey.id
        flowState.selectedJourneyId = journey.id
        HapticManager.notification(.success)
        router.push(.journeyLoading)
    }

    @MainActor
    private func loadPublishedJourneys() async {
        isLoading = true
        loadFailed = false
        do {
            let list = try await container.journeyService.getPublishedJourneys()
            if list.count == 1, let only = list.first {
                flowState.prepareForNewJourney()
                flowState.selectedJourneyId = only.id
                isLoading = false
                router.push(.journeyLoading)
                return
            }
            journeys = list
            isLoading = false
        } catch {
            isLoading = false
            loadFailed = true
        }
    }
}

// MARK: - Card

private struct JourneySelectionCard: View {
    let displayName: String
    let stepsLabel: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: SalmaDesign.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(ThemedColors.primaryLight.opacity(0.2))
                        .frame(width: 52, height: 52)
                    Image(systemName: "checklist")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(ThemedColors.primary)
                }

                VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
                    Text(displayName)
                        .font(SalmaDesign.Typography.title3)
                        .foregroundColor(ThemedColors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(stepsLabel)
                        .font(SalmaDesign.Typography.callout)
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Image(systemName: "chevron.forward")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(SalmaDesign.Colors.textTertiary)
            }
            .padding(SalmaDesign.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(SalmaDesign.Colors.surface)
            .cornerRadius(SalmaDesign.Radius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: SalmaDesign.Radius.lg)
                    .stroke(
                        isSelected ? ThemedColors.primary : SalmaDesign.Colors.border,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: SalmaDesign.Shadows.card.color,
                radius: SalmaDesign.Shadows.card.radius,
                x: SalmaDesign.Shadows.card.x,
                y: SalmaDesign.Shadows.card.y
            )
        }
        .buttonStyle(.plain)
        .pressAnimation()
    }
}
