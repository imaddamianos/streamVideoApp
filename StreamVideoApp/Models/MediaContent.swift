//
//  MediaContent.swift
//  StreamVideoApp
//
//  Created by iMad on 10/02/2024.
//

import Foundation
import UIKit

struct MediaContent: Decodable {
    let image: String
    let hlsMediaURL: String
    let adsTagURL: String
    let isSubscriber: Bool
}


