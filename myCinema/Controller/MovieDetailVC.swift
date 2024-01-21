//
//  MovieDetailVC.swift
//  myCinema
//
//  Created by t2023-m0028 on 1/17/24.
//

import UIKit

class MovieDetailVC: UIViewController {
    
    let networkManager = NetworkManager.shared
    var selectedMovie: Movie?
    
    // 세부 정보 텍스트뷰
    let detailTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textAlignment = .center
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    // 출시일 정보를 표시하는 레이블
    let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
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
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor(hex: "0x6aa3ff")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // API 데이터를 이용한 영화 세부 정보 텍스트뷰
        view.addSubview(detailTextView)
        
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
            posterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            posterImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            posterImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            posterImageView.heightAnchor.constraint(equalToConstant: 350),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleLabel.heightAnchor.constraint(equalToConstant: 60),
            
            detailTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            detailTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            detailTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            detailTextView.heightAnchor.constraint(lessThanOrEqualToConstant: 160),
            
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
            
            // 영화 세부 정보를 가져와서 ddetailTextView 업데이트
            fetchMovieDetails(movieID: selectedMovie.id)
            
            // 출시일 정보를 가져와서 releaseDateLabel 업데이트
            fetchReleaseDates(movieID: selectedMovie.id)
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
        networkManager.fetchMovieDetails(movieID: movieID) { [weak self] movieDetails, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching movie details: \(error.localizedDescription)")
                return
            }

            if let overview = movieDetails?["overview"] as? String { // 변경된 부분
                DispatchQueue.main.async {
                    self.detailTextView.text = overview
                }
            }
        }
    }
    
    // 출시일 정보를 가져오는 메서드
    func fetchReleaseDates(movieID: Int) {
        networkManager.fetchReleaseDates(movieID: movieID) { [weak self] releaseDate in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.displayReleaseDate(releaseDate: releaseDate)
            }
        }
    }
    
    // 출시일 정보를 UI에 표시하는 메서드
    func displayReleaseDate(releaseDate: String?) {
        releaseDateLabel.text = "출시일: \(releaseDate ?? "Unknown Release Date")"
    }
    // 영화 포스터 이미지를 가져와서 이미지 뷰에 설정하는 메서드
    func loadImage(for movie: Movie, into imageView: UIImageView) {
        if let posterPath = movie.posterPath {
            let posterURL = "https://image.tmdb.org/t/p/w500\(posterPath)"
            
            networkManager.loadImage(from: posterURL) { [weak self] image in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
}
