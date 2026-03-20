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
    func makeSession(for flow: AppFlow) -> Session {
        switch flow {
        case .login:
            return LoginSession()
        case .main:
            return AuthenticatedSession()
        }
    }
}
