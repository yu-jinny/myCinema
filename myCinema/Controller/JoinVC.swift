import UIKit

class JoinVC: UIViewController {
    
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
    
    let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호 확인"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이름"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let birthdateTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "생년월일 (8자리)"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원가입", for: .normal)
        button.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(nameTextField)
        view.addSubview(birthdateTextField)
        view.addSubview(joinButton)
        
        setupLayout()
    }
    
    func setupLayout() {
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        birthdateTextField.translatesAutoresizingMaskIntoConstraints = false
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            nameTextField.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            birthdateTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            birthdateTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            birthdateTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            joinButton.topAnchor.constraint(equalTo: birthdateTextField.bottomAnchor, constant: 20),
            joinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func joinButtonTapped() {
        guard let username = usernameTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              let name = nameTextField.text,
              let birthdate = birthdateTextField.text else {
            showAlert(message: "모든 정보를 입력해주세요.")
            return
        }
        
        if password != confirmPassword {
            showAlert(message: "비밀번호가 일치하지 않습니다.")
            return
        }
        
        if birthdate.count != 8 {
            showAlert(message: "생년월일이 올바르게 입력되지 않았습니다. 다시 한번 확인해주세요.")
            return
        }
        
        // 아이디 중복 체크
        if isUsernameDuplicate(username: username) {
            showAlert(message: "이미 사용 중인 아이디입니다.")
            return
        }
        
        let user = User(username: username, password: password, name: name, birthdate: birthdate)
        UserDefaultsManager.shared.saveUserInfo(user: user)
        
        print("회원가입 완료!")
    }
    
    // 아이디 중복 체크 함수
    func isUsernameDuplicate(username: String) -> Bool {
        // UserDefaults에 저장된 아이디 목록을 가져옴
        let savedUsernames = UserDefaultsManager.shared.getSavedUsernames()
        
        // 현재 입력한 아이디가 이미 저장된 아이디 목록에 있는지 확인
        return savedUsernames.contains(username)
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(
            title: "알림",
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
