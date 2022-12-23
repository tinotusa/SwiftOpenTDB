# SwiftOpenTDB

A wrapper for [OpenTDB](https://opentdb.com)

``` swift
let openTDB = OpenTDB.shared

// Set the trivia options.
openTDB.triviaConfig = .init(
    numberOfQuestions: 10,
    category: .animals,
    difficulty: .easy,
    triviaType: .any
)

// Get the questions.
let questions = openTDB.getQuestions()

for question in questions {
    print(question.question)
    print(question.incorrectAnswers)
}
```
