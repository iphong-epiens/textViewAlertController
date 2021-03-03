//
//  ViewController.swift
//  textViewAlert
//
//  Created by Inpyo Hong on 2021/03/02.
//

import UIKit
import RxSwift
import RxCocoa
import RxAlertController
import KMPlaceholderTextView

class ViewController: UIViewController {
    @IBOutlet weak var modalBtn: UIButton!
    
    let disposeBag = DisposeBag()
    let textView: KMPlaceholderTextView = KMPlaceholderTextView(frame: CGRect.zero)
    var textViewAlertController: UIAlertController!
    var textViewHeight: CGFloat = 50
    var textViewTitlePadding = "\n\n"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configTextView()
        
        print(UIScreen.main.bounds)
        
        self.modalBtn.rx.tap
            .subscribe(onNext: {
                self.textViewPopup()
            }).disposed(by: self.disposeBag)
    }

    func configTextView() {
        let deviceFrame = UIScreen.main.bounds
        
        if deviceFrame.width <= 375 {
            self.textViewHeight = 50
            self.textViewTitlePadding = "\n\n"
        }
        else {
            self.textViewHeight = 90
            self.textViewTitlePadding = "\n\n\n\n"
        }
    }
    
    func textViewPopup() {
        let textViewTitle = "자주 사용하는 메세지 편집" + self.textViewTitlePadding
        self.textViewAlertController = UIAlertController(title: textViewTitle, message: nil, preferredStyle: .alert)

        self.textViewAlertController.view.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.new, context: nil)
        self.textView.backgroundColor = UIColor.white
        self.textView.textContainerInset = UIEdgeInsets.init(top: 8, left: 5, bottom: 8, right: 5)
        self.textView.layer.borderWidth = 1
        self.textView.layer.borderColor = UIColor.lightGray.cgColor
        self.textView.layer.cornerRadius = 4
        self.textView.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        self.textView.placeholder = (NSString("내용을 입력해주세요.")) as String
        self.textView.placeholderColor = UIColor.lightGray
        self.textView.text = "기존에 입력된 글자입니다."
        self.textView.delegate = self
        self.textViewAlertController.view.addSubview(self.textView)
        
        self.textViewAlertController.rx.show(in: self, buttonTitles: ["Cancel", "OK"])
            .subscribe(onSuccess: { index in
                print("Selected option #\(index)")
                
                switch index {
                case 0: //cancel
                    self.textViewAlertController.view.removeObserver(self, forKeyPath: "bounds")

                case 1: //ok
                    let enteredText = self.textView.text as String
                    self.textViewAlertController.view.removeObserver(self, forKeyPath: "bounds")
                    
                    print("enteredText", enteredText)
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds"{
            if let rect = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgRectValue {
                let margin: CGFloat = 4
                let xPos = rect.origin.x + margin
                let yPos = rect.origin.y + 54
                let width = rect.width - 2 * margin
                let height: CGFloat = self.textViewHeight

                textView.frame = CGRect.init(x: xPos, y: yPos, width: width, height: height)
            }
        }
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.endEditing(true)
    }
}
