import SwiftUI

struct FavoritesView: View {
    @ObservedObject private var store = QuickAccessStore.shared
    var body: some View {
        List {
            Section {
                if store.favorites.isEmpty {
                    Text("Tap the star on Recommend to save a merchant or category.")
                }
                ForEach(store.favorites) { favorite in
                    HStack {
                        Label(favorite.title, systemImage: favorite.category.icon)
                        Spacer()
                        Button("Remove", role: .destructive) { store.toggle(favorite) }
                            .accessibilityLabel("Remove \(favorite.title) from favorites")
                    }
                }
                .onMove { source, destination in
                    var favorites = store.favorites
                    favorites.move(fromOffsets: source, toOffset: destination)
                    store.reorder(ids: favorites.map(\.id))
                }
            } footer: {
                Text("Favorites are saved on this device. Pinned wallet cards do not change reward ranking.")
            }
        }.navigationTitle("Favorites")
            .toolbar { EditButton().disabled(store.favorites.count < 2) }
    }
}
