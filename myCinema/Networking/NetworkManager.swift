//
//  NetworkManager.swift
//  myCinema
//
//  Created by t2023-m0028 on 1/19/24.
//

import UIKit

// 네트워크 요청 중 발생할 수 있는 에러 타입 정의
enum NetworkError: Error {
    case invalidURL
    case otherError(String)
    case parsingError
}

class NetworkManager {
    
    static let shared = NetworkManager() // 싱글톤 인스턴스

    private let apiKey = "a4da431c6791ead04a4fed52ad08e4fc"
    
    private init() {}

    // 영화 목록을 가져오는 메서드
    func fetchMovies(endpoint: String, completion: @escaping ([Movie]?, Error?) -> Void) {
        let urlString = "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil, NetworkError.invalidURL)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            guard let data = data, error == nil else {
                print("Error fetching movie data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, error)
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonArray = json as? [String: Any], let results = jsonArray["results"] as? [[String: Any]] {
                    let movies = self.parseMovieData(jsonArray: results)
                    completion(movies, nil)
                }
            } catch {
                print("Error parsing movie data: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }

    // JSON 데이터를 Movie 객체로 파싱하는 메서드
    private func parseMovieData(jsonArray: [[String: Any]]) -> [Movie] {
        var movies: [Movie] = []

        for movieData in jsonArray {
            do {
                let movie = try Movie(json: movieData)
                movies.append(movie)
            } catch {
                print("Error creating Movie object: \(error.localizedDescription)")
            }
        }

        return movies
    }

    // 이미지를 URL에서 가져오는 메서드
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            let image = UIImage(data: data)
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    // 출시일 정보를 가져오는 메서드
    func fetchReleaseDates(movieID: Int, completion: @escaping (String?) -> Void) {
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)/release_dates?api_key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching release dates: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let releaseDates = json as? [String: Any], let results = releaseDates["results"] as? [[String: Any]], let firstRelease = results.first, let releaseDatesArray = firstRelease["release_dates"] as? [[String: Any]], let firstReleaseDate = releaseDatesArray.first, let releaseDate = firstReleaseDate["release_date"] as? String {

                    // "T" 이후의 부분을 제외하고 표시
                    let formattedDate = releaseDate.components(separatedBy: "T").first ?? "Unknown Release Date"
                    completion(formattedDate)
                } else {
                    completion("Unknown Release Date")
                }
            } catch {
                print("Error parsing release dates: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    // 영화 세부 정보를 가져오는 메서드
    func fetchMovieDetails(movieID: Int, completion: @escaping ([String: Any]?, Error?) -> Void) {
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)?api_key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil, NetworkError.invalidURL)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching movie details: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, error)
                return
            }

            do {
                // JSON 데이터 파싱
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let movieDetails = json as? [String: Any] {
                    completion(movieDetails, nil)
                }
            } catch {
                print("Error parsing movie details: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }
}
