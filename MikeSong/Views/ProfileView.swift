//
//  ProfileView.swift
//  BearSong
//

import SwiftUI

private struct MixcloudProfile: Decodable {
    let name: String?
    let biog: String?
    let city: String?
    let favorite_count: Int?
    let following_count: Int?
    let pictures: Pictures?
}

struct ProfileView: View {
    @Environment(\.openURL) private var openURL

    @State private var profile: MixcloudProfile?
    @State private var isLoading = false
    @State private var hasError = false

    private let profileURL = URL(string: "https://api.mixcloud.com/rennan-rebou%C3%A7as/")!
    private let editProfileURL = URL(string: "https://www.mixcloud.com/settings/profile/")!

    var body: some View {
        ZStack {
            if hasError && profile == nil {
                errorView
            } else {
                ScrollView {
                    VStack(spacing: LayoutConstants.paddingStandard) {
                        if let profile {
                            profileImage(urlString: profile.pictures?._640wx640h)
                            card("Name", text: profile.name ?? "")
                            card("Bio", text: profile.biog ?? "")
                            card("City", text: profile.city ?? "")
                            card("Favorites", text: "Favorites Sounds: \(profile.favorite_count ?? 0)")
                            card("Following", text: "Following: \(profile.following_count ?? 0)")
                            Button("Edit profile") { openURL(editProfileURL) }
                                .padding()
                        }
                    }
                    .padding(LayoutConstants.sectionPadding)
                }
                .background(Image("backgroundProfile").resizable().scaledToFill().ignoresSafeArea())
            }
            if isLoading { ProgressView().scaleEffect(1.5) }
        }
        .navigationTitle("Profile")
        .task { await loadProfile() }
    }

    private func profileImage(urlString: String?) -> some View {
        Group {
            if let urlString, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholderImage
                    case .empty:
                        placeholderImage.overlay { ProgressView() }
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
        .frame(width: 157, height: 158)
        .clipShape(RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusLarge)
                .strokeBorder(Color.white, lineWidth: LayoutConstants.borderWidth)
        )
    }

    private var placeholderImage: some View {
        Rectangle().fill(Color.gray.opacity(0.3))
    }

    private func card(_ title: String, text: String) -> some View {
        VStack {
            Text(text)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusMedium)
                .strokeBorder(Color.white, lineWidth: LayoutConstants.borderWidth)
        )
    }

    private var errorView: some View {
        VStack(spacing: LayoutConstants.paddingStandard) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Erro ao carregar perfil.")
                .foregroundStyle(.secondary)
                .onTapGesture { Task { await loadProfile() } }
        }
        .padding()
    }

    private func loadProfile() async {
        isLoading = true
        hasError = false
        defer { isLoading = false }
        do {
            let (data, response) = try await URLSession.shared.data(from: profileURL)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                hasError = true
                return
            }
            let decoded = try JSONDecoder().decode(MixcloudProfile.self, from: data)
            await MainActor.run {
                profile = decoded
            }
        } catch {
            hasError = true
        }
    }
}

#Preview {
    NavigationStack { ProfileView() }
}
