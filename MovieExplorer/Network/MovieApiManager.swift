import UIKit
import Alamofire
    
// Api Manager
class MovieApiManager: NSObject {
    
    static let api_key = "" /** INSERT YOUR API KEY HERE **/
    static var base_url : String? = nil
    static var poster_small_size_prefix : String? = nil
    
    
    /// Preparation method need for requesting base information ad base_url and poster prefixes
    ///
    /// - Parameter callback: called when all data requested
    static func prepare(_ callback: @escaping () -> Void )
    {
        let parameters : Parameters = [
            "api_key": api_key
        ];
        
        Alamofire.request("https://api.themoviedb.org/3/configuration", method: .get, 
                          parameters: parameters, 
                          encoding: URLEncoding.queryString, 
                          headers: [:]).responseJSON { (data) in
            
            if let result = data.result.value {
                let JSON = result as! NSDictionary
                let imagesJSON = JSON["images"] as! NSDictionary
                self.base_url = imagesJSON["base_url"] as? String
                let poster_sizes = imagesJSON["poster_sizes"] as! Array<String>
                self.poster_small_size_prefix = poster_sizes.first
                
                callback()
            }
        }
    }
    
    
    /// Method for searching films
    ///
    /// - Parameters:
    ///   - string: search string for searching movies
    ///   - page: page number in paginated server responses
    ///   - callback: called on finished
    static func fetchPageOfMoviesFor( searchString string: String, 
                                      page:Int, 
                                      callback: @escaping ([MovieInfo], Int, Int, Int) -> Void ) -> Void 
    {
        
        let parameters : Parameters = [
            "api_key": api_key,
            "query": string,
            "page": page
        ];
        
        /// queue for parsing response on background thread to non-blocking UI behaiviour
        let queue = DispatchQueue(label: "com.background-response-parsing", qos: .utility, attributes: [.concurrent])
        
        let request = Alamofire.request("https://api.themoviedb.org/3/search/movie", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: [:])
        
        request.responseJSON(queue: queue, options: .allowFragments) { (data) in
            if let result = data.result.value {
                var movies = [MovieInfo]()
                var pagesCount = 0
                var allMovies = 0
                
                if let JSON = result as? NSDictionary 
                {
                    if let results = JSON["results"] as? Array<NSDictionary> 
                    {
                        pagesCount = JSON["total_pages"] as! Int
                        allMovies = JSON["total_results"] as! Int
                        
                        for mInfo : NSDictionary in results {
                            let id = mInfo["id"] as! Int
                            let info = MovieInfo(id:id)
                            
                            if let name = mInfo["title"] as? String 
                            {
                                info.name = name
                            }
                            
                            if let imageURLString = mInfo["poster_path"] as? String
                            {
                                let fullURLString = String(format:"%@%@%@", base_url!, poster_small_size_prefix!, imageURLString)
                                let url = URL(string:fullURLString)
                                
                                do{
                                    let imageData = try Data(contentsOf: url!)
                                    let image = UIImage(data: imageData)
                                    info.thumbnail = image
                                }
                                catch
                                {
                                }
                            }
                            
                            movies.append( info )
                        }  
                    }
                }
                
                callback(movies, pagesCount, allMovies, page)
            }
        }
    }
    
    
    
    /// Fetch info on specific movie
    ///
    /// - Parameters:
    ///   - id: internal movie db id of the film ( can be fetched in fetchPageOfMoviesFor method 
    ///   - callback: called on request finished
    static func fetchInfoForMovie( movieID id: Int,  
                                   callback: @escaping ( _ poster: UIImage?, _ textDescription: String) -> Void ) -> Void 
    {
        let parameters : Parameters = [
            "api_key": api_key
        ];
        
        Alamofire.request("https://api.themoviedb.org/3/movie/" + String(id), method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: [:]).responseJSON { (data) in
            
            var textDescription = "";
            var image: UIImage? = nil
            if let result = data.result.value {
                if let JSON = result as? NSDictionary 
                {
                    if let overview = JSON["overview"] as? String
                    {
                        textDescription = overview
                    }
                    
                    if let imageURLString = JSON["poster_path"] as? String
                    {
                        let fullURLString = String(format:"%@original%@", base_url!, imageURLString)
                        let url = URL(string:fullURLString)
                        do{
                            let imageData = try Data(contentsOf: url!)
                            image = UIImage(data: imageData)
                        }
                        catch
                        {
                        }
                    }
                }
            }
            callback(image, textDescription)
        }
    }
}
