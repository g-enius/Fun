//
//  HomeCoordinator.swift
//  Model
//
//  Coordinator protocol for Home tab navigation
//

@MainActor
public protocol HomeCoordinator: AnyObject {
    func showDetail(for item: FeaturedItem)
    func showProfile()
}
