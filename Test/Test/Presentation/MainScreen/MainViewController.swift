import UIKit

protocol IMainScreenView: AnyObject {
    /// Update view with a new state
    /// - Parameter state: updated state
    func update(withState state: MainScreenViewController.State)
}

class MainScreenViewController: UIViewController {

    enum Constants {
        static let rowHeight: CGFloat = 200
    }

    enum State {
        case empty
        case error(MainScreenError)
        case loaded([MainCellConfig])
        case loading
    }

    // Dependencies
    private let presenter: IMainScreenPresenter

    // UI
    private lazy var textField = makeTextField()
    private lazy var tableView = makeTableView()
    private lazy var messageLabel = makeMessageLabel()

    // Properties
    private var currentState: State = .empty
    private var configs: [MainCellConfig] = []

    init(presenter: IMainScreenPresenter) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
}

private extension MainScreenViewController {

    func makeTableView() -> UITableView {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(MainScreenCell.self, forCellReuseIdentifier: MainScreenCell.reuseIdentifier)
        table.isHidden = true
        table.rowHeight = Constants.rowHeight
        table.separatorStyle = .none
        return table
    }

    func makeTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter text and press Done"
        textField.delegate = self
        textField.returnKeyType = .done
        return textField
    }

    func makeMessageLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.text = "Enter text above and press Done on the keyboard to show result"
        label.textAlignment = .center
        return label
    }

    func makeMessageView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func setupUI() {
        let messageView = makeMessageView()

        view.backgroundColor = .white
        view.addSubview(messageView)
        messageView.addSubview(messageLabel)
        view.addSubview(textField)
        view.addSubview(tableView)

        textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true

        tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        messageView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16).isActive = true
        messageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        messageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        messageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        messageLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: 16).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -16).isActive = true
        messageLabel.centerYAnchor.constraint(equalTo: messageView.centerYAnchor).isActive = true

        textField.becomeFirstResponder()
    }

    private func showSkeletons() {

    }

    private func showData(_ data: [MainCellConfig]) {
        configs = data
        tableView.isHidden = false
        tableView.reloadData()
    }

    private func showError(_ error: MainScreenError) {
        tableView.isHidden = true
        messageLabel.text = error.text
    }
}

extension MainScreenViewController: UITableViewDelegate {

}

extension MainScreenViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        configs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard 
            let cell = tableView.dequeueReusableCell(withIdentifier: MainScreenCell.reuseIdentifier) as? MainScreenCell
        else {
            return UITableViewCell()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? MainScreenCell else { return }

        let config = configs[indexPath.row]

        presenter.willDisplay(cell: cell, withConfig: config)
    }
}

// MARK: - UITextFieldDelegate

extension MainScreenViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }

        presenter.onTextFieldDidChange(with: text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return false
    }
}

// MARK: - IMainScreenView

extension MainScreenViewController: IMainScreenView {
    
    func update(withState state: State) {
        switch state {
        case .empty:
            break
        case .error(let error):
            showError(error)
        case .loading:
            showSkeletons()
        case .loaded(let configs):
            showData(configs)
        }
    }
}
