//
//  TryingApp.swift
//  Shared
//
//  Created by ZC on 2/10/22.
//

import SwiftUI
import ComposableArchitecture
import Questions

public enum AppRoute: Hashable {
  case questions(QuestionsRoute?)
  case answers
}

public struct AppState: Equatable {
  public var questions: IdentifiedArrayOf<QuestionState>
  public var route: AppRoute
}

public enum AppAction {
  case navigate(AppRoute)
}

public struct AppEnvironment {
  public var uuid: () -> UUID
}

public extension AppEnvironment {
  static let live = AppEnvironment(uuid: UUID.init)
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
  case .navigate(let route):
    state.route = route
    return .none
  }
}
  .debug()

public struct TryingApp: View {
  public init() {}
  public var body: some View {
    ContentView(store: Store(
      initialState: AppState(questions: mockQuestions, route: .questions(nil)),
      reducer: appReducer,
      environment: .live
    ))
  }
}
