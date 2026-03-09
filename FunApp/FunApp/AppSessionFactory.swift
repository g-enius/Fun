//
//  AppSessionFactory.swift
//  FunApp
//
//  Composition root: creates concrete sessions for each app flow
//

import FunCore
import FunModel
import FunServices

@MainActor
struct AppSessionFactory: SessionFactory {
    func makeSession(for flow: AppFlow, serviceLocator: ServiceLocator) -> Session {
        switch flow {
        case .login:
            return LoginSession(serviceLocator: serviceLocator)
        case .main:
            return AuthenticatedSession(serviceLocator: serviceLocator)
        }
    }
}
