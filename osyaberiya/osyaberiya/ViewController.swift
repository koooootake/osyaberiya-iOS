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
                print("Sucsess Session: \(String(describing: data)) \(String(describing: response))")
            } else {
                print("Error Session: \(String(describing: error))")
            }
        })
        //sessionスタート
        task.resume()
    }
}
