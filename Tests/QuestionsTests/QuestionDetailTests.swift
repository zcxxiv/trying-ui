//
//  QuestionDetailTests.swift
//  
//
//  Created by ZC on 3/16/22.
//


import XCTest
import Combine
import ComposableArchitecture

import Shared
import QuestionsService

@testable import Questions

class QuestionDetailTests: XCTestCase {
  
  let mainQueue = DispatchQueue.test
  let mockQuesitonTitle = "question-title"
  let mockQuesitonDescription = "question-description"
  
  func testUpdateQuestionSuccessFlow() {
    let store = TestStore(
      initialState: .init(question: .mock),
      reducer: questionReducer,
      environment: .init(mainQueue: mainQueue.eraseToAnyScheduler(), service: .mock)
    )
    store.send(.navigate(.detail(nil))) {
      $0.route = .detail(nil)
      $0.originalQuestion = .mock
    }
    store.send(.titleChanged(mockQuesitonTitle)) {
      $0.question.title = self.mockQuesitonTitle
    }
    store.send(.descriptionChanged(mockQuesitonDescription)) {
      $0.question.description = self.mockQuesitonDescription
    }
    store.send(.updateTapped) {
      $0.isUpdateRequestInFlight = true
    }
    mainQueue.advance()
    store.receive(
      .updateResponse(
        .success(
          Question(
            id: Question.mock.id,
            title: mockQuesitonTitle,
            description: mockQuesitonDescription
          )
        )
      )
    ) {
      $0.isUpdateRequestInFlight = false
      $0.originalQuestion = nil
      $0.route = nil
    }
  }
  
  func testUpdateQuestionFailureFlow() {
    var service = QuestionsService.mock
    service.updateQuestion = { question in
      Fail(error: QuestionsService.Error())
        .eraseToEffect()
    }
    let store = TestStore(
      initialState: .init(question: .mock),
      reducer: questionReducer,
      environment: .init(mainQueue: mainQueue.eraseToAnyScheduler(), service: service)
    )
    store.send(.navigate(.detail(nil))) {
      $0.route = .detail(nil)
      $0.originalQuestion = .mock
    }
    store.send(.titleChanged(mockQuesitonTitle)) {
      $0.question.title = self.mockQuesitonTitle
    }
    store.send(.updateTapped) {
      $0.isUpdateRequestInFlight = true
    }
    mainQueue.advance()
    store.receive(
      .updateResponse(
        .failure(
          QuestionsService.Error()
        )
      )
    ) {
      $0.isUpdateRequestInFlight = false
      $0.route = .detail(.error("Failed to update the question. Please try again."))
    }
    store.send(.navigate(.detail(nil))) {
      $0.route = .detail(nil)
    }
  }
  
  func testUpdateButtonDisabled() {
    let store = TestStore(
      initialState: .init(question: .mock),
      reducer: questionReducer,
      environment: .init(mainQueue: mainQueue.eraseToAnyScheduler(), service: .mock)
    )
    // update button should be disabled when form is pristine
    store.send(.navigate(.detail(nil))) {
      $0.route = .detail(nil)
      $0.originalQuestion = .mock
      XCTAssertTrue($0.isUpdateButtonsDisabled)
    }
    // update button should be enabled when user make edit
    store.send(.titleChanged(mockQuesitonTitle)) {
      $0.question.title = self.mockQuesitonTitle
      XCTAssertFalse($0.isUpdateButtonsDisabled)
    }
    // update button should be disabled when user make edit without actual change comparing to the inital state
    store.send(.titleChanged(Question.mock.title)) {
      $0.question.title = Question.mock.title
      XCTAssertTrue($0.isUpdateButtonsDisabled)
    }
  }
  
  func testDeleteQuestionSuccessFlow() {
    let store = TestStore(
      initialState: .init(question: .mock),
      reducer: questionReducer,
      environment: .init(mainQueue: mainQueue.eraseToAnyScheduler(), service: .mock)
    )
    store.send(.navigate(.detail(nil))) {
      $0.route = .detail(nil)
      $0.originalQuestion = .mock
    }
    store.send(.navigate(.detail(.delete))) {
      $0.route = .detail(.delete)
    }
    store.send(.deleteConfirmationTapped) {
      $0.isDeleteRequestInFlight = true
    }
    mainQueue.advance()
    store.receive(.deleteResponse(.success(Question.mock.id))) {
      $0.isDeleteRequestInFlight = false
      $0.route = nil
    }
  }
  
  func testDeleteQuestionFailureFlow() {
    var service = QuestionsService.mock
    service.deleteQuestion = { question in
      Fail(error: QuestionsService.Error())
        .eraseToEffect()
    }
    let store = TestStore(
      initialState: .init(question: .mock),
      reducer: questionReducer,
      environment: .init(mainQueue: mainQueue.eraseToAnyScheduler(), service: service)
    )
    store.send(.navigate(.detail(nil))) {
      $0.route = .detail(nil)
      $0.originalQuestion = .mock
    }
    store.send(.navigate(.detail(.delete))) {
      $0.route = .detail(.delete)
    }
    store.send(.deleteConfirmationTapped) {
      $0.isDeleteRequestInFlight = true
    }
    mainQueue.advance()
    store.receive(.deleteResponse(.failure(QuestionsService.Error()))) {
      $0.isDeleteRequestInFlight = false
      $0.route = .detail(.error("Failed to delete the question. Please try again."))
    }
    store.send(.navigate(.detail(nil))) {
      $0.route = .detail(nil)
    }
  }
  
}
