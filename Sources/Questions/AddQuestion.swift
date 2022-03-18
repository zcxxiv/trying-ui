//
//  SwiftUIView.swift
//  
//
//  Created by ZC on 3/11/22.
//

import SwiftUI
import ComposableArchitecture
import QuestionsService
import Shared

public struct AddQuestionState: Equatable {
  var title = ""
  var description = ""
  var isAddQuestionRequestInFlight = false
  var isErrorModalPresented = false
  var isSubmitButtonDisabled: Bool {
    title.isEmpty || isAddQuestionRequestInFlight
  }
}

public enum AddQuestionAction: Equatable {
  case titleChanged(String)
  case descriptionChanged(String)
  case submitTapped
  case cancelTapped
  case addQuestionResponse(Result<Question, QuestionsService.Error>)
  case errorModalDismissed
}

public let addQuestionReducer = Reducer<AddQuestionState, AddQuestionAction, QuestionsEnvironment>.init { state, action, environment in
  switch action {
    
  case let .titleChanged(title):
    state.title = title
    return .none
    
  case let .descriptionChanged(description):
    state.description = description
    return .none
    
  case .submitTapped:
    state.isAddQuestionRequestInFlight = true
    return environment.service.addQuestion(
      Question(id: "", title: state.title, description: state.description)
    )
      .receive(on: environment.mainQueue)
      .catchToEffect(AddQuestionAction.addQuestionResponse)
    
  case .addQuestionResponse(.failure):
    state.isAddQuestionRequestInFlight = false
    state.isErrorModalPresented = true
    return .none
    
  case .addQuestionResponse(.success):
    state.isAddQuestionRequestInFlight = false
    return .none
    
  case .errorModalDismissed:
    state.isErrorModalPresented = false
    return .none
    
  default:
    return .none
  }
}

struct AddQuestionView: View {
  public let store: Store<AddQuestionState, AddQuestionAction>
  
  init(store: Store<AddQuestionState, AddQuestionAction>) {
    self.store = store
  }
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack(alignment: .center) {
        // Page heading
        Text("What is your daily question?")
          .font(.title2)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)
          .padding(.vertical)
          .padding(.bottom)
        
        // Title text field
        LabeledTextEditor(
          label: "What is your daily question?",
          text: viewStore.binding(get: \.title, send: AddQuestionAction.titleChanged)
        )
          .padding(.bottom)
          .frame(maxHeight: 120)
        
        // Description text field
        LabeledTextEditor(
          label: "Describe your question in more detail",
          text: viewStore.binding(get: \.description, send: AddQuestionAction.descriptionChanged)
        )
          .padding(.bottom)
        
        Spacer()
        
        // Action buttons
        HStack {
          Button { viewStore.send(.cancelTapped) } label: {
            Text("Cancel")
              .fontWeight(.medium)
          }
          Spacer()
          Button { viewStore.send(.submitTapped) } label: {
            HStack {
              Text("Done")
                .fontWeight(.medium)
                .padding(.trailing, -2)
              Image(systemName: "checkmark.circle")
            }
          }
          .disabled(viewStore.isSubmitButtonDisabled)
        }
        .padding(.top)
      }
      .padding(24)
      .alert(isPresented: viewStore.binding(get: \.isErrorModalPresented, send: .errorModalDismissed)) {
        Alert(
          title: Text("Error"),
          message: Text("Failed to create question. Please try again later."),
          dismissButton: .default(Text("OK"))
        )
      }
    }
  }
}

/**
 * Text editor with label and a filled background
 */
struct LabeledTextEditor: View {
  var label: String
  @Binding var text: String
  
  init(label: String, text: Binding<String>) {
    UITextView.appearance().backgroundColor = .clear // removing white background from UITextView to allow setting custom background color
    self.label = label
    self._text = text
  }
  
  var body: some View {
    VStack {
      HStack {
        Text(label)
          .font(.footnote)
          .foregroundColor(.secondary)
        Spacer()
      }
      TextEditor(text: $text)
        .padding()
        .background(
          Color(UIColor.secondarySystemBackground)
        )
        .cornerRadius(4)
    }
  }
  
}
