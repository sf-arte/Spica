//
//  Flickr.swift
//  Spica
//
//  Created by Suita Fujino on 2016/09/28.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import OAuthSwift
import SwiftyJSON

/**
 
 FlickrのAPIを呼ぶクラス
 
 */

class Flickr {
    // MARK: - 定数
    /// Flickr APIのURL
    private let apiURL = "https://api.flickr.com/services/rest"
    
    /// データ保存用のキー
    private enum KeyForUserDefaults : String {
        case oauthToken = "OAuthToken"
        case oauthTokenSecret = "OAuthTokenSecret"
    }
    
    // MARK: - 構造体
    /// Flickrから返ってきたトークン
    private struct OAuthToken {
        let token : String
        let secret : String
    }
    
    /// OAuth認証に必要なパラメータ
    struct OAuthParams {
        let consumerKey : String
        let consumerSecret: String
        let requestTokenURL = "https://www.flickr.com/services/oauth/request_token"
        let authorizeURL = "https://www.flickr.com/services/oauth/authorize"
        let accessTokenURL = "https://www.flickr.com/services/oauth/access_token"

        init?(path: String) {
            do {
                let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                let lines = text.components(separatedBy: CharacterSet.newlines)
                consumerKey = lines[0]
                consumerSecret = lines[1]
            } catch (let error) {
                log?.error(error)
                return nil
            }
        }
    }
    
    
    // MARK: - プロパティ
    private let params : OAuthParams
    
    private var oauthSwift : OAuth1Swift
    
    private var oauthToken : OAuthToken?
    {
        didSet {
            guard let oauthToken = oauthToken else { return }
            let defaults = UserDefaults.standard
            defaults.set(oauthToken.token, forKey: KeyForUserDefaults.oauthToken.rawValue)
            defaults.set(oauthToken.secret, forKey: KeyForUserDefaults.oauthTokenSecret.rawValue)
        }
    }
    
    // MARK: Lifecycle
    /// イニシャライザ
    init(params: OAuthParams) {
        self.params = params
        
        oauthSwift = OAuth1Swift(
            consumerKey: params.consumerKey,
            consumerSecret: params.consumerSecret,
            requestTokenUrl: params.requestTokenURL,
            authorizeUrl: params.authorizeURL,
            accessTokenUrl: params.accessTokenURL
        )
        
        oauthToken = nil
        let defaults = UserDefaults.standard
        
        if let token = defaults.object(forKey: KeyForUserDefaults.oauthToken.rawValue) as? String,
            let secret = defaults.object(forKey: KeyForUserDefaults.oauthTokenSecret.rawValue) as? String {
            oauthSwift.client = OAuthSwiftClient(
                consumerKey: params.consumerKey,
                consumerSecret: params.consumerSecret,
                oauthToken: token,
                oauthTokenSecret: secret,
                version: .oauth1
            )
            oauthToken = OAuthToken(token: token, secret: secret)
        }
    }
    
    // MARK: メソッド
    
    /**
     flickrのユーザーアカウントを表示して、アプリの認証をする。認証を既にしていた場合は処理を行わない。
     成功した場合、consumer keyとconsumer secretを利用してOAuth tokenを取得する。
     
     TODO: 失敗した場合の処理
     */
    
    func authorize() {
        if (oauthToken != nil) { return }
        
        oauthSwift.authorize(
            withCallbackURL: URL(string: "Spica://oauth-callback/flickr")!,
            success: { [weak self] credential, response, parameters in
                self?.oauthToken = OAuthToken(token: credential.oauthToken, secret: credential.oauthTokenSecret)
            },
            failure: { error in
                log?.error(error.localizedDescription)
            }
        )
    }
    
    
    
    /**
     指定された座標周辺の写真をJSON形式で取得し、パースする。パースしたデータはPhotoクラスの配列に格納される。
     
     TODO: 失敗時の処理。未認証時認証。
     
     - parameter leftBottom: 写真を検索する範囲の左下の座標
     - parameter rightTop: 写真を検索する範囲の右上の座標
     - parameter count: 1回に取得する件数。500件まで
     - parameter handler: パースしたデータに対して実行する処理
    */
    
    func getPhotos(leftBottom: Coordinates, rightTop: Coordinates, count: Int, handler: @escaping ([Photo]) -> ()) {
        oauthSwift.client.get(apiURL,
            parameters: [
                "api_key"        : params.consumerKey,
                "format"         : "json",
                "bbox"           : "\(leftBottom.longitude),\(leftBottom.latitude),\(rightTop.longitude),\(rightTop.latitude)",
                "method"         : "flickr.photos.search",
                "sort"           : "interestingness-desc",
                "extras"         : "geo,owner_name,url_o,url_sq,url_l",
                "per_page"       : count,
                "nojsoncallback" : 1
            ],
            headers: nil,
            success: { data, response in
                let json = JSON(data: data)
            
                let status = json["stat"].stringValue
                if(status != "ok") {
                    log?.error(json["message"].stringValue)
                }
                handler(json["photos"]["photo"].arrayValue.map{ Flickr.decode(from: $0) })
            },
            failure: { error in
                log?.error(error)
            }
        )
    }
    
}

extension Flickr {
    static func decode(from json: JSON) -> Photo {
        let id = json["id"].intValue
        let owner = json["owner"].stringValue
        let ownerName = json["ownername"].stringValue
        let title = json["title"].stringValue
        let iconURL = json["url_sq"].stringValue
        let largeURL = json["url_l"].stringValue
        let originalURL = json["url_o"].stringValue
        let coordinates = Coordinates(latitude: json["latitude"].doubleValue, longitude: json["longitude"].doubleValue)
   
        return Photo(
            id: id,
            owner: owner,
            ownerName: ownerName,
            iconURL: iconURL,
            largeURL: largeURL,
            originalURL: originalURL,
            photoTitle: title,
            coordinate: coordinates
        )
    }
}
