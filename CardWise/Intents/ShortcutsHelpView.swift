import SwiftUI
import AppIntents

struct ShortcutsHelpView: View {
    var body: some View {
        List {
            Section("Find Your Best Card") {
                Text("In Shortcuts, add a CardWise action: Best Card for a Merchant or Best Card for a Category. Choose a purchase amount to get an estimated reward.")
                Text("You can also say: “Find my best card with CardWise” or “Compare my cards with CardWise.” Siri asks for the merchant or category and amount.")
                ShortcutsLink()
            }
            Section("Your Saved Preferences") {
                Text("Actions use your recorded purchases, spending caps, point values and ranking preference. Open CardWise after changing data on another device. Unlock your device to run an action.")
            }
        }.navigationTitle("Siri & Shortcuts")
    }
}
