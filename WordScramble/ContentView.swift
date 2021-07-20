//
//  ContentView.swift
//  WordScramble
//
//  Created by Milo Wyner on 7/19/21.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle.fill")
                    Text($0)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle(rootWord)
            .onAppear(perform: startGame)
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !answer.isEmpty else { return }
        
        // extra validation to come
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        guard let url = Bundle.main.url(forResource: "start", withExtension: "txt"),
              let startText = try? String(contentsOf: url) else {
            fatalError("Error loading start.txt")
        }
        
        let words = startText.components(separatedBy: "\n")
        
        rootWord = words.randomElement() ?? "silkworm"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
