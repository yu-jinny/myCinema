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

    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이름"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let birthdateTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "생년월일"
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
        view.addSubview(nameTextField)
        view.addSubview(birthdateTextField)
        view.addSubview(joinButton)

        setupLayout()
    }

    func setupLayout() {
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
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

            nameTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
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
        print("회원가입 버튼이 눌렸습니다.")
        // 여기에 실제 회원가입 로직을 구현하면 됩니다.
    }
}
