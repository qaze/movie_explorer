import UIKit

/// Detailed view controller for movie
class DetailsViewController: UIViewController {
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var textDescription: UITextView!
    @IBOutlet weak var titleItem: UINavigationItem!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    var movie : MovieInfo? = nil
    
    /// Configuration of VC with Movie Info
    ///
    /// - Parameter movieInfo: movie info
    func configure( info movieInfo: MovieInfo )
    {
        self.movie = movieInfo
        MovieApiManager.fetchInfoForMovie(movieID: (self.movie?.id)!) { (image, textDescription) in
            DispatchQueue.main.async {
                self.poster.image = image
                self.textDescription.text = textDescription
                DispatchQueue.main.async {
                    self.loadingView.stopAnimating()
                }
            }
        }
        
        DispatchQueue.main.async {
            self.titleItem.title = self.movie?.name
        }
    }
    
    
    @IBAction func unwindToSearchScreen(_ segue: UIStoryboardSegue )
    {
    }
}
