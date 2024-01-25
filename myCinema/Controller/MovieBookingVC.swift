//
//  MovieBookingVC.swift
//  myCinema
//
//  Created by t2023-m0028 on 1/17/24.
//
import UIKit

class MovieBookingVC: UIViewController {
    
    // UIAlertController를 클래스 레벨에 선언
    private var alertController: UIAlertController?
    // 상영시간 목록을 담을 배열
    let showingTimes = ["0:00" ,"6:00", "10:00", "13:00", "16:00", "19:00", "22:00"]
    // 영화명을 표시할 라벨
    var titleLabel: UILabel!
    // 선택된 상영시간을 표시할 라벨
    var selectedTimeLabel: UILabel!
    // 보여줄 인원 수를 표시할 라벨
    var numberOfPeopleLabel: UILabel!
    // 인원수 추가 Stepper
    var stepper: UIStepper!
    // 선택된 영화 데이터
    var selectedMovie: Movie?
    // 사용자가 입력한 예매 정보
    var selectedTime: String = ""
    var selectedDate: String = ""
    var numberOfPeople: Int = 0
    var totalPrice: Double = 0.0
    // 결제할 금액을 표시할 라벨
    var priceLabel: UILabel!
    // DateFormatter를 클래스 레벨에 선언
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd EEE"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 화면 초기 설정
        setupUI()
        
        // 스테퍼 초기값 설정 및 초기 UI 업데이트
        stepper.value = 1
        stepperValueChanged()
        
