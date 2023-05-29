//
//  AppleMusic.swift
//  Fitplay
//
//  Created by Samuel Vulakh on 4/28/23.
//

import MusicKit

class AppleMusicController: ObservableObject {
    @Published var isAuthorizedForMusicKit = false
    @Published var musicKitError: MusicAuthorization.Status?

    func requestMusicAuthorization() async {
        if MusicAuthorization.currentStatus == .notDetermined || MusicAuthorization.currentStatus == .authorized {
            let status = await MusicAuthorization.request()

            switch status {
                case .authorized:
                    isAuthorizedForMusicKit = true
                case .restricted:
                    musicKitError = .restricted
                case .notDetermined:
                    musicKitError = .notDetermined
                case .denied:
                    musicKitError = .denied
                @unknown default:
                    musicKitError = .notDetermined
                
                    
            }
        } else {
            if await UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
                await UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        }
    }
}
