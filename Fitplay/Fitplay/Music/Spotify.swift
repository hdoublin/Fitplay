//
//  Spotiify.swift
//  Fitplay
//
//  Created by Samuel Vulakh on 4/28/23.
//

import SwiftUI
import SpotifyiOS
import Combine
import WebKit

class SpotifyController: NSObject, ObservableObject, WKNavigationDelegate {
    let spotifyClientID = "598cfa42cf3e4586b848cd740ca065f7"
    let spotifyRedirectURL = URL(string:"fitplay-redirect.app")!
    
    var accessToken: String? = nil
    
    var playURI = ""
    
    private var connectCancellable: AnyCancellable?
    
    private var disconnectCancellable: AnyCancellable?
    
    override init() {
        super.init()
//        connectCancellable = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
//            .receive(on: DispatchQueue.main)
//            .sink { _ in
//                self.connect()
//            }
        
        disconnectCancellable = NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.disconnect()
            }

    }
    
    var logInCompletion: (String) -> Void = { _ in }
        
    lazy var configuration = SPTConfiguration(
        clientID: spotifyClientID,
        redirectURL: spotifyRedirectURL
    )

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    func setAccessToken(from url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)
        
        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            self.accessToken = accessToken
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print(errorDescription)
        }
        
    }
    
    func connect() {
        guard let access = self.appRemote.connectionParameters.accessToken else {
            self.appRemote.authorizeAndPlayURI("")
            print("fwefwe")
            return
        }
        
        print(access)
        
        appRemote.connect()
    }
    
    var webView = WKWebView()
    
    func spotifyAuthVC() {
        // Create Spotify Auth ViewController
        let spotifyVC = UIViewController()
        // Create WebView
        let webView = WKWebView()
        webView.navigationDelegate = self
        spotifyVC.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: spotifyVC.view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: spotifyVC.view.leadingAnchor),
            webView.bottomAnchor.constraint(equalTo: spotifyVC.view.bottomAnchor),
            webView.trailingAnchor.constraint(equalTo: spotifyVC.view.trailingAnchor)
        ])
        
        let authURLFull = "https://accounts.spotify.com/authorize?response_type=token&client_id=" + spotifyClientID + "&redirect_uri=" + "fitplay-redirect.app://" + "&show_dialog=false"
        
        let urlRequest = URLRequest.init(url: URL.init(string: authURLFull)!)
        webView.load(urlRequest)
        
        // Create Navigation Controller
        let navController = UINavigationController(rootViewController: spotifyVC)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAction))
        spotifyVC.navigationItem.leftBarButtonItem = cancelButton
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshAction))
        spotifyVC.navigationItem.rightBarButtonItem = refreshButton
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navController.navigationBar.titleTextAttributes = textAttributes
        spotifyVC.navigationItem.title = "spotify.com"
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.tintColor = UIColor.white
        navController.navigationBar.barTintColor = UIColor.black
        navController.navigationBar.backgroundColor = .black
        navController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        navController.modalTransitionStyle = .coverVertical
        
        UIApplication.shared.windows.first?.rootViewController?.present(navController, animated: true, completion: nil)
    }
    
    func handleAuth(spotifyAccessToken: String) {
        logInCompletion(spotifyAccessToken)

            // Close Spotify Auth ViewController after getting Access Token
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
        }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("finishing")
        RequestForCallbackURL(request: navigationAction.request)
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    func RequestForCallbackURL(request: URLRequest) {
        // Get the access token string after the '#access_token=' and before '&token_type='
        let requestURLString = (request.url?.absoluteString)! as String
        if requestURLString.hasPrefix(spotifyRedirectURL.absoluteString) {
            if requestURLString.contains("#access_token=") {
                if let range = requestURLString.range(of: "=") {
                    let spotifAcTok = requestURLString[range.upperBound...]
                    if let range = spotifAcTok.range(of: "&token_type=") {
                        let spotifAcTokFinal = spotifAcTok[..<range.lowerBound]
                        handleAuth(spotifyAccessToken: String(spotifAcTokFinal))
                    }
                }
            }
        }
    }

//        func fetchSpotifyProfile(accessToken: String) {
//            print("Access Token: \(accessToken)")
//            logInCompletion(accessToken)
//            self.accessToken = accessToken
//            self.connect()
//            let tokenURLFull = "https://api.spotify.com/v1/me"
//            let verify: NSURL = NSURL(string: tokenURLFull)!
//            let request: NSMutableURLRequest = NSMutableURLRequest(url: verify as URL)
//            request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
//            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
//                if error == nil {
//                    let result = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [AnyHashable: Any]
//                    //AccessToken
//                    print("Spotify Access Token: \(accessToken)")
//                    //Spotify Handle
//                    let spotifyId: String! = (result?["id"] as! String)
//                    print("Spotify Id: \(spotifyId ?? "")")
//                    //Spotify Display Name
//                    let spotifyDisplayName: String! = (result?["display_name"] as! String)
//                    print("Spotify Display Name: \(spotifyDisplayName ?? "")")
//                    //Spotify Email
//                    let spotifyEmail: String! = (result?["email"] as! String)
//                    print("Spotify Email: \(spotifyEmail ?? "")")
//                    //Spotify Profile Avatar URL
//                    let spotifyAvatarURL: String!
//                    let spotifyProfilePicArray = result?["images"] as? [AnyObject]
//                    if (spotifyProfilePicArray?.count)! > 0 {
//                        spotifyAvatarURL = spotifyProfilePicArray![0]["url"] as? String
//                    } else {
//                        spotifyAvatarURL = "Not exists"
//                    }
//                    print("Spotify Profile Avatar URL: \(spotifyAvatarURL ?? "")")
//                }
//            }
//            task.resume()
//        }
    
    @objc func cancelAction() {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
     }

     @objc func refreshAction() {
         self.webView.reload()
     }
    
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }
}

extension SpotifyController: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            
        })
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("failed")
        print(error)
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnected")
    }
}

//extension SpotifyController: SPTAppRemotePlayerStateDelegate {
//    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
//        debugPrint("Track name: %@", playerState.track.name)
//    }
//
//}
extension SpotifyController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        // noop
    }
    
}
