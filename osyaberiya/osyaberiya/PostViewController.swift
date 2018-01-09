//
//  ViewController.swift
//  osyaberiya
//
//  Created by koooootake on 2017/12/16.
//  Copyright © 2017年 koooootake. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {
    
    let indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var osyaberiButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //テキストViewレイアウト
        textView.textContainerInset = UIEdgeInsetsMake(20, 10, 20, 10)
        textView.sizeToFit()
        textView.text = "楽しくおしゃべりしよう！"
        textView.returnKeyType = .done
        textView.delegate = self
        countLabel.text = "\(textView.text.count)/\(UtilModel.maxTextCount)"
        
        //ボタンレイアウト
        LayoutViewModel.dropShadow(view: osyaberiButton)
        LayoutViewModel.dropShadow(view: clearButton)
        
        //くるくるレイアウト
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.center = self.view.center
        indicator.color = UIColor.white
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
        self.view.bringSubview(toFront: indicator)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //キーボード立ち上げ
        textView.becomeFirstResponder()
    }

    func textValidation() -> Bool {
        if textView.text.count < 1 || textView.text.count > UtilModel.maxTextCount {
            let alertController = UIAlertController(title: "0 < 文字数 < 100", message: "にしてください🙏", preferredStyle: .alert)
            let action = UIAlertAction(title: UtilModel.okMessage, style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.textView.becomeFirstResponder()
                }
            })
            alertController.addAction(action)
            self.present(alertController, animated: true, completion:nil)
            return false
        }
        return true
    }
    
    @IBAction func sendText(_ sender: Any) {
        //キーボードを閉じる
        textView.resignFirstResponder()
        
        LayoutViewModel.buttonAnimation(button: osyaberiButton)
        
        guard textValidation() else {
            return
        }
        
        //くるくるstart
        indicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        PostViewModel.post(text: textView.text, completion: { (isSucsess, title, message) in
            //くるくるstop
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            
            if isSucsess {
                DispatchQueue.main.async {
                    //画面遷移
                    let storyboard: UIStoryboard = self.storyboard!
                    let resultViewController = storyboard.instantiateViewController(withIdentifier: "ResultViewController")
                    self.present(resultViewController, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController.show(title: title, message: message)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func clearText(_ sender: Any) {
        textView.text = ""
        countLabel.text = "\(textView.text.count)/\(UtilModel.maxTextCount)"
    }
    
}

extension PostViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        countLabel.text = "\(textView.text.count)/\(UtilModel.maxTextCount)"
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = textView.text + string
        if text.count > UtilModel.maxTextCount {
            return false
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        //改行とじる
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
