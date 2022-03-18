//
//  ContentView.swift
//  Shared
//
//  Created by ZC on 2/10/22.
//

import SwiftUI
import ComposableArchitecture
import Questions
import Answers


public struct ContentView: View {
  public let store: Store<AppState, AppAction>
  public var body: some View {
    WithViewStore(store) { viewStore in
      TabView(
        selection: viewStore.binding(get: \.route, send: AppAction.navigate)
      ) {
        QuestionsView(store: Store(
          initialState: QuestionsState(),
          reducer: questionsReducer,
          environment: .init(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            service: .mock
          )
        ))
          .tabItem {
            Image(systemName: "lightbulb")
            Text("Questions")
          }
          .tag(AppRoute.questions(nil))
        AnswersView()
          .tabItem {
            Image(systemName: "list.star")
            Text("Answers")
          }
          .tag(AppRoute.answers)
      }
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(store: Store(
      initialState: AppState(questions: mockQuestions, route: .questions(nil)),
      reducer: appReducer,
      environment: .live
    ))
  }
}
