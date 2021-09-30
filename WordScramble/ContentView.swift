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
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    func wordOffet(_ wordGeo: GeometryProxy, _ geo: GeometryProxy) -> CGFloat {
        let wordMaxY = wordGeo.frame(in: .global).maxY
        let wordHeight = wordGeo.size.height
        let endPoint = geo.frame(in:.global).maxY
        let startPoint = endPoint - wordHeight
        
        if wordMaxY < startPoint {
            return 0
        } else if wordMaxY > endPoint {
            return geo.size.width
        } else {
            let percentage = (wordMaxY - endPoint) / wordHeight + 1
            return geo.size.width * percentage
        }
    }
    
    func wordColor(_ wordGeo: GeometryProxy, _ geo: GeometryProxy) -> Color {
        var percent = (wordGeo.frame(in: .global).midY - geo.frame(in: .global).minY) / (geo.frame(in: .global).maxY - geo.frame(in: .global).minY)
        if percent < 0 { percent = 0 } else
        if percent > 1 { percent = 1 }
        return Color(hue: percent, saturation: 1, brightness: 0.75)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                GeometryReader { geo in
                    List {
                        ForEach(usedWords, id: \.self) { word in
                            GeometryReader { wordGeo in
                                HStack {
                                    Image(systemName: "\(word.count).circle.fill")
                                        .foregroundColor(wordColor(wordGeo, geo))
                                    Text(word)
                                }
                                .accessibilityElement(children: .ignore)
                                .accessibility(label: Text("\(word), \(word.count) letters"))
                                .offset(x: wordOffet(wordGeo, geo))
                                .frame(width: wordGeo.size.width, height: wordGeo.size.height, alignment: .leading)
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                Text("Score: \(score)")
                    .font(.headline)
            }
            .navigationTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError, content: {
                Alert(title: Text(errorTitle), message: Text(errorMessage))
            })
            .navigationBarItems(trailing: Button("Restart", action: startGame))
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !answer.isEmpty else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original.")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }
        
        guard isLongEnough(word: answer) else {
            wordError(title: "Word too short", message: "Be more creative.")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
        score += answer.count
    }
    
    func startGame() {
        guard let url = Bundle.main.url(forResource: "start", withExtension: "txt"),
              let startText = try? String(contentsOf: url) else {
            fatalError("Error loading start.txt")
        }
        
        let words = startText.components(separatedBy: "\n")
        
        rootWord = words.randomElement() ?? "silkworm"
        usedWords = []
        score = 0
        
        // For debugging scrolling effects:
//        for _ in 0..<15 {
//            var word = words.randomElement() ?? "silkworm"
//            word.removeLast(Int.random(in: 0..<5))
//            usedWords.append(word)
//        }
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var remainingLetters = rootWord
        
        for letter in word {
            if let index = remainingLetters.firstIndex(of: letter) {
                remainingLetters.remove(at: index)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isLongEnough(word: String) -> Bool {
        word.count >= 3
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
