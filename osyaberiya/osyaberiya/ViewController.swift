//
//  ViewController.swift
//  osyaberiya
//
//  Created by koooootake on 2017/12/16.
//  Copyright © 2017年 koooootake. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func sendText(_ sender: Any) {
        let param = [
            "input" : "アイウエオ"
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
            if error == nil {
                let decoder: JSONDecoder = JSONDecoder()
                guard let data = data else {
                    return
                }
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
            } else {
                print("Error Session : \(String(describing: error))")
            }
        })
        //sessionスタート
        task.resume()
    }
}

struct Result: Codable {
    let filename: String
    let video_url: String
}
