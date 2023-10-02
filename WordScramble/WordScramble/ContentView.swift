//
//  ContentView.swift
//  WordScramble
//
//  Created by Oluwapelumi Williams on 07/09/2023.
//

// For this app make the following extensions:
// Disallow answers that are shorter than three letters or are just the start word
// Add a toolbar button that calls startGame(), so that users can restart with a new word whenever they want to
// put a text view somewhere so you can track and show the player's score for a given root word.

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]() // another way to specify the type of variable. Not syntactically called the same name as using the :[String] method
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score: Int = 0
//    @FocusState private var focusedField
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        //                        .focused($focusField)
                        Text("\(score)")
                    }
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(word), \(word.count) letters")
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                Button("Reset", action: resetGame)
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        // set the word to lowercase and then trim
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the resulting string is empty
        guard answer.count > 0 else { return }
        
        // extra validation
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Try another combination")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You cannot have this word combination from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "That is not a valid word.")
            return
        }
        
        guard isLessThanThree(word: answer) else {
            wordError(title: "Word not allowed", message:"Words less than 3 are not allowed")
            return
        }
        
        guard isSameAsRoot(word: answer) else {
            wordError(title: "Not allowed", message: "That's the same as the root word!")
            return
        }
        
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        // compute score: just the number of letters in newWord
        // another way to calculate score would be to rank all 26 alphabets in order of their rarity. Possibly normalize to the set of letters in each rootWord. Then add them all up.
        score += newWord.count
        
        newWord = ""
    }
    
    func startGame() {
        // locate the URL for start.txt in this app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            
            // load it into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // split the string into an array of strings, using line breaks as the split parameter
                let allWords = startWords.components(separatedBy: "\n")
                
                // pick one word at random. use "sensible" as default
                rootWord = allWords.randomElement() ?? "sensible"
                
                // all is good at this point
                return
            }
        }
        
        // at this point, a problem must have occured. Trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
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
    
    func isLessThanThree(word: String) -> Bool {
        return !(word.count < 3)
    }
    
    func isSameAsRoot(word: String) -> Bool {
        return !(word == rootWord)
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    
    func resetGame() {
        startGame()
        newWord = ""
        usedWords.removeAll()
        score = 0
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
