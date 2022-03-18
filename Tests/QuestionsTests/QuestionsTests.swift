//
//  QuestionsTests.swift
//  
//
//  Created by ZC on 2/22/22.
//

import XCTest
import Combine
import ComposableArchitecture

import Shared

@testable import Questions
import QuestionsService

class QuestionsTests: XCTestCase {
  let mainQueue = DispatchQueue.test
  
  func testFetchingQuestionsSuccess() {
    let store = TestStore(
      initialState: .init(route: nil),
      reducer: questionsReducer,
      environment: .init(mainQueue: mainQueue.eraseToAnyScheduler(), service: .mock)
    )
    store.send(.fetchQuestions) {
      $0.isGetQuestionsRequestInFlight = true
    }
    mainQueue.advance()
    store.receive(.questionsResponse(.success(.mock))) {
      $0.isGetQuestionsRequestInFlight = false
      $0.hasLoadedQuestions = true
      $0.questions = IdentifiedArrayOf<QuestionState>(
        uniqueElements: [Question].mock.map(QuestionState.init)
      )
    }
  }
  
  func testFetchingQuestionsFailure() {
    let mockError = QuestionsService.Error()
    var service = QuestionsService.mock
    service.getQuestions = { Fail(error: mockError).eraseToEffect() }
    let store = TestStore(
      initialState: .init(route: nil),
      reducer: questionsReducer,
      environment: .init(mainQueue: mainQueue.eraseToAnyScheduler(), service: service)
    )
    store.send(.fetchQuestions) {
      $0.isGetQuestionsRequestInFlight = true
    }
    mainQueue.advance()
    store.receive(.questionsResponse(.failure(mockError))) {
      $0.isGetQuestionsRequestInFlight = false
    }
    store.receive(.navigate(.error)) {
      $0.route = .error
    }
  }

  func testFetchingQuestionsEmpty() {
    var service = QuestionsService.mock
    service.getQuestions = { Just([]).setFailureType(to: QuestionsService.Error.self).eraseToEffect() }
    let store = TestStore(
      initialState: .init(route: nil),
      reducer: questionsReducer,
      environment: .init(mainQueue: mainQueue.eraseToAnyScheduler(), service: service)
    )
    store.send(.fetchQuestions) {
      $0.isGetQuestionsRequestInFlight = true
    }
    mainQueue.advance()
    store.receive(.questionsResponse(.success([]))) {
      $0.questions = []
      $0.hasLoadedQuestions = true
      $0.isGetQuestionsRequestInFlight = false
    }
    store.receive(.navigate(.empty)) {
      $0.route = .empty
    }
  }
  
  func testNavigateToAddQuestionWhenAddButtonTapped() {
    let store = TestStore(
      initialState: .init(route: nil),
      reducer: questionsReducer,
      environment: .init(mainQueue: mainQueue.eraseToAnyScheduler(), service: .mock)
    )
    store.send(.addButtonTapped) {
      $0.addQuestion = .init()
    }
    store.receive(.navigate(.add)) {
      $0.route = .add
    }
  }
  
  func testAddQuestionRespnoseShouldOptimisticallyUpadateQuestions () {
    let mockQuestion = Question.mock
    let store = TestStore(
      initialState: .init(route: nil),
      reducer: questionsReducer,
      environment: .init(mainQueue: mainQueue.eraseToAnyScheduler(), service: .mock)
    )
    store.send(.navigate(.add)) {
      $0.route = .add
    }
    store.send(.addQuestion(.addQuestionResponse(.success(mockQuestion)))) {
      $0.questions = [QuestionState(question: mockQuestion)]
      $0.route = .none
    }
  }
}
