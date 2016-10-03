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
    
    
    private let params = OAuthParams()
    
    private lazy var oauthSwift : OAuth1Swift? = {
        return self.params.map{ (params) in
            return OAuth1Swift(
                consumerKey: params.consumerKey,
                consumerSecret: params.consumerSecret,
                requestTokenUrl: params.requestTokenURL,
                authorizeUrl: params.authorizeURL,
                accessTokenUrl: params.accessTokenURL
            )
        }
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
    
    struct Coordinates {
        var latitude: Double
        var longitude: Double
    }
    
    func getPhotos(coordinates: Coordinates, accuracy: Int) {
        guard let params = params else { fatalError("params is nil.") }
        guard let oauthSwift = oauthSwift else { fatalError("oauthSwift is nil.") }
        
        _ = oauthSwift.client.get(apiURL,
            parameters: [
                "api_key"  : params.consumerKey,
                "lat"      : coordinates.latitude,
                "lon"      : coordinates.longitude,
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
