//
//  ItemsCoordinator.swift
//  Model
//
//  Coordinator protocol for Items tab navigation
//

@MainActor
public protocol ItemsCoordinator: AnyObject {
    func showDetail(for item: FeaturedItem)
}
