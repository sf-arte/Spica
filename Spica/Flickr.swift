//
//  Flickr.swift
//  Spica
//
//  Created by Suita Fujino on 2016/09/28.
//  Copyright © 2016年 ARTE Co., Ltd. All rights reserved.
//

import Foundation
import OAuthSwift

class Flickr {
    private let apiURL = "https://api.flickr.com/services/rest"
    
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
        
        init? () {
            // temporarily loading from .txt file
            guard let path = Bundle.main.path(forResource: "key", ofType: "txt") else { return nil }
            var str : [String] = []
            do {
                let text = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
                text.enumerateLines { (line, ptr) in
                    str.append(line)
                }
                consumerKey = str[0]
                consumerSecret = str[1]
            } catch (let error) {
                consumerKey = ""
                consumerSecret = ""
                print(error)
                return nil
            }
        }
    }
    
    
    private let params = OAuthParams()
    
    private lazy var oauthSwift : OAuth1Swift? = {
        guard let par = self.params else { return nil }
        return OAuth1Swift(
            consumerKey: par.consumerKey,
            consumerSecret: par.consumerSecret,
            requestTokenUrl: par.requestTokenURL,
            authorizeUrl: par.authorizeURL,
            accessTokenUrl: par.accessTokenURL
        )
    }()
    
    private var oauthToken : OAuthToken? = nil
    
    
    func authorize() -> Bool {
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
    
    func getPhotosForLocation(latitude: Double, longitude: Double, accuracy: Int) {
        guard let par = params else { fatalError("params is nil.") }
        guard let oauth = oauthSwift else { fatalError("oauthSwift is nil.") }
        
        _ = oauth.client.get(apiURL,
            parameters: [
                "api_key"  : par.consumerKey,
                "lat"      : latitude,
                "lon"      : longitude,
                "format"   : "json",
                "accuracy" : accuracy,
                "method"   : "flickr.photos.search"
            ],
            headers: nil,
            success: { (data, response) in
                let dataString = String(data: data, encoding: String.Encoding.utf8)
                print(dataString)
            },
            failure: { error in
                print(error)
            }
        )
    
    }
    
}
