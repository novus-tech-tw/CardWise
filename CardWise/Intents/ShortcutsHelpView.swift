import SwiftUI
import AppIntents

struct ShortcutsHelpView: View {
    var body: some View {
        List {
            Section("Find Your Best Card") {
                Text("In Shortcuts, add a CardWise action: Best Card for a Merchant or Best Card for a Category. Choose a purchase amount to get an estimated reward.")
                Text("You can also say: “Find my best card with CardWise” or “Compare my cards with CardWise.” Siri asks for the merchant or category. The amount defaults to $100; set a different amount in Shortcuts.")
                ShortcutsLink()
            }
            Section("Shopping Mode") {
                Text("Say “Start shopping mode in CardWise” to keep the best card for a merchant on your Lock Screen and in the Dynamic Island for up to 4 hours. Say “End shopping mode in CardWise” or tap the close button to remove it.")
            }
            Section("Wallet Check-ins") {
                Text("“Show unused credits in CardWise”, “Show card deadlines in CardWise” and “Show bonus categories in CardWise” read your saved wallet. Nothing leaves your device.")
            }
            Section("Saved Merchant Offers") {
                Text("Get Saved Merchant Offers returns your current manually entered offers for a merchant, or all merchants when left empty. " +
                     "Get Best Saved Merchant Offer compares eligible savings for one merchant and purchase amount. Both return offer details you can use in later Shortcut actions.")
                Text("The best offer uses your activation confirmation, minimum spend, maximum reward and expiry. Offer savings are separate from base card rewards. Confirm eligibility with your issuer.")
                Text("Set Card to search just that saved card, or leave it empty to search your wallet. The app's Your Offers screen has the same current inventory, plus search and used, expired and archived history.")
            }
            Section("Your Saved Preferences") {
                Text("Actions use your recorded purchases, spending caps, point values and ranking preference. Open CardWise after changing data on another device. Unlock your device to run an action.")
            }
        }.navigationTitle("Siri & Shortcuts")
    }
}
