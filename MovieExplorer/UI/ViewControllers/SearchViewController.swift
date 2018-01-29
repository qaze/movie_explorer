import UIKit

class SearchViewController: UIViewController
{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var movies : Array<MovieInfo> = [MovieInfo]() 
    
    var totalMovies : Int = 0
    var totalPages : Int = 0
    var currentPage : Int = 1
    
    var isLoadingNewPage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MovieApiManager.prepare {
            DispatchQueue.main.async {
                self.searchBar.isHidden = false
                self.activityIndicator.stopAnimating()   
            }
        }
    }

    /// Configuring DetailedMovieController by click
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMovieDetails" {
            let destVC = segue.destination as! DetailsViewController
            let senderCell = sender as! MovieTableViewCell
            destVC.configure(info: senderCell.info!)
        }
    }
    
    @IBAction func unwindToSearchScreen(_ segue: UIStoryboardSegue )
    {
        
    }
    
    
    /// Method for requesting more pages
    func loadMore()
    {
        if( !isLoadingNewPage )
        {
            isLoadingNewPage = true
            currentPage += 1
            MovieApiManager.fetchPageOfMoviesFor(searchString: self.searchBar.text!, page: self.currentPage) { (fetchedMovies, pageCount, moviesCount, currentPage ) in
                self.movies.append(contentsOf: fetchedMovies)
                self.currentPage = currentPage
                self.totalPages = pageCount
                self.totalMovies = moviesCount
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.isLoadingNewPage = false
                }
            }
        }
    }
    
}


// MARK: - UITableView Data Source and Delegate Methods
extension SearchViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var resultCell : UITableViewCell? = nil;
        
        if( indexPath.row == movies.count )
        {
            resultCell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell")
        }
        else
        {
            let cell : MovieTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieTableViewCell
            let info = movies[indexPath.row]
            cell.configure(info: info)
            resultCell = cell;
        }
        
        return resultCell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if( movies.count == totalMovies || totalPages == currentPage )
        {
            return movies.count
        }
        
        return movies.count + 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if( indexPath.row == self.movies.count )
        {
            loadMore()
        }
    }
}


// MARK: - UISearchBar delegate methods
extension SearchViewController : UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        self.activityIndicator.startAnimating()
        currentPage = 1
        MovieApiManager.fetchPageOfMoviesFor(searchString: searchBar.text!, page: currentPage ) 
        { (fetchedMovies, pageCount, moviesCount, currentPage) in
            
            self.movies = fetchedMovies
            self.currentPage = currentPage
            self.totalPages = pageCount
            self.totalMovies = moviesCount
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
}
