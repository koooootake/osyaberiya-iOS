//
//  SettingViewController.swift
//  osyaberiya
//
//  Created by koooootake on 2017/12/17.
//  Copyright © 2017年 koooootake. All rights reserved.
//

import Foundation

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var tableTitle = [ ["SNS", "Twitter別アカログイン", "Twitterログアウト"],
                       ["おしゃべりや", "おしゃべりやとは", "Webアプリ"],
                       ["お問い合わせ", "公式Twitter"],
                       ["Special Thanks", "いらすとや"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "gray_bg"))
        tableView.backgroundView?.contentMode = .scaleAspectFill
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableTitle.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableTitle[section].count - 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableTitle[section][0]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view:UIView, forSection: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
        cell.textLabel?.text = tableTitle[indexPath.section][indexPath.row + 1]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Select : ",tableTitle[indexPath.section][indexPath.row + 1])
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                TwitterViewModel.login()
            case 1:
                let str = TwitterViewModel.logout()
                let alert: UIAlertController
                if str != "" {
                    alert = UIAlertController.show(title: "ログアウトしました", message: "\(str)")
                } else {
                    alert = UIAlertController.show(title: "ログインしていません", message: "")
                }
                self.present(alert, animated: true, completion: nil)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                let alert = UIAlertController.show(title: "おしゃべりや", message: "入力した文章をキャラクターがおしゃべりしてくれるコミュニケーションツールです。文章の内容に応じて、キャラクターの表情や背景が変化します。")
                self.present(alert, animated: true, completion: nil)
            case 1:
                openSafari(urlStr: "http://osyaberiya.com/")
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                openSafari(urlStr: "https://twitter.com/osyaberiya/")
            default:
                break
            }
        case 3:
            switch indexPath.row {
            case 0:
                openSafari(urlStr: "http://www.irasutoya.com/")
            default:
                break
            }
        default:
            break
        }
    }
    
    private func openSafari(urlStr: String) {
        guard let url = URL(string: urlStr) else {
            let alert = UIAlertController.show(title: "URLが無効です", message: "")
            self.present(alert, animated: true, completion: nil)
            return
        }
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
