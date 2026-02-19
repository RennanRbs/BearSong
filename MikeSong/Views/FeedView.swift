//
//  FeedView.swift
//  BearSong
//

import SwiftUI
import CoreData
import UIKit

struct FeedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) private var openURL

    @State private var items: [CloudcastItem] = []
    @State private var isLoading = false
    @State private var hasError = false
    @State private var favoritedItemNames: Set<String> = []

    private let feedURL = URL(string: "https://api.mixcloud.com/search/?q=music&type=cloudcast&limit=20")!
    private let columns = [
        GridItem(.flexible(), spacing: LayoutConstants.cellSpacing),
        GridItem(.flexible(), spacing: LayoutConstants.cellSpacing)
    ]

    var body: some View {
        ZStack {
            if hasError && items.isEmpty {
                errorView
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: LayoutConstants.cellSpacing) {
                        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                            FeedCardView(
                                item: item,
                                isFavorited: favoritedItemNames.contains(item.name ?? ""),
                                onTap: { saveFavorite(for: item) }
                            )
                            .contextMenu {
                                Button("Favorite this HotSong") { saveFavorite(for: item) }
                                if let urlString = item.url, let url = URL(string: urlString) {
                                    Button("Listen this Song") { openURL(url) }
                                }
                            }
                        }
                    }
                    .padding(LayoutConstants.sectionPadding)
                }
                .refreshable { await loadFeed() }
            }

            if isLoading { ProgressView().scaleEffect(1.5) }
        }
        .navigationTitle("Hot Song Bear")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { Task { await loadFeed() } }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .task {
            loadFavoritedNames()
            await loadFeed()
        }
    }

    private var errorView: some View {
        VStack(spacing: LayoutConstants.paddingStandard) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Nao foi possivel carregar o feed. Toque para tentar novamente.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .onTapGesture { Task { await loadFeed() } }
        }
        .padding()
    }

    private func loadFeed() async {
        isLoading = true
        hasError = false
        defer { isLoading = false }
        do {
            let (data, response) = try await URLSession.shared.data(from: feedURL)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                hasError = true
                return
            }
            let decoded = try MixcloudFeedResponse.decode(from: data)
            await MainActor.run {
                items = decoded.data ?? []
                if items.isEmpty { hasError = true }
            }
        } catch {
            hasError = true
        }
    }

    private func loadFavoritedNames() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = ["name"]
        do {
            let results = try viewContext.fetch(request) as? [[String: Any]]
            let names = (results ?? []).compactMap { $0["name"] as? String }
            favoritedItemNames = Set(names)
        } catch {}
    }

    private func saveFavorite(for item: CloudcastItem) {
        let name = item.name ?? "Unknown"
        guard !name.isEmpty else { return }
        Task {
            var image: UIImage?
            if let urlString = item.pictures?._640wx640h, let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) { image = UIImage(data: data) }
            }
            guard let img = image else { return }
            let saved = FavoriteStorageHelper.saveFavorite(image: img, name: name, context: viewContext)
            if saved {
                await MainActor.run { favoritedItemNames.insert(name) }
            }
        }
    }
}

// MARK: - FeedCardView

struct FeedCardView: View {
    let item: CloudcastItem
    let isFavorited: Bool
    let onTap: () -> Void

    var body: some View {
        let url = item.pictures.flatMap { $0._640wx640h }.flatMap { URL(string: $0) }
        GeometryReader { geo in
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        Color.gray.opacity(0.3)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: geo.size.width, height: geo.size.width)
                .clipped()
                .contentShape(Rectangle())
                .onTapGesture(perform: onTap)

                if isFavorited {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.pink)
                        .font(.system(size: 24))
                        .padding(LayoutConstants.paddingStandard)
                }
            }
            .frame(width: geo.size.width, height: geo.size.width)
            .clipShape(RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusMedium))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    NavigationStack {
        FeedView()
            .environment(\.managedObjectContext, .init())
    }
}
