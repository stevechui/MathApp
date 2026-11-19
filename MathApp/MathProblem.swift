import Foundation

enum PracticeMode: String, CaseIterable, Identifiable {
    case addition
    case subtraction
    case additionAndSubtraction
    case multiplication
    case division
    case multiplicationAndDivision
    case multiplicationTable

    var id: String { rawValue }

    var title: String {
        switch self {
        case .addition: "Add"
        case .subtraction: "Subtract"
        case .additionAndSubtraction: "Add & Subtract"
        case .multiplication: "Multiply"
        case .division: "Divide"
        case .multiplicationAndDivision: "Multiply & Divide"
        case .multiplicationTable: "Multiplication table"
        }
    }

    var operations: [MathOperation] {
        switch self {
        case .addition: [.addition]
        case .subtraction: [.subtraction]
        case .additionAndSubtraction: [.addition, .subtraction]
        case .multiplication: [.multiplication]
        case .division: [.division]
        case .multiplicationAndDivision: [.multiplication, .division]
        case .multiplicationTable: [.multiplication]
        }
    }
}

enum MathOperation: String, CaseIterable {
    case addition
    case subtraction
    case multiplication
    case division

    var symbol: String {
        switch self {
        case .addition: "+"
        case .subtraction: "−"
        case .multiplication: "×"
        case .division: "÷"
        }
    }
}

struct MathProblem {
    let firstNumber: Int
    let secondNumber: Int
    let operation: MathOperation

    var answer: Int {
        switch operation {
        case .addition: firstNumber + secondNumber
        case .subtraction: firstNumber - secondNumber
        case .multiplication: firstNumber * secondNumber
        case .division: firstNumber / secondNumber
        }
    }

    var remainder: Int {
        guard operation == .division else { return 0 }
        return firstNumber % secondNumber
    }

    func isCorrect(_ input: String) -> Bool {
        if operation == .division {
            let parts = input.split(separator: "R")
            guard parts.count == 2,
                  let quotient = Int(parts[0]),
                  let remainder = Int(parts[1]) else {
                return false
            }
            return quotient == answer && remainder == self.remainder
        }

        return Int(input) == answer
    }

    static func generate(
        mode: PracticeMode,
        firstDigitCount: Int,
        secondDigitCount: Int
    ) -> MathProblem {
        precondition((1...4).contains(firstDigitCount), "First number digit count must be between 1 and 4.")
        precondition((1...4).contains(secondDigitCount), "Second number digit count must be between 1 and 4.")

        let operation = mode.operations[Int.random(in: 0..<mode.operations.count)]
        let first = randomNumber(digitCount: firstDigitCount)
        let second: Int

        switch operation {
        case .addition:
            second = randomNumber(digitCount: secondDigitCount)
        case .subtraction:
            second = randomNumber(digitCount: secondDigitCount)
        case .multiplication:
            second = randomNumber(digitCount: secondDigitCount)
        case .division:
            second = randomNumber(digitCount: secondDigitCount, allowZero: false)
        }

        return MathProblem(firstNumber: first, secondNumber: second, operation: operation)
    }

    private static func randomNumber(digitCount: Int, allowZero: Bool = true) -> Int {
        let minimum = digitCount == 1 ? (allowZero ? 0 : 1) : minimumNumber(digitCount: digitCount)
        return Int.random(in: minimum...maximumNumber(digitCount: digitCount))
    }

    private static func minimumNumber(digitCount: Int) -> Int {
        var minimum = 1
        for _ in 1..<digitCount {
            minimum *= 10
        }
        return minimum
    }

    private static func maximumNumber(digitCount: Int) -> Int {
        minimumNumber(digitCount: digitCount) * 10 - 1
    }
}
