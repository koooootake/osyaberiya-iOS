//
//  PostViewModel.swift
//  osyaberiya
//
//  Created by koooootake on 2017/12/27.
//  Copyright © 2017年 koooootake. All rights reserved.
//

import Foundation

class PostViewModel: NSObject {
    
    static func post(text: String, completion: @escaping (_ isSucsess: Bool, _ title: String, _ message: String) -> Void) {
        let param = [
            "input" : text
        ]
        
        guard let url = URL(string: "http://osyaberiya.com/generate") else {
            completion(false, "URLが無効です", UtilModel.contactMessage)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        } catch {
            completion(false, "リクエストが無効です", "\(UtilModel.contactMessage)\n\(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            if let error = error {
                completion(false, "通信に失敗しました🙅‍♂️", error.localizedDescription)
                return
            }
            
            guard let data = data else {
                completion(false, "動画の生成に失敗しました", UtilModel.contactMessage)
                return
            }
            
            let decoder: JSONDecoder = JSONDecoder()
            do {
                let result: Result = try decoder.decode(Result.self, from: data)
                VideoManager.shared.set(fileName: result.filename, filePath: result.video_url)
                print("Sucsess session :", result)
                completion(true, "動画の生成に成功しました", "")
            } catch {
                completion(false, "JSONの読み込みに失敗しました", "\(UtilModel.contactMessage)\n\(error.localizedDescription)")
            }
        })
        
        task.resume()
    }
}

struct Result: Codable {
    let filename: String
    let video_url: String
}
