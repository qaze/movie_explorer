import UIKit

/// Base movie info
class MovieInfo: NSObject {
    
    let id: Int!
    var name : String? = ""
    var thumbnail : UIImage? = nil

    init(id movieID: Int ) {
        self.id = movieID
    }
}
