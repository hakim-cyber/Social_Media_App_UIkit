//
//  FollowersListViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/29/25.
//

import Foundation

protocol FollowerListCellDelegate:AnyObject{
    func didTapProfile(cell:FollowerListCell)
    func didTapFollow(cell:FollowerListCell)
    func didTapMore(cell:FollowerListCell)
}
