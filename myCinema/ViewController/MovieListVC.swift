//
//  MovieListVC.swift
//  myCinema
//
//  Created by t2023-m0028 on 1/17/24.
//

import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}


class MovieListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {

    var tableView: UITableView!
    let sectionTitles = ["Popular Movies", "Now Playing","Top Rated Movies", "Upcoming Movies"]
    var upcomingMoviesData: [Movie] = []
    var topRatedMoviesData: [Movie] = []
    var popularMoviesData: [Movie] = []
    var nowPlayingMoviesData: [Movie] = []
    var bookmarkedMovies: [Movie] = []

    @objc func heartButtonTapped(_ sender: UIButton) {
        let section = sender.tag / 1000
        let item = sender.tag % 1000
        let selectedMovie: Movie

        switch section {
        case 0: selectedMovie = popularMoviesData[item]
        case 1: selectedMovie = nowPlayingMoviesData[item]
        case 2: selectedMovie = topRatedMoviesData[item]
        case 3: selectedMovie = upcomingMoviesData[item]
        default: return
        }

        if !bookmarkedMovies.contains(where: { $0 as AnyObject === selectedMovie as AnyObject }) {
            bookmarkedMovies.append(selectedMovie)
            print("\(selectedMovie.title)이 관심영화 리스트에 담겼습니다.")
        } else {
            if let index = bookmarkedMovies.firstIndex(where: { ($0 as AnyObject) === (selectedMovie as AnyObject) }) {
                bookmarkedMovies.remove(at: index)
                print("\(selectedMovie.title)이 관심영화 리스트에서 제거되었습니다.")
            }
        }

        sender.isSelected = !sender.isSelected
        sender.setImage(UIImage(systemName: sender.isSelected ? "heart.fill" : "heart"), for: .normal)

        let indexPath = IndexPath(item: item, section: section)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func parseMovieData(jsonArray: [[String: Any]]) -> [Movie] {
        var movies: [Movie] = []

        for movieData in jsonArray {
            if let id = movieData["id"] as? Int,
               let title = movieData["title"] as? String,
               let posterPath = movieData["poster_path"] as? String {
                let movie = Movie(id: id, title: title, posterPath: posterPath)
                movies.append(movie)
            }
        }

        return movies
    }

    // 영화 데이터를 가져오는 메서드
    func fetchMovieData(endpoint: String, section: Int) {
        // API 키 및 엔드포인트를 이용하여 URL 생성
        let apiKey = "a4da431c6791ead04a4fed52ad08e4fc"
        let urlString = "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)"
        
        // URL이 유효한지 확인
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        // 네트워크 작업을 비동기로 수행
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            // 데이터 및 에러 확인
            guard let data = data, error == nil else {
                print("Error fetching movie data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                // JSON 데이터 파싱
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("JSON Data: \(json)")
                // 파싱된 데이터를 Movie 객체로 변환
                if let jsonArray = json as? [String: Any], let results = jsonArray["results"] as? [[String: Any]] {
                    let movies = self.parseMovieData(jsonArray: results)
                    DispatchQueue.main.async {
                        // 적절한 섹션에 파싱된 데이터 삽입 및 테이블 뷰 리로드
                        switch section {
                        case 0: self.popularMoviesData = movies
                        case 1: self.nowPlayingMoviesData = movies
                        case 2: self.topRatedMoviesData = movies
                        case 3: self.upcomingMoviesData = movies
                        default: break
                        }
                        self.tableView.reloadData()
                        
                        // 각 영화의 상세 정보를 가져오기
                        for movie in movies {
                            self.fetchMovieDetails(movieID: movie.id)
                        }
                    }
                }
            } catch {
                print("Error parsing movie data: \(error.localizedDescription)")
            }
        }.resume()
    }

    // 영화 상세 정보를 가져오는 메서드
    func fetchMovieDetails(movieID: Int) {
        let apiKey = "a4da431c6791ead04a4fed52ad08e4fc"
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)?api_key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching movie details: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                // JSON 데이터 파싱
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let movieDetails = json as? [String: Any] {
                    // 여기에서 movieDetails를 활용하여 상세 정보 업데이트
                    // 예를 들면, 영화 제목, 설명, 출시일 등을 가져와서 업데이트할 수 있습니다.
                    print("Movie details: \(movieDetails)")
                }
            } catch {
                print("Error parsing movie details: \(error.localizedDescription)")
            }
        }.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true

        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
        view.addSubview(tableView)

        fetchMovieData(endpoint: "popular", section: 0)
        fetchMovieData(endpoint: "now_playing", section: 1)
        fetchMovieData(endpoint: "top_rated", section: 2)
        fetchMovieData(endpoint: "upcoming", section: 3)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)

        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }

        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: cell.contentView.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.tag = indexPath.section
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCellIdentifier\(collectionView.tag)")
        collectionView.backgroundColor = UIColor.white
        cell.contentView.addSubview(collectionView)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(hex: "0x6aa3ff")

        let titleLabel = UILabel()
        titleLabel.text = sectionTitles[section]
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.textColor = UIColor.white
        headerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0: return popularMoviesData.count
        case 1: return nowPlayingMoviesData.count
        case 2: return topRatedMoviesData.count
        case 3: return upcomingMoviesData.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCellIdentifier\(collectionView.tag)", for: indexPath)

        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }

        let movie: Movie

        switch collectionView.tag {
        case 0: movie = popularMoviesData[indexPath.item]
        case 1: movie = nowPlayingMoviesData[indexPath.item]
        case 2: movie = topRatedMoviesData[indexPath.item]
        case 3: movie = upcomingMoviesData[indexPath.item]
        default: return cell
        }

        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: cell.contentView.bounds.width - 20, height: cell.contentView.bounds.height - 60))
        loadImage(for: movie, into: imageView)
        cell.contentView.addSubview(imageView)

        let heartButton = UIButton(type: .custom)
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        heartButton.tintColor = .systemPink
        heartButton.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        heartButton.tag = collectionView.tag * 1000 + indexPath.item
        heartButton.isSelected = bookmarkedMovies.contains(where: { $0 as AnyObject === movie as AnyObject })
        heartButton.addTarget(self, action: #selector(heartButtonTapped(_:)), for: .touchUpInside)
        cell.contentView.addSubview(heartButton)

        let titleLabel = UILabel(frame: CGRect(x: 0, y: cell.contentView.bounds.height - 55, width: cell.contentView.bounds.width, height: 60))
        titleLabel.text = movie.title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        cell.contentView.addSubview(titleLabel)
        cell.backgroundColor = UIColor.white

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width - 10 * 2) / 2
        let cellHeight = collectionView.bounds.height
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell selected at section \(collectionView.tag), item \(indexPath.item)")
        let selectedMovie: Movie

        switch collectionView.tag {
        case 0:
            selectedMovie = popularMoviesData[indexPath.item]
        case 1:
            selectedMovie = nowPlayingMoviesData[indexPath.item]
        case 2:
            selectedMovie = topRatedMoviesData[indexPath.item]
        case 3:
            selectedMovie = upcomingMoviesData[indexPath.item]
        default:
            return
        }
        print("\(selectedMovie.title)이 선택되었습니다.")

        if let movieDetailVC = storyboard?.instantiateViewController(withIdentifier: "MovieDetailVC") as? MovieDetailVC {
            movieDetailVC.selectedMovie = selectedMovie

            if let navigationController = navigationController {
                navigationController.pushViewController(movieDetailVC, animated: true)
            } else {
                present(movieDetailVC, animated: true, completion: nil)
            }
        }
    }

    func loadImage(for movie: Movie, into imageView: UIImageView) {
        if let posterPath = movie.posterPath {
            let posterURL = "https://image.tmdb.org/t/p/w500\(posterPath)"
            if let url = URL(string: posterURL) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }.resume()
            }
        }
    }
}

class Movie {
    let id: Int
    let title: String
    let posterPath: String?

    init(id: Int, title: String, posterPath: String?) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
    }
}
