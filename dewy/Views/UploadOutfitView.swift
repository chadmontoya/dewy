import UIKit

class ViewController: UIViewController {
    
    private let slideUpView = UIView()
    private let closeButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let mainButton = UIButton(type: .system)
        mainButton.setTitle("show view", for: .normal)
        mainButton.addTarget(self, action: #selector(showSlideUpView), for: .touchUpInside)
        mainButton.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        mainButton.center = view.center
        view.addSubview(mainButton)
        
        slideUpView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 300)
        slideUpView.backgroundColor = .lightGray
        view.addSubview(slideUpView)
        
        closeButton.setTitle("X", for: .normal)
        closeButton.addTarget(self, action: #selector(hideSlideUpView), for: .touchUpInside)
        closeButton.frame = CGRect(x: slideUpView.frame.width - 50, y: 10, width: 40, height: 40)
        closeButton.setTitleColor(.black, for: .normal)
        slideUpView.addSubview(closeButton)
    }
    
    @objc private func showSlideUpView() {
        UIView.animate(withDuration: 0.3) {
            self.slideUpView.frame.origin.y = self.view.frame.height - 300
        }
    }
    
    @objc private func hideSlideUpView() {
        UIView.animate(withDuration: 0.3) {
            self.slideUpView.frame.origin.y = self.view.frame.height
        }
    }
}
