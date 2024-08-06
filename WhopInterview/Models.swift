import Foundation

// Swift structs can have surprising performance characteristics (needing more than one retain/release
// where a class would only need one, increasing app size due to value witnesses, etc.). Their benefits as
// immutable objects may still outweigh their performance downsides, but the two should be considered together.
// Here we use final classes with immutable members (aside from the enum) to highlight the alternative
final class Site {
    let url: URL
    let id: String
    let description: String

    init(url: URL, id: String, description: String) {
        self.url = url
        self.id = id
        self.description = description
    }
}

final class Folder {
    let items: [FolderItem]
    let id: String
    let description: String

    init(items: [FolderItem], id: String, description: String) {
        self.items = items
        self.id = id
        self.description = description
    }
}

extension Folder: Identifiable {
}

enum FolderItem {
    case site(Site)
    case folder(Folder)
    
    var children: [FolderItem]? {
        get {
            switch self {
            case .site(_):
                return nil
            case .folder(let folder):
                return folder.items
            }
        }
        set {
            fatalError()
        }
    }
}

extension FolderItem: Identifiable {
    var id: String {
        switch self {
        case .site(let site):
            return site.id
        case .folder(let folder):
            return folder.id
        }
    }
}

