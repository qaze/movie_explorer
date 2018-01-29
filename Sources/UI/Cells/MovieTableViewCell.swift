import UIKit

/// Cell for displaing thumbnail and title of film
class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameView: UITextView!
    
    weak var info : MovieInfo? = nil
    
    func configure( info movieInfo: MovieInfo )
    {
        self.info = movieInfo
        
        DispatchQueue.main.async {
            self.thumbnailImageView.image = self.info?.thumbnail
            self.nameView.text = self.info?.name
        }
    }
    
    
}
