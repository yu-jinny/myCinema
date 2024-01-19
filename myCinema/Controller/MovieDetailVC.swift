//
//  MovieDetailVC.swift
//  myCinema
//
//  Created by t2023-m0028 on 1/17/24.
//

import UIKit

class MovieDetailVC: UIViewController {
    
    var selectedMovie: Movie?
    
    // 세부 정보 레이블
    let detailsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 출시일 정보를 표시하는 레이블
    let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true

        view.backgroundColor = .white
        
        // 영화 포스터 이미지 뷰
        let posterImageView = UIImageView()
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(posterImageView)
        
        // 영화 타이틀 레이블
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = UIColor(hex: "0x6aa3ff")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // API 데이터를 이용한 영화 세부 정보 레이블
        view.addSubview(detailsLabel)
        
        // Rated 정보를 UI에 표시하는 레이블
        //view.addSubview(ratedInfoLabel)
        
        // 출시일 정보를 표시하는 레이블
        view.addSubview(releaseDateLabel)
        
        // 예매하기 버튼
        let bookButton = UIButton(type: .system)
        bookButton.setTitle("예매하기", for: .normal)
        bookButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        bookButton.tintColor = .white
        bookButton.backgroundColor = UIColor(hex:"0x6aa3ff")
        bookButton.translatesAutoresizingMaskIntoConstraints = false
        bookButton.addTarget(self, action: #selector(bookButtonTapped), for: .touchUpInside)
        view.addSubview(bookButton)
        
        // NSLayoutConstraint를 이용하여 레이아웃 설정
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            posterImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            posterImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            posterImageView.heightAnchor.constraint(equalToConstant: 350),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            detailsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            detailsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
        
            bookButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bookButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bookButton.widthAnchor.constraint(equalTo: view.widthAnchor),
            bookButton.heightAnchor.constraint(equalToConstant: 60),
            
            releaseDateLabel.bottomAnchor.constraint(equalTo: bookButton.topAnchor, constant: -10),
            releaseDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ])
        
        // 선택된 영화 데이터를 기반으로 UI 업데이트
                if let selectedMovie = selectedMovie {
                    titleLabel.text = selectedMovie.title

                    // 영화 포스터 이미지 로드
                    loadImage(for: selectedMovie, into: posterImageView)
                    
                    // 영화 세부 정보를 가져와서 detailsLabel 업데이트
                    fetchMovieDetails(movieID: selectedMovie.id)
        }
    }
    
    // 예매하기 버튼이 눌렸을 때 동작하는 메서드
    @objc func bookButtonTapped() {
        print("예매하기 버튼이 눌렸습니다.")
        
        // MovieBookingVC의 인스턴스를 생성
        if let movieBookingVC = storyboard?.instantiateViewController(withIdentifier: "MovieBookingVC") as? MovieBookingVC {
            movieBookingVC.selectedMovie = selectedMovie
            // 현재 뷰 컨트롤러가 네비게이션 컨트롤러에 내장되어 있다면 push, 아니면 present
            if let navigationController = navigationController {
                navigationController.pushViewController(movieBookingVC, animated: true)
            } else {
                present(movieBookingVC, animated: true, completion: nil)
            }
        }
    }

    
    // 영화 세부 정보를 가져오는 메서드
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
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let movieDetails = json as? [String: Any] {
                    if let overview = movieDetails["overview"] as? String {
                        DispatchQueue.main.async {
                            self.detailsLabel.text = overview
                        }
                    }
                }
            } catch {
                print("Error parsing movie details: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // 영화 포스터 이미지 로드
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
                        // 영화 포스터 이미지 로드 이후에 출시일 정보를 가져오도록 이동
                        self.fetchReleaseDates(movieID: movie.id)
                    }
                }.resume() // 이 부분을 추가하세요
            }
        }
    }
    
    // 출시일 정보를 가져오는 메서드
    func fetchReleaseDates(movieID: Int) {
        let apiKey = "a4da431c6791ead04a4fed52ad08e4fc"
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)/release_dates?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching release dates: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let releaseDates = json as? [String: Any], let results = releaseDates["results"] as? [[String: Any]], let firstRelease = results.first, let releaseDatesArray = firstRelease["release_dates"] as? [[String: Any]], let firstReleaseDate = releaseDatesArray.first, let releaseDate = firstReleaseDate["release_date"] as? String {
                    
                    // "T" 이후의 부분을 제외하고 표시
                    let formattedDate = releaseDate.components(separatedBy: "T").first ?? "Unknown Release Date"
                    
                    DispatchQueue.main.async {
                        // 출시일 정보를 UI에 표시
                        self.displayReleaseDate(releaseDate: formattedDate)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.displayReleaseDate(releaseDate: "Unknown Release Date")
                    }
                }
            } catch {
                print("Error parsing release dates: \(error.localizedDescription)")
            }
        }.resume()
    }

            // 출시일 정보를 UI에 표시하는 메서드
            func displayReleaseDate(releaseDate: String) {
                DispatchQueue.main.async {
                    self.releaseDateLabel.text = "출시일: \(releaseDate)"
                }
            }
        }
