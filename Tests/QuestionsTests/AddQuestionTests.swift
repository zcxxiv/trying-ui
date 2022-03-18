//
//  AddQuestionTests.swift
//  
//
//  Created by ZC on 3/14/22.
//

import XCTest
import Combine
import ComposableArchitecture

import Shared
import QuestionsService

@testable import Questions

class AddQuestionTests: XCTestCase {
  let mainQueue = DispatchQueue.test
  let mockQuestionId = "1729"
  let mockQuesitonTitle = "question-title"
  let mockQuesitonDescription = "question-description"
  
  func testAddQuestionSuccessFlow() {
    let store = TestStore(
      initialState: .init(),
      reducer: addQuestionReducer,
      environment: .init(mainQueue: mainQueue.eraseToAnyScheduler(), service: .mock)
    )
    store.send(.titleChanged(mockQuesitonTitle)) { $0.title = self.mockQuesitonTitle }
    store.send(.descriptionChanged(mockQuesitonDescription)) {
      $0.description = self.mockQuesitonDescription
    }
    store.send(.submitTapped) {
      $0.isAddQuestionRequestInFlight = true
      XCTAssertTrue($0.isSubmitButtonDisabled)
    }
    mainQueue.advance()
    store.receive(
      .addQuestionResponse(
        .success(
          Question(
            id: mockQuestionId,
            title: mockQuesitonTitle,
            description: mockQuesitonDescription
          )
        )
      )
    ) {
      $0.isAddQuestionRequestInFlight = false
      XCTAssertFalse($0.isSubmitButtonDisabled)
    }
  }
  
  func testAddQuestionFailureFlow() {
    var service = QuestionsService.mock
    service.addQuestion = { question in
      Fail(error: QuestionsService.Error())
        .eraseToEffect()
    }
    let store = TestStore(
      initialState: .init(),
      reducer: addQuestionReducer,
      environment: .init(mainQueue: mainQueue.eraseToAnyScheduler(), service: service)
    )
    store.send(.titleChanged(mockQuesitonTitle)) { $0.title = self.mockQuesitonTitle }
    store.send(.descriptionChanged(mockQuesitonDescription)) {
      $0.description = self.mockQuesitonDescription
    }
    store.send(.submitTapped) { $0.isAddQuestionRequestInFlight = true }
    mainQueue.advance()
    store.receive(
      .addQuestionResponse(
        .failure(QuestionsService.Error())
      )
    ) {
      $0.isAddQuestionRequestInFlight = false
      $0.isErrorModalPresented = true
    }
    store.send(.errorModalDismissed) { $0.isErrorModalPresented = false }
  }
  
  func testSubmitButtonDisabledWhenTitleIsEmpty() {
    let store = TestStore(
      initialState: .init(),
      reducer: addQuestionReducer,
      environment: .init(mainQueue: mainQueue.eraseToAnyScheduler(), service: .mock)
    )
    store.send(.titleChanged(mockQuesitonTitle)) {
      $0.title = self.mockQuesitonTitle
      XCTAssertFalse($0.isSubmitButtonDisabled)
    }
    store.send(.titleChanged("")) {
      $0.title = ""
      XCTAssertTrue($0.isSubmitButtonDisabled)
    }
  }
  
}



