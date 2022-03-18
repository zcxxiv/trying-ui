//
//  AnswersView.swift
//  Trying
//
//  Created by ZC on 2/20/22.
//

import SwiftUI

public struct Answer: Identifiable, Equatable {
    public var id: UUID
    public var questionID: UUID
    public var date: Date
    public var score: Int
    public var notes: String
}


public struct AnswersView: View {
    public init() {}
    public var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct AnswersView_Previews: PreviewProvider {
    static var previews: some View {
        AnswersView()
    }
}
