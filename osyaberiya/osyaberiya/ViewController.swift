//
//  ViewController.swift
//  osyaberiya
//
//  Created by koooootake on 2017/12/16.
//  Copyright © 2017年 koooootake. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.center = self.view.center
        indicator.color = UIColor.white
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
        self.view.bringSubview(toFront: indicator)
    }

    @IBAction func sendText(_ sender: Any) {
        let inputText = textView.text
        
        let param = [
            "input" : inputText
        ]
        
        guard let url = URL(string: "http://osyaberiya.com/generate") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        } catch {
            print("Error JSONSerialization : ", error.localizedDescription)
        }

        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            //くるくるstop
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            
            if let error = error {
                print("Error session　: \(error)")
                return
            }
            
            guard let data = data else {
                print("Error data")
                return
            }
            let decoder: JSONDecoder = JSONDecoder()
            do {
                let result: Result = try decoder.decode(Result.self, from: data)
                print("Sucsess Session :",result)
                VideoModel.shared.set(filePath: result.video_url)
                
                DispatchQueue.main.async {
                    //画面遷移
                    let storyboard: UIStoryboard = self.storyboard!
                    let resultViewController = storyboard.instantiateViewController(withIdentifier: "ResultViewController")
                    self.present(resultViewController, animated: true, completion: nil)
                }
                
            } catch {
                print("Error decode")
            }
            
        })
        task.resume()
        //くるくるstart
        indicator.startAnimating()
    }

}

struct Result: Codable {
    let filename: String
    let video_url: String
}
