//
//  Flickr.swift
//  Spica
//
//  Created by Suita Fujino on 2016/09/28.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import Foundation
import OAuthSwift
import SwiftyJSON

class Flickr {
    // MARK: - 定数
    
    private let apiURL = "https://api.flickr.com/services/rest"
    
    // データ保存用のキー
    private enum KeyForUserDefaults : String {
        case oauthToken = "OAuthToken"
        case oauthTokenSecret = "OAuthTokenSecret"
    }
    
    // MARK: - 構造体
    
    private struct OAuthToken {
        let token : String
        let secret : String
    }
    
    private struct OAuthParams {
        let consumerKey : String
        let consumerSecret: String
        let requestTokenURL = "https://www.flickr.com/services/oauth/request_token"
        let authorizeURL = "https://www.flickr.com/services/oauth/authorize"
        let accessTokenURL = "https://www.flickr.com/services/oauth/access_token"
        
        init?() {
            // temporarily loading from .txt file
            guard let path = Bundle.main.path(forResource: "key", ofType: "txt") else { return nil }
            do {
                let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                let lines = text.components(separatedBy: CharacterSet.newlines)
                consumerKey = lines[0]
                consumerSecret = lines[1]
            } catch (let error) {
                consumerKey = ""
                consumerSecret = ""
                print(error)
                return nil
            }
        }
    }
    
    struct Coordinates {
        var latitude: Double
        var longitude: Double
    }
    
    // MARK: - プロパティ
    
    private let params = OAuthParams()
    
    private var oauthSwift : OAuth1Swift?
    
    private var oauthToken : OAuthToken?
    {
        didSet {
            guard let oauthToken = oauthToken else { return }
            let defaults = UserDefaults.standard
            defaults.set(oauthToken.token, forKey: KeyForUserDefaults.oauthToken.rawValue)
            defaults.set(oauthToken.secret, forKey: KeyForUserDefaults.oauthTokenSecret.rawValue)
        }
    }
    
    // MARK: イニシャライザ
    
    init() {
        guard let params = params else { return }
        
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
            oauthSwift?.client = OAuthSwiftClient(
                consumerKey: params.consumerKey,
                consumerSecret: params.consumerSecret,
                accessToken: token,
                accessTokenSecret: secret
            )
            oauthToken = OAuthToken(token: token, secret: secret)
        }
    }
    
    // MARK: メソッド
    
    /**
     flickrのユーザーアカウントを表示して、アプリの認証をする。認証を既にしていた場合は処理を行わない。
     成功した場合、consumer keyとconsumer secretを利用してOAuth tokenを取得する。
     TODO: 失敗した場合の処理。
     - parameter coordinates: 写真を検索する際の中心座標。
     - parameter accuracy: 検索する範囲の広さを1〜16で指定する。値が大きいほど狭くなる。
     - returns: 成功したかどうかを返す。認証を既にしていた場合、trueを返す。
     */
    
    func authorize() -> Bool {
        if (oauthToken != nil) { return true }
        var succeeded = false
        oauthSwift?.authorizeWithCallbackURL(
            URL(string: "Spica://oauth-callback/flickr")!,
            success: { credential, response, parameters in
                self.oauthToken = OAuthToken(token: credential.oauth_token, secret: credential.oauth_token_secret)
                succeeded = true
            },
            failure: { error in
                print(error.localizedDescription)
            }
        )
        
        return succeeded
    }
    
    
    
    /**
     指定された座標周辺の写真をJSON形式で取得し、パースする。パースしたデータはPhotoクラスの配列に格納される。
     TODO: 失敗時の処理。未認証時認証。
     - parameter coordinates: 写真を検索する際の中心座標。
     - parameter accuracy: 検索する範囲の広さを1〜16で指定する。値が大きいほど狭くなる。
    */
    
    func getPhotos(coordinates: Coordinates, accuracy: Int, handler: @escaping ([Photo]) -> ()) {
        guard let params = params else { fatalError("params is nil.") }
        guard let oauthSwift = oauthSwift else { fatalError("oauthSwift is nil.") }
        
        _ = oauthSwift.client.get(apiURL,
            parameters: [
                "api_key"  : params.consumerKey,
                "lat"      : coordinates.latitude,
                "lon"      : coordinates.longitude,
                "format"   : "json",
                "accuracy" : accuracy,
                "method"   : "flickr.photos.search",
                "nojsoncallback" : 1
            ],
            headers: nil,
            success: { (data, response) in
                let json = JSON(data: data)

                let status = json["stat"].stringValue
                if(status != "ok") {
                    // FIXME: 何か表示する。
                    printLog(json["message"].stringValue)
                }
                
                handler(json["photos"]["photo"].arrayValue.map{ Photo(json: $0) })
            },
            failure: { error in
                // FIXME: 何か表示する。
                printLog(error)
            }
        )
    
    }
    
}

func printLog(_ obj: Any) {
    print("##Spica Log: \(obj)")
}
