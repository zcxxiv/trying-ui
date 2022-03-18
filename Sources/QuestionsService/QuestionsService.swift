//
//  File.swift
//  
//
//  Created by ZC on 2/25/22.
//

import Foundation
import Combine
import ComposableArchitecture
import XCTestDynamicOverlay

import Shared

public struct QuestionsService {
  public var getQuestions: () -> Effect<[Question], Error>
  public var addQuestion: (Question) -> Effect<Question, Error>
  public var updateQuestion: (Question) -> Effect<Question, Error>
  public var deleteQuestion: (String) -> Effect<String, Error>
  
  public struct Error: Swift.Error, Equatable {
    public init() {}
  }
}

public extension QuestionsService {
  static let live = Self(
    getQuestions: {
//      Effect.task {
//        do {
//          let (questions, _) = try await URLSession.shared
//            .data(from: URL(string: "https://e90a0722867e901827e17bafcea2c824.m.pipedream.net/questions")!)
//          return try JSONDecoder().decode([Question].self, from: questions)
//        } catch {
//          return []
//        }
//      }
//      .setFailureType(to: Error.self)
      URLSession.shared.dataTaskPublisher(
        for: URL(string: "https://e90a0722867e901827e17bafcea2c824.m.pipedream.net/questions")!
      )
        .map { data, _ in data }
        .decode(type: [Question].self, decoder: JSONDecoder())
        .mapError { error in print(error); return Error() }
        .eraseToEffect()
    },
    addQuestion: { (question: Question) -> Effect<Question, Error> in
      var request = URLRequest(url: URL(string: "https://beb80e6a3c6143432c25922d1cc80585.m.pipedream.net")!)
      request.httpMethod = "POST"
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue("application/json", forHTTPHeaderField: "Accept")
      request.httpBody = try? JSONEncoder().encode(question)
      return URLSession.shared.dataTaskPublisher(for: request)
        .map { data, _ in data }
        .decode(type: Question.self, decoder: JSONDecoder())
        .mapError { error in print(error); return Error() }
        .eraseToEffect()
    },
    updateQuestion: { (question: Question) -> Effect<Question, Error> in
      var request = URLRequest(url: URL(string: "https://beb80e6a3c6143432c25922d1cc80585.m.pipedream.net")!)
      request.httpMethod = "PUT"
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue("application/json", forHTTPHeaderField: "Accept")
      request.httpBody = try? JSONEncoder().encode(question)
      return URLSession.shared.dataTaskPublisher(for: request)
        .map { data, _ in data }
        .decode(type: Question.self, decoder: JSONDecoder())
        .mapError { error in print(error); return Error() }
        .eraseToEffect()
    },
    deleteQuestion: { (id: String) -> Effect<String, Error> in
      var request = URLRequest(url: URL(string: "https://beb80e6a3c6143432c25922d1cc80585.m.pipedream.net/\(id)")!)
      request.httpMethod = "DELETE"
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue("application/json", forHTTPHeaderField: "Accept")
      return URLSession.shared.dataTaskPublisher(for: request)
        .map { data, _ in data }
        .decode(type: String.self, decoder: JSONDecoder())
        .mapError { error in print(error); return Error() }
        .eraseToEffect()
    }
  )
}

extension QuestionsService {
  public static let mock = Self(
    getQuestions: {
//      Fail(error: Error())
//        .eraseToEffect()
//      Just([])
//        .setFailureType(to: Error.self)
//        .eraseToEffect()
      Just(.mock)
        .setFailureType(to: Error.self)
        .eraseToEffect()
    },
    addQuestion: { question in
//      Fail(error: Error())
//        .eraseToEffect()
      Just(
        Question(
          id: "1729",
          title: question.title,
          description: question.description
        ))
        .setFailureType(to: Error.self)
        .eraseToEffect()
    },
    updateQuestion: { question in
//      Fail(error: Error())
//        .eraseToEffect()
      Just(
        Question(
          id: question.id,
          title: question.title,
          description: question.description
        ))
        .setFailureType(to: Error.self)
        .eraseToEffect()
    },
    deleteQuestion: { id in
//      Fail(error: Error())
//        .eraseToEffect()
      Just(id)
        .setFailureType(to: Error.self)
        .eraseToEffect()
    }
  )
}

extension QuestionsService {
  public static let noop = Self(
    getQuestions: { .none },
    addQuestion: { _ in .none },
    updateQuestion: { _ in .none },
    deleteQuestion: { _ in .none }
  )
}

#if DEBUG
extension QuestionsService {
  static let failing = Self(
    getQuestions: {
      XCTFail("\(Self.self).getQuetions is unimplemented.")
      return .none
    },
    addQuestion: { _ in
      XCTFail("\(Self.self).addQuestion is unimplemented.")
      return .none
    },
    updateQuestion: { _ in
      XCTFail("\(Self.self).updateQuestion is unimplemented.")
      return .none
    },
    deleteQuestion: { _ in
      XCTFail("\(Self.self).deleteQuestion is unimplemented.")
      return .none
    }
  )
}
#endif
