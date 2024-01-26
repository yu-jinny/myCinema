import UIKit

class LoginVC: UIViewController {

    let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "아이디"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인", for: .normal)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()

    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원가입", for: .normal)
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)

        setupLayout()
    }

    func setupLayout() {
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            signUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func loginButtonTapped() {
        // 사용자가 입력한 정보 가져오기
        guard let username = usernameTextField.text,
              let password = passwordTextField.text else {
            print("아이디와 비밀번호를 입력해주세요.")
            return
        }

        // 저장된 사용자 정보 불러오기
        if let savedUser = UserDefaultsManager.shared.loadUserInfo() {
            // 입력한 정보와 저장된 정보 비교
            if username == savedUser.username && password == savedUser.password {
                // 로그인이 성공하면 사용자 이름을 가져와서 알림창에 표시
                let alertController = UIAlertController(
                    title: "로그인 성공",
                    message: "\(savedUser.name) 님, 반갑습니다.",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                    // MovieListVC를 초기화
                    let movieListVC = MovieListVC()

                    // 네비게이션 컨트롤러가 존재하는지 확인
                    if let navigationController = self.navigationController {
                        // 네비게이션 스택에 MovieListVC를 추가
                        navigationController.pushViewController(movieListVC, animated: true)
                    } else {
                        // 네비게이션 컨트롤러가 없다면 새로 생성하여 rootViewController로 설정
                        let navigationController = UINavigationController(rootViewController: movieListVC)
                        navigationController.modalPresentationStyle = .fullScreen
                        self.present(navigationController, animated: true, completion: nil)
                    }
                })
                present(alertController, animated: true, completion: nil)
            } else {
                print("아이디 또는 비밀번호가 일치하지 않습니다.")
            }
        } else {
            print("등록된 사용자 정보가 없습니다.")
        }
    }



    @objc func signUpButtonTapped() {
        let joinVC = JoinVC()
        navigationController?.pushViewController(joinVC, animated: true)
    }
}
