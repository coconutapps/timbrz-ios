import SwiftUI

struct MessagesView: View {
    struct Thread: Identifiable { let id: String; let listingTitle: String; let last: String }
    let threads: [Thread] = [
        .init(id: "t1", listingTitle: "Straw-bale Lakefront Cabin", last: "Can we tour Saturday?"),
        .init(id: "t2", listingTitle: "A-frame under the Cedars", last: "Is STR allowed?")
    ]

    var body: some View {
        NavigationStack {
            List(threads) { t in
                NavigationLink(destination: ChatView(title: t.listingTitle)) {
                    VStack(alignment: .leading) {
                        Text(t.listingTitle).font(.headline)
                        Text(t.last).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Messages")
        }
    }
}

struct ChatView: View {
    let title: String
    @State private var text: String = ""
    var body: some View {
        VStack {
            ScrollView { Text("(Conversation stub)").frame(maxWidth: .infinity, alignment: .leading).padding() }
            HStack {
                TextField("Message", text: $text).textFieldStyle(.roundedBorder)
                Button(action: { text = "" }) {
                    Image(systemName: "paperplane.fill")
                }
                    .buttonStyle(.borderedProminent)
            }.padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View { MessagesView() }
}
