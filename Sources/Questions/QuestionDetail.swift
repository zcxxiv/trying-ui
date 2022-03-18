//
//  QuestionDetail.swift
//  
//
//  Created by ZC on 3/15/22.
//

import SwiftUI
import Combine
import ComposableArchitecture

import Shared
import QuestionsService


// MARK: - Model

public enum QuestionDetailRoute: Equatable, Hashable {
  case delete
  case error(String)
}

public enum QuestionRoute: Equatable, Hashable {
  case detail(QuestionDetailRoute?)
}

// MARK: - Logic

public struct QuestionState: Identifiable, Equatable {
  public var question: Question
  public var id: String { question.id }
  public var route: QuestionRoute? = .none
  var isDeleteRequestInFlight = false
  var isUpdateRequestInFlight = false
  
  var originalQuestion: Question?
  
  public init(question: Question) {
    self.question = question
  }
  
  var isUpdateButtonsDisabled: Bool {
    isDeleteRequestInFlight || isUpdateRequestInFlight || isQuestionChanged
  }
  
  var isQuestionChanged: Bool {
    guard let questionBeforeUpdate = originalQuestion else {
      return true
    }
    return question == questionBeforeUpdate
  }
}

public enum QuestionAction: Equatable {
  case navigate(QuestionRoute?)
  case titleChanged(String)
  case descriptionChanged(String)
  case deleteConfirmationTapped
  case updateTapped
  case deleteResponse(Result<String, QuestionsService.Error>)
  case updateResponse(Result<Question, QuestionsService.Error>)
}

let questionReducer = Reducer<QuestionState, QuestionAction, QuestionsEnvironment>.init { state, action, environment in
  switch action {
    
  case let .navigate(route):
    if state.route == .none && route == .detail(.none) {
      state.originalQuestion = state.question
    }
    state.route = route
    return .none
  
  case let .titleChanged(title):
    state.question.title = title
    return .none
    
  case let .descriptionChanged(description):
    state.question.description = description
    return .none
    
  case .deleteConfirmationTapped:
    state.isDeleteRequestInFlight = true
    return environment.service.deleteQuestion(state.id)
      .receive(on: environment.mainQueue)
      .catchToEffect(QuestionAction.deleteResponse)
 
  case .deleteResponse(.success):
    state.isDeleteRequestInFlight = false
    state.route = .none
    return .none
    
  case .deleteResponse(.failure):
    state.isDeleteRequestInFlight = false
    state.route = .detail(.error("Failed to delete the question. Please try again."))
    return .none
    
  case .updateTapped:
    state.isUpdateRequestInFlight = true
    return environment.service.updateQuestion(state.question)
      .receive(on: environment.mainQueue)
      .catchToEffect(QuestionAction.updateResponse)

  case .updateResponse(.success):
    state.isUpdateRequestInFlight = false
    state.originalQuestion = nil
    state.route = .none
    return .none
    
  case .updateResponse(.failure):
    state.isUpdateRequestInFlight = false
    state.route = .detail(.error("Failed to update the question. Please try again."))
    return .none
    
  }
}

// MARK: - View

public struct QuestionDetailView: View {
  var store: Store<QuestionState, QuestionAction>
  public var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        LabeledTextEditor(
          label: "Question",
          text: viewStore.binding(
            get: \.question.title, send: QuestionAction.titleChanged
          )
        )
          .frame(maxHeight: 120)
          .padding(.bottom)
        LabeledTextEditor(
          label: "Description",
          text: viewStore.binding(
            get: \.question.description, send: QuestionAction.descriptionChanged
          )
        )
          .padding(.bottom)
        Spacer()
        HStack {
          Button { viewStore.send(.navigate(.detail(.delete))) } label: {
            Text("Delete")
              .fontWeight(.medium)
              .foregroundColor(Color(.systemRed))
          }
          Spacer()
          Button { viewStore.send(.updateTapped) } label: {
            HStack {
              Text("Update")
                .fontWeight(.medium)
            }
          }
          .disabled(viewStore.isUpdateButtonsDisabled)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .padding(24)
      
      // delete confirmation
      .alert(
        title: { _ in Text("Are you sure") },
        unwrapping: viewStore.binding(
          get: \.route,
          send: QuestionAction.navigate(.detail(.none))
        ),
        case: /QuestionRoute.detail .. /QuestionDetailRoute.delete,
        actions: { _ in
          Button(role: .destructive) {
            viewStore.send(.deleteConfirmationTapped)
          } label: {
            Text("Delete")
          }
        },
        message: { Text("Are you sure to delete this question?") }
      )
      
      // update or delete error alert
      .alert(
        title: { _ in Text("Error") },
        unwrapping: viewStore.binding(
          get: \.route,
          send: QuestionAction.navigate(.detail(.none))
        ),
        case: /QuestionRoute.detail .. /QuestionDetailRoute.error,
        actions: { _ in  },
        message: { Text($0) }
      )
    }
  }
}

