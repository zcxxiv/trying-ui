//
//  QuestionsPreviewApp.swift
//  QuestionsPreview
//
//  Created by ZC on 2/25/22.
//

import SwiftUI
import Questions
import QuestionsService

@main
struct QuestionsPreviewApp: App {
  var body: some Scene {
    WindowGroup {
      QuestionsView(
        store: .init(
          initialState: .init(),
          reducer: questionsReducer,
          environment: .mock
        )
      )
    }
  }
}
