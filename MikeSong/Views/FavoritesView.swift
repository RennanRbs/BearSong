//
//  FavoritesView.swift
//  BearSong
//

import SwiftUI
import CoreData
import UIKit

struct FavoritesView: View {
    @FetchRequest(sortDescriptors: []) private var favorites: FetchedResults<Favorite>

    var body: some View {
        Group {
            if favorites.isEmpty {
                Text("No favorites yet")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: LayoutConstants.cellSpacing) {
                        ForEach(favorites, id: \.objectID) { favorite in
                            FavoriteCardView(pathImageFavorite: favorite.pathImageFavorite ?? "")
                        }
                    }
                    .padding(LayoutConstants.sectionPadding)
                }
            }
        }
        .navigationTitle("Favorites")
    }
}

// MARK: - FavoriteCardView (loads image from disk)

struct FavoriteCardView: View {
    let pathImageFavorite: String
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay { ProgressView() }
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusMedium))
        .task { loadImage() }
    }

    private func loadImage() {
        guard !pathImageFavorite.isEmpty else { return }
        let fileManager = FileManager.default
        guard let docURL = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return }
        let fileURL = docURL.appendingPathComponent(FavoriteStorageHelper.favoritesSubdirectory).appendingPathComponent(pathImageFavorite)
        guard let data = try? Data(contentsOf: fileURL), let uiImage = UIImage(data: data) else { return }
        Task { @MainActor in image = uiImage }
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
            .environment(\.managedObjectContext, .init())
    }
}
