//
//  File.swift
//  
//
//  Created by ZC on 3/6/22.
//

import Foundation

public enum QuestionStatus: Int, Codable {
  case active = 1
  case archived
  case deleted
}

public struct Question: Identifiable, Equatable, Hashable, Codable {
  public var id: String
  public var title: String
  public var description: String = ""
  public var status: QuestionStatus = .active
  
  public init(
    id: String,
    title: String,
    description: String = "",
    status: QuestionStatus = .active
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.status = status
  }

  enum CodingKeys: String, CodingKey { case id, title, description, status }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.title = try container.decode(String.self, forKey: .title)
    self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
    self.status = try container.decodeIfPresent(QuestionStatus.self, forKey: .status) ?? .active
  }
}

public extension Question {
  static let mock = Question(id: "1234", title: "Did I try my best in building mock questions?")
}

public extension Array where Element == Question {
  static let mock = [
    Question(id: "1234", title: "Did I try my best in building mock questions?"),
    Question(id: "2345", title: "Did I try my best in building mock answers?"),
    Question(id: "4567", title: "Did I try my best in finding meeting"),
    Question(id: "7890", title: "Did I try my best in build relationships?"),
  ]
}
