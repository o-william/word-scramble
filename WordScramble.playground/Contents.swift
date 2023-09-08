import UIKit

let input = "a b c"
let letters = input.components(separatedBy: " ")

let input2 = """
            apple
             ballc
            cirnge
            """

let letters2 = input2.components(separatedBy: "\n")

print("letters: \(letters)")
print("letters2: \(letters2)")

var word1 = letters2[0]
print(word1)

let trimmed = word1.trimmingCharacters(in: .whitespacesAndNewlines)

let checker = UITextChecker()
let range = NSRange(location: 0, length: trimmed.utf16.count)
let misspelledRange = checker.rangeOfMisspelledWord(in: trimmed, range: range, startingAt: 0, wrap: false, language: "en")

print(misspelledRange.location)
