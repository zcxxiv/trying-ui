//
//  QuestionsView.swift
//  Trying
//
//  Created by ZC on 2/20/22.
//

import SwiftUI
import SwiftUINavigation
import ComposableArchitecture

import Shared
import QuestionsService

// MARK: - Model

public let mockQuestions: IdentifiedArrayOf<QuestionState> = [
  QuestionState(
    question: Question(id: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F", title: "Did I do my best in setting up clear goals today?")
  ),
  QuestionState(
    question: Question(id: "E621E1F8-C36C-495A-93FC-0C247A3E6E4F", title: "Did I do my best in making progress for my goals today?")
  ),
  QuestionState(
    question: Question(id: "E621E1F8-C36C-495A-93FC-0C247A3E6E3F", title: "Did I do my best in being a great husband?")
  ),
  QuestionState(
    question: Question(id: "E621E1F8-C36C-495A-93FC-0C247A3E6E2F", title: "Did I do my best in getting healthier?")
  ),
]

public enum QuestionsRoute: Equatable, Hashable {
  case add
  case error
  case empty
}

// MARK: - Logic

public struct QuestionsState: Equatable {
  public var route: QuestionsRoute?
  public var questions: IdentifiedArrayOf<QuestionState> = []
  public var isGetQuestionsRequestInFlight = false
  public var hasLoadedQuestions = false
  public var isLoading: Bool {
    !hasLoadedQuestions && isGetQuestionsRequestInFlight
  }
  
  public var addQuestion = AddQuestionState()
  
  public init(route: QuestionsRoute? = nil  ) {
    self.route = route
  }
}

extension QuestionsState {
  static var placeholder: Self {
    var state = QuestionsState()
    state.questions = mockQuestions
    return state
  }
}

public enum QuestionsAction: Equatable {
  case navigate(QuestionsRoute?)
  case fetchQuestions
  case questionsResponse(Result<[Question], QuestionsService.Error>)
  case question(id: String, action: QuestionAction)
  case addQuestion(AddQuestionAction)
  case addButtonTapped
}

public struct QuestionsEnvironment {
  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>,
    service: QuestionsService
  ) {
    self.mainQueue = mainQueue
    self.service = service
  }
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var service: QuestionsService
}

public extension QuestionsEnvironment {
  static let live = Self(
    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
    service: .live
  )
}

public extension QuestionsEnvironment {
  static let mock = Self(
    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
    service: .mock
  )
}

public let questionsReducer = Reducer<QuestionsState, QuestionsAction, QuestionsEnvironment>.combine(
  questionReducer.forEach(
    state: \QuestionsState.questions,
    action: /QuestionsAction.question(id:action:),
    environment: { $0 }
  ),
  addQuestionReducer.pullback(
    state: \QuestionsState.addQuestion,
    action: /QuestionsAction.addQuestion,
    environment: { $0 }
  ),
  .init { state, action, environment in
    switch action {
      
    case let .questionsResponse(.success(questions)):
      state.isGetQuestionsRequestInFlight = false
      state.hasLoadedQuestions = true
      state.questions = IdentifiedArrayOf<QuestionState>(
        uniqueElements: questions.map(QuestionState.init)
      )
      return state.questions.count == 0
      ? .init(value: .navigate(.empty))
      : .none
      
    case let .questionsResponse(.failure(error)):
      state.isGetQuestionsRequestInFlight = false
      return .init(value: .navigate(.error))
      
    case .fetchQuestions:
      state.isGetQuestionsRequestInFlight = true
      return environment.service.getQuestions()
        .receive(on: environment.mainQueue)
        .catchToEffect(QuestionsAction.questionsResponse)
      
    case let .navigate(route):
      state.route = route
      return .none
      
    case let .question(id, questionAction):
      switch questionAction {
      case let .navigate(route):
        state.questions[id: id]?.route = route
        return .none
      case let .updateResponse(.success(question)):
        state.questions[id: id]?.question = question
        return .none
      default:
        return .none
      }
      
    case .addButtonTapped:
      state.addQuestion = .init()
      return .init(value: .navigate(.add))
      
    case .addQuestion(.cancelTapped):
      state.route = .none
      return .none
      
    case let .addQuestion(.addQuestionResponse(.success(question))):
      state.route = .none
      state.questions.append(
        QuestionState(question: question)
      )
      return .none
      
    case .addQuestion:
      return .none
    }
  })
  .debug()

// MARK: - View

public struct QuestionsView: View {
  public let store: Store<QuestionsState, QuestionsAction>
  public init(store: Store<QuestionsState, QuestionsAction>) {
    self.store = store
  }
  public var body: some View {
    HStack {
      NavigationView {
        WithViewStore(self.store) { viewStore in
          QuestionsListView(
            store: viewStore.isLoading
            ? .init(initialState: .placeholder, reducer: .empty, environment: ())
            : store
          )
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Daily Questions")
            .toolbar {
              Button("Add") { viewStore.send(.addButtonTapped) }
            }
            .onAppear {
              viewStore.send(.fetchQuestions)
            }
            .redacted(reason: viewStore.isLoading ? .placeholder : [])
            .sheet(
              unwrapping: viewStore.binding(get: \.route, send: QuestionsAction.navigate(.add)),
              case: /QuestionsRoute.add,
              onDismiss: { viewStore.send(.navigate(nil)) }) { _ in
                AddQuestionView(
                  store: store.scope(
                    state: \.addQuestion,
                    action: QuestionsAction.addQuestion
                  )
                )
              }
        }
      }
    }
  }
}

public struct QuestionsListView: View {
  public let store: Store<QuestionsState, QuestionsAction>
  public var body: some View {
    WithViewStore(store) { viewStore in
      switch viewStore.route {
      case .none, .add:
        ScrollView {
          VStack(spacing: 0) {
            ForEachStore(
              store.scope(
                state: \.questions,
                action: QuestionsAction.question(id:action:))
            ) { questionStore in
              QuestionRowView(store: questionStore)
            }
          }
          .padding(.horizontal)
          .padding(.top)
        }
        .background(Color(.secondarySystemBackground))
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
      case .error:
        VStack {
          Spacer()
          Text("Failed fetching questions")
            .padding(.bottom, 4)
          Button {
            viewStore.send(.fetchQuestions)
          } label: {
            Text("Try Again")
          }
          Spacer()
        }
      case .empty:
        VStack {
          Spacer()
          Text("No questions available, please create some using Add button near the top.")
            .padding()
          Spacer()
        }
      }
    }
  }
}

// MARK: - Preview

struct QuestionsView_Previews: PreviewProvider {
  static var previews: some View {
    QuestionsView(store: Store(
      initialState: QuestionsState(),
      reducer: questionsReducer,
      environment: .live
    ))
  }
}
