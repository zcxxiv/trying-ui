//
//  QuestionRow.swift
//  
//
//  Created by ZC on 2/24/22.
//

import SwiftUI
import SwiftUINavigation
import ComposableArchitecture

import Shared

public struct QuestionRowView: View {
  public let store: Store<QuestionState, QuestionAction>
  
  public var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack {
        NavigationLink(
          unwrapping: viewStore.binding(get: \.route, send: QuestionAction.navigate(.detail(nil))),
          case: /QuestionRoute.detail
        ) { $question in
          QuestionDetailView(store: store)
        } onNavigate: { activated in
          viewStore.send(.navigate(activated ? .detail(nil) : nil))
        } label: {
          HStack{
            Text(viewStore.question.title)
              .foregroundColor(Color(UIColor.label))
              .fontWeight(.medium)
              .multilineTextAlignment(.leading)
            Spacer()
            Image(systemName: "chevron.right")
              .padding(.leading)
          }
          .padding()
          .padding(.horizontal)
          .background(Color(.systemBackground))
          .cornerRadius(8)
        }
      }
      .padding(.bottom)
      
    }
  }
}

