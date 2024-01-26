//
//  MovieListVC.swift
//  myCinema
//
//  Created by t2023-m0028 on 1/17/24.
//

import UIKit

class MovieListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
   
    let networkManager = NetworkManager.shared
    var tableView: UITableView!
    let sectionTitles = ["Popular Movies", "Now Playing", "Top Rated Movies", "Upcoming Movies"]
    var upcomingMoviesData: [Movie] = []
    var topRatedMoviesData: [Movie] = []
    var popularMoviesData: [Movie] = []
    var nowPlayingMoviesData: [Movie] = []
    var bookmarkedMovies: [Movie] = []

    // MARK: - Actions

    @objc func heartButtonTapped(_ sender: UIButton) {
        let section = sender.tag / 1000
        let item = sender.tag % 1000

        guard let selectedMovie = movieForIndexPath(section: section, item: item) else {
            return
        }

        if !bookmarkedMovies.contains(where: { $0.id == selectedMovie.id }) {
            bookmarkedMovies.append(selectedMovie)
            print("\(selectedMovie.title)이 관심영화 리스트에 담겼습니다.")
        } else {
            if let index = bookmarkedMovies.firstIndex(where: { $0.id == selectedMovie.id }) {
                bookmarkedMovies.remove(at: index)
                print("\(selectedMovie.title)이 관심영화 리스트에서 제거되었습니다.")
            }
        }

        sender.isSelected = !sender.isSelected
        updateHeartButton(sender, for: selectedMovie)
    }

    
    // MARK: - Data Fetching

    func fetchMovieData(endpoint: String, section: Int) {
        NetworkManager.shared.fetchMovies(endpoint: endpoint) { [weak self] movies, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching movies: \(error.localizedDescription)")
            } else if let movies = movies {
                DispatchQueue.main.async {
                    self.updateMoviesData(movies, forSection: section)
                    self.tableView.reloadData()

                    for movie in movies {
                        self.fetchMovieDetails(movieID: movie.id)
                    }
                }
            }
        }
    }

    func fetchMovieDetails(movieID: Int) {
        networkManager.fetchMovieDetails(movieID: movieID) { movieDetails, error in
            if let error = error {
                print("Error fetching movie details: \(error.localizedDescription)")
            } else if movieDetails != nil {
                // Handle movie details if needed
            }
        }
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        fetchMovieData(endpoint: "popular", section: 0)
        fetchMovieData(endpoint: "now_playing", section: 1)
        fetchMovieData(endpoint: "top_rated", section: 2)
        fetchMovieData(endpoint: "upcoming", section: 3)
    }

    // MARK: - UITableViewDataSource

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

        let collectionView = configureCollectionView(in: cell.contentView, layout: collectionViewLayout, forSection: indexPath.section)
        cell.contentView.addSubview(collectionView)

        return cell
    }

    // MARK: - UITableViewDelegate

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

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moviesData(forSection: collectionView.tag).count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCellIdentifier\(collectionView.tag)", for: indexPath)

        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }

        let movie = movieForIndexPath(section: collectionView.tag, item: indexPath.item)

        let imageView = configureImageView(in: cell.contentView, forMovie: movie)
        cell.contentView.addSubview(imageView)

        let heartButton = configureHeartButton(in: cell.contentView, forMovie: movie, atIndexPath: indexPath)
        cell.contentView.addSubview(heartButton)

        let titleLabel = configureTitleLabel(in: cell.contentView, forMovie: movie)
        cell.contentView.addSubview(titleLabel)

        cell.backgroundColor = UIColor.white

        return cell
    }

    // MARK: - UICollectionViewDelegate

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
        guard let selectedMovie = movieForIndexPath(section: collectionView.tag, item: indexPath.item) else {
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

    // MARK: - Helper Methods

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
        view.addSubview(tableView)
    }

    private func configureCollectionView(in view: UIView, layout: UICollectionViewFlowLayout, forSection section: Int) -> UICollectionView {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.tag = section
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCellIdentifier\(collectionView.tag)")
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }

    private func configureImageView(in view: UIView, forMovie movie: Movie?) -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: view.bounds.width - 20, height: view.bounds.height - 60))
        loadImage(for: movie, into: imageView)
        return imageView
    }

    private func configureHeartButton(in view: UIView, forMovie movie: Movie?, atIndexPath indexPath: IndexPath) -> UIButton {
        let heartButton: UIButton

        if let existingButton = view.viewWithTag(indexPath.item) as? UIButton {
            heartButton = existingButton
        } else {
            heartButton = UIButton(type: .custom)
            heartButton.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
            heartButton.tag = indexPath.item
            heartButton.addTarget(self, action: #selector(heartButtonTapped(_:)), for: .touchUpInside)
            view.addSubview(heartButton)
        }

        heartButton.isSelected = bookmarkedMovies.contains(where: { $0.id == movie?.id })
        updateHeartButton(heartButton, for: movie)

        return heartButton
    }


    private func configureTitleLabel(in view: UIView, forMovie movie: Movie?) -> UILabel {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: view.bounds.height - 55, width: view.bounds.width, height: 60))
        titleLabel.text = movie?.title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        return titleLabel
    }

    private func updateMoviesData(_ movies: [Movie], forSection section: Int) {
        switch section {
        case 0: popularMoviesData = movies
        case 1: nowPlayingMoviesData = movies
        case 2: topRatedMoviesData = movies
        case 3: upcomingMoviesData = movies
        default: break
        }
    }

    private func moviesData(forSection section: Int) -> [Movie] {
        switch section {
        case 0: return popularMoviesData
        case 1: return nowPlayingMoviesData
        case 2: return topRatedMoviesData
        case 3: return upcomingMoviesData
        default: return []
        }
    }

    private func movieForIndexPath(section: Int, item: Int) -> Movie? {
        let movies = moviesData(forSection: section)
        guard item < movies.count else {
            return nil
        }
        return movies[item]
    }

    private func updateHeartButton(_ button: UIButton, for movie: Movie?) {
        let heartImageName = button.isSelected ? "heart.fill" : "heart"
        let heartImage = UIImage(systemName: heartImageName)?.withRenderingMode(.alwaysTemplate)
        button.setImage(heartImage, for: .normal)
        button.tintColor = button.isSelected ? .systemRed : .white
    }

    private func loadImage(for movie: Movie?, into imageView: UIImageView) {
        guard let posterPath = movie?.posterPath else {
            return
        }
        let posterURL = "https://image.tmdb.org/t/p/w500\(posterPath)"
        networkManager.loadImage(from: posterURL) { image in
            imageView.image = image
        }
    }
}
