import SwiftUI

struct ItemCellView: View {
    private let item: FolderItem

    init(item: FolderItem) {
        self.item = item
    }
    
    var body: some View {
        switch item {
        case .site(let site):
            SiteCellView(site: site)
        case .folder(let folder):
            FolderCellView(folder: folder)
        }
    }
}

struct SiteCellView: View {
    private let site: Site

    init(site: Site) {
        self.site = site
    }
    
    var body: some View {
        return NavigationLink(destination: WebView(site: site)) {
            HStack {
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.blue)
                Text(site.description).font(.headline)
            }
        }.accessibilityLabel(site.description)
    }
}

// Here, we let the cell view ingest a model object type, Folder. This
// works fairly well because the Folder object contains almost nothing
// beyond what's needed for display, so it's roughly equivalent to a view
// model. However, we could create decoupling here by using an explicit
// view model instead.
struct FolderCellView: View {
    private let folder: Folder

    init(folder: Folder, isExpanded: Bool = false) {
        self.folder = folder
    }

    var body: some View {
        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(folder.description).font(.headline)
            }
        }.accessibilityLabel(folder.description)
    }
}

private let googleUrl = URL(string: "https://google.com")!
private let msnUrl = URL(string: "https://msn.com")!

private func randomItem(index: Int) -> FolderItem {
    let id = "item_\(index)"
    switch index % 3 {
    case 0:
        return .site(Site(url: googleUrl, id: id, description: "Google \(index)"))
    case 1:
        return .site(Site(url: msnUrl, id: id, description: "MSN \(index)"))
    case 2:
        let items: [FolderItem] = [
            .site(Site(url: msnUrl, id: "\(id)_msn", description: "MSN")),
            .site(Site(url: msnUrl, id: "\(id)_google", description: "Google"))
        ]
        return .folder(Folder(items: items, id: id, description: "Folder \(index)"))
    default:
        fatalError()
    }
}

class InfiniteScrollViewModel: ObservableObject {
    @Published var items: [FolderItem] = []
    @Published var showingAlert = false

    init() {
        loadMoreItems()
    }

    func loadMoreItems() {
        let newItems = (self.items.count..<(self.items.count + 20)).map { index in
            randomItem(index: index)
        }
        self.items.append(contentsOf: newItems)
        // Keeping infinite items in memory could create memory issues
        // if the list is extremely long. A real-world solution may need to only keep part of the items list in memory, and the rest on disk.
        if Int.random(in: 0..<20) == 0 {
            // Simulated web load failure: uncomment the line below to occasionally show failure alert
            // showingAlert = true
        }
    }
}

struct ContentView: View {
    @ObservedObject private var viewModel = InfiniteScrollViewModel()

    var body: some View {
        NavigationView {
            VStack {
                List($viewModel.items, children: \.children) { item in
                    ItemCellView(item: item.wrappedValue).onAppear {
                        if let last = viewModel.items.last {
                            if item.wrappedValue.id == last.id {
                                viewModel.loadMoreItems()
                            }
                        }
                    }
                }
            }
        }.alert("Web Failure", isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

#Preview {
    ContentView()
}