        // 선택된 영화 데이터를 기반으로 UI 업데이트
        if let selectedMovie = selectedMovie {
            titleLabel.text = selectedMovie.title
        }
    }
    
    // 화면 초기 설정 함수
    func setupUI() {
        // 예매하기 타이틀 추가
        let bookingLabel = UILabel()
        bookingLabel.text = "예매하기"
        bookingLabel.textColor = UIColor(hex: "0x6aa3ff")
        bookingLabel.font = UIFont.boldSystemFont(ofSize: 30)
        bookingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bookingLabel)
        
        // 영화명 레이블
        let titleNameLabel = UILabel()
        titleNameLabel.text = "영화명"
        titleNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleNameLabel)
        
        // 선택된 영화명
        titleLabel = UILabel()
        titleLabel.text = selectedMovie?.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .right
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // 인원 수를 보여줄 라벨
        numberOfPeopleLabel = UILabel()
        numberOfPeopleLabel.text = "1명"
        numberOfPeopleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        numberOfPeopleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(numberOfPeopleLabel)
        
        // 결제할금액을 보여줄 라벨
        priceLabel = UILabel()
        priceLabel.text = "8000원"
        priceLabel.font = UIFont.boldSystemFont(ofSize: 20)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(priceLabel)
        
        // Stepper 설정
        stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 100
        stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        stepper.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stepper)
        
        // DatePicker 초기 설정
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date() // 오늘 날짜로 설정
        datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        datePicker.date = Date()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        view.addSubview(datePicker)
        datePickerValueChanged(datePicker)
        
        // 상영시간을 표시할 라벨 추가
        selectedTimeLabel = UILabel()
        selectedTimeLabel.font = UIFont.boldSystemFont(ofSize: 20)
        selectedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectedTimeLabel)
        
        // 버튼 추가 (상영시간 선택 버튼)
        let selectTimeButton = UIButton()
        selectTimeButton.setTitle("  상영시간 선택  ", for: .normal)
        selectTimeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        selectTimeButton.setTitleColor(.black, for: .normal)
        selectTimeButton.backgroundColor = UIColor(hex: "f0f1f2")
        selectTimeButton.layer.cornerRadius = 10
        selectTimeButton.layer.masksToBounds = true
        selectTimeButton.addTarget(self, action: #selector(selectTimeButtonTapped), for: .touchUpInside)
        selectTimeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectTimeButton)
        
        let dateLabel = UILabel()
        dateLabel.text = "상영일"
        dateLabel.font = UIFont.boldSystemFont(ofSize: 20)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateLabel)
        
        let timeLabel = UILabel()
        timeLabel.text = "상영시간"
        timeLabel.font = UIFont.boldSystemFont(ofSize: 20)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeLabel)
        
        let peopleLabel = UILabel()
        peopleLabel.text = "인원"
        peopleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        peopleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(peopleLabel)
        
        let totalPriceLabel = UILabel()
        totalPriceLabel.text = "총 가격"
        totalPriceLabel.font = UIFont.boldSystemFont(ofSize: 20)
        totalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalPriceLabel)
        
        // 결제하기 버튼 추가
        let payButton = UIButton()
        payButton.setTitle("결제하기", for: .normal)
        payButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        payButton.tintColor = .white
        payButton.backgroundColor = UIColor(hex: "0x6aa3ff")
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        payButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(payButton)
        
        
        // 영화 정보 입력 항목을 수직으로 나열하기
        let stackView = UIStackView(arrangedSubviews: [titleNameLabel, dateLabel, timeLabel, peopleLabel, totalPriceLabel])
        stackView.axis = .vertical
        stackView.spacing = 70
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            bookingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            bookingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: bookingLabel.bottomAnchor, constant: 80),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            payButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            payButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            payButton.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: stackView.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 80),
            
            stepper.centerYAnchor.constraint(equalTo: peopleLabel.centerYAnchor),
            stepper.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            numberOfPeopleLabel.centerYAnchor.constraint(equalTo: peopleLabel.centerYAnchor),
            numberOfPeopleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            priceLabel.centerYAnchor.constraint(equalTo: totalPriceLabel.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            datePicker.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            selectedTimeLabel.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            selectedTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            selectTimeButton.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            selectTimeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc func selectTimeButtonTapped() {
        // 상영시간 선택을 위한 액션 시트 표시
        let alertController = UIAlertController(title: "상영시간을 선택해주세요", message: nil, preferredStyle: .actionSheet)
        
        for time in showingTimes {
            let action = UIAlertAction(title: time, style: .default) { [weak self] _ in
                self?.selectedTime = time
                // 옵셔널 체이닝을 사용하여 값이 있는 경우에만 설정
                if let selectedTime = self?.selectedTime {
                    self?.selectedTimeLabel.text = selectedTime
                    print("상영시간을 \(selectedTime)으로 선택하셨습니다")
                } else {
                    print("상영시간이 선택되지 않았습니다")
                }
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // 액션 시트 표시
        present(alertController, animated: true, completion: nil)
    }
    
    // 날짜 선택 이벤트 처리
    @objc func datePickerValueChanged(_ datePicker: UIDatePicker) {
        let selectedDate = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd EEE"
        self.selectedDate = dateFormatter.string(from: selectedDate)
        print("상영일을 \(self.selectedDate)으로 선택하셨습니다")
    }
    
    // 스테퍼 값이 변경되었을 때 호출되는 메서드
    @objc func stepperValueChanged() {
        let newNumberOfPeople = Int(stepper.value)
        numberOfPeople = newNumberOfPeople  // numberOfPeople 업데이트
        numberOfPeopleLabel.text = "\(newNumberOfPeople)명"
        priceLabel.text = "\(newNumberOfPeople*8000)원"
        
        // 스테퍼 값이 1 미만인 경우 경고창 표시
        if newNumberOfPeople < 1 {
            let alert = UIAlertController(title: "경고", message: "1명 이상의 인원수가 필요합니다.", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(confirmAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    // 결제하기 버튼을 눌렀을 때 호출되는 메서드
    @objc func payButtonTapped() {
        guard !selectedTime.isEmpty else {
            let alert = UIAlertController(title: "경고", message: "상영시간을 선택해주세요.", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(confirmAction)
            present(alert, animated: true, completion: nil)
            return
        }
        // 결제 버튼을 누를 때 스테퍼 값이 1 미만인 경우 경고창 표시
        if numberOfPeople < 1 {
            let alert = UIAlertController(title: "경고", message: "1명 이상의 인원수가 필요합니다.", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(confirmAction)
            present(alert, animated: true, completion: nil)
        } else {
            // 정상적인 결제 로직 수행
            let alertController = UIAlertController(title: "결제 확인", message: "영화명: \(self.titleLabel.text ?? "")\n상영일: \(self.selectedDate)\n상영시간: \(self.selectedTime)\n인원: \(self.numberOfPeople)\n총 가격: \(self.priceLabel.text ?? "") \n정말 결제하시겠습니까?", preferredStyle: .alert)
            // 확인 액션 추가
            let confirmAction = UIAlertAction(title: "결제하기", style: .default) { [weak self] _ in
                // 결제 정보 출력 및 MovieListVC로 돌아가기
                if let self = self {
                    print("결제가 완료되었습니다. 영화명: \(self.titleLabel.text ?? ""), 상영일: \(self.selectedDate) 상영시간: \(self.selectedTime) 인원: \(self.numberOfPeople), 총 가격: \(self.priceLabel.text ?? "")")
                    
                    // MovieListVC로 돌아가기
                    if let tabBarController = self.tabBarController,
                       let navigationController = tabBarController.selectedViewController as? UINavigationController,
                       let movieListVC = navigationController.viewControllers.compactMap({ $0 as? MovieListVC }).first {
                        self.navigationController?.popToViewController(movieListVC, animated: true)
                    }
                }
            }
            // 확인 액션을 alertController에 추가
            alertController.addAction(confirmAction)
            // 알림창 표시
            present(alertController, animated: true, completion: nil)
        }
    }
}
// PickerView Delegate 및 DataSource 구현
extension MovieBookingVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // 1개의 열(column)을 가진다.
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return showingTimes.count // 상영시간의 항목 수를 반환
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return showingTimes[row] // 각 row에 표시할 상영시간을 반환
    }
}
