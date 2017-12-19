//
//  ViewController.swift
//  osyaberiya
//
//  Created by koooootake on 2017/12/16.
//  Copyright © 2017年 koooootake. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {
    
    let indicator = UIActivityIndicatorView()
    let errorMessage = "@osyaberiyaまでお問い合わせください"
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    var text: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.textContainerInset = UIEdgeInsetsMake(20, 10, 20, 10)
        textView.sizeToFit()
        textView.text = "おしゃべりやです"
        textView.returnKeyType = .done
        textView.delegate = self
        countLabel.text = "\(textView.text.count)/99"
        
        //くるくる設定
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.center = self.view.center
        indicator.color = UIColor.white
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
        self.view.bringSubview(toFront: indicator)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        countLabel.text = "\(textView.text.count)/99"
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = textView.text + string
        if text.count > 99 {
            return false
        }
        return true
    }
    
    //改行とじる
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textValidation() -> Bool {
        if textView.text.count < 1 || textView.text.count > 99 {
            let alert = UIAlertController.show(title: "0 < 文字 < 100 に\nしてください", message: "")
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    @IBAction func sendText(_ sender: Any) {
        textView.resignFirstResponder()
        
        if !textValidation() {
            return
        }
        
        let inputText = textView.text
        
        let param = [
            "input" : inputText
        ]
        
        guard let url = URL(string: "http://osyaberiya.com/generate") else {
            let alert = UIAlertController.show(title: "URLが無効です", message: errorMessage)
            self.present(alert, animated: true, completion: nil)
            print("Error URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        } catch {
            let alert = UIAlertController.show(title: "テキストが無効です", message: errorMessage)
            self.present(alert, animated: true, completion: nil)
            print("Error JSONSerialization : ", error.localizedDescription)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            //くるくるstop
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            
            if let error = error {
                let alert = UIAlertController.show(title: "通信に失敗しました", message: "")
                self.present(alert, animated: true, completion: nil)
                print("Error session: \(error)")
                return
            }
            
            guard let data = data else {
                let alert = UIAlertController.show(title: "動画の生成に失敗しました", message: "繰り返し失敗する場合は\n\(self.errorMessage)")
                self.present(alert, animated: true, completion: nil)
                print("Error data")
                return
            }
            
            let decoder: JSONDecoder = JSONDecoder()
            do {
                let result: Result = try decoder.decode(Result.self, from: data)
                VideoModel.shared.set(fileName: result.filename, filePath: result.video_url)
                print("Sucsess session :",result)
                
                DispatchQueue.main.async {
                    //画面遷移
                    let storyboard: UIStoryboard = self.storyboard!
                    let resultViewController = storyboard.instantiateViewController(withIdentifier: "ResultViewController")
                    self.present(resultViewController, animated: true, completion: nil)
                }
                
            } catch {
                let alert = UIAlertController.show(title: "動画の読み込みに失敗しました", message: "繰り返し失敗する場合は\n\(self.errorMessage)")
                self.present(alert, animated: true, completion: nil)
                print("Error decode")
            }
        })
        
        task.resume()
        //くるくるstart
        indicator.startAnimating()
    }
    
    @IBAction func clearText(_ sender: Any) {
        textView.text = ""
        countLabel.text = "\(textView.text.count)/99"
    }
    
}

struct Result: Codable {
    let filename: String
    let video_url: String
}
