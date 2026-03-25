//
//  AppConstants.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/12/25.
//


import UIKit
enum AppConstants {
    
    enum Feed {
        static let pageSize: Int = 20
        static let maxPrefetchPages: Int = 2
        static let cellCornerRadius: CGFloat = 12
    }
    enum Media {
        
        enum AspectRatio {
                   /// 1:1 square
                   static let square = CGSize(width: 1, height: 1)
                   /// 4:5 Instagram portrait
                   static let portrait45 = CGSize(width: 4, height: 5)
                   /// 1:1.2 custom portrait
            static let portraitCustom = CGSize(width: 1, height: 1)
                   /// 16:9 landscape
                   static let landscape169 = CGSize(width: 16, height: 9)
                   /// Stories: 9:16
                   static let story916 = CGSize(width: 9, height: 16)
               }
        // Default pick/crop ratios per feature
              static let defaultPostCropRatio = AspectRatio.portraitCustom
              static let defaultStoryCropRatio = AspectRatio.story916
              static let defaultAvatarCropRatio = AspectRatio.square
        
    }
    enum UI {
           static let defaultSpacing: CGFloat = 12
           static let smallSpacing: CGFloat = 8
        static let postCornerRadius: CGFloat = 15
       }
}
