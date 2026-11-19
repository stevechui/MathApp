//
//  ContentView.swift
//  MathApp
//
//  Created by Steve Chui on 11/16/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("selectedPracticeMode") private var selectedModeRawValue = PracticeMode.addition.rawValue
    @AppStorage("firstDigitCount") private var firstDigitCount = 1
    @AppStorage("secondDigitCount") private var secondDigitCount = 1
    @AppStorage("multiplicationTableNumber") private var multiplicationTableNumber = 4
    @State private var problem = MathProblem.generate(mode: .addition, firstDigitCount: 1, secondDigitCount: 1)
    @State private var strokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []
    @State private var answerInput = ""
    @State private var feedbackMessage: String?
    @State private var feedbackIsCorrect: Bool?
    @State private var isCanvasExpanded = false
    @State private var hasLoadedSavedSettings = false
    @State private var showSkipConfirmation = false
    @State private var multiplicationTableAnswers = Array(repeating: "", count: 10)
    @State private var multiplicationTableChecked = false
    @State private var multiplicationTableFeedback: String?

    private var selectedMode: PracticeMode {
        PracticeMode(rawValue: selectedModeRawValue) ?? .addition
    }

    private var selectedModeBinding: Binding<PracticeMode> {
        Binding(
            get: { selectedMode },
            set: { selectedModeRawValue = $0.rawValue }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(red: 0.94, green: 0.97, blue: 1)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        if selectedMode == .multiplicationTable {
                            multiplicationTableCard
                        } else {
                            workCard
                            answerCard
                        }
                    }
                    .frame(maxWidth: 560)
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.light)
        .onChange(of: selectedModeRawValue) { _, _ in
            if selectedMode == .multiplicationTable {
                clearMultiplicationTableAnswers()
            } else {
                makeNewProblem()
            }
        }
        .onChange(of: firstDigitCount) { _, _ in makeNewProblem() }
        .onChange(of: secondDigitCount) { _, _ in makeNewProblem() }
        .onChange(of: multiplicationTableNumber) { _, _ in clearMultiplicationTableAnswers() }
        .onAppear {
            guard !hasLoadedSavedSettings else { return }
            hasLoadedSavedSettings = true
            makeNewProblem()
        }
        .fullScreenCover(isPresented: $isCanvasExpanded) {
            ExpandedCanvasView(strokes: $strokes, currentStroke: $currentStroke, problem: problem)
        }
        .alert("Skip this question?", isPresented: $showSkipConfirmation) {
            Button("Keep working", role: .cancel) {}
            Button("Skip question", role: .destructive) {
                makeNewProblem()
            }
        } message: {
            Text("You haven't answered correctly yet. You can keep working on this question or skip to a new one.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Text("Math time!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.12, green: 0.23, blue: 0.42))
                Spacer()
                NavigationLink {
                    SettingsView(
                        selectedMode: selectedModeBinding,
                        firstDigitCount: $firstDigitCount,
                        secondDigitCount: $secondDigitCount,
                        multiplicationTableNumber: $multiplicationTableNumber
                    )
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(Color.blue)
                        .frame(width: 44, height: 44)
                        .background(.white, in: Circle())
                }
                .accessibilityLabel("Setting")
                .accessibilityIdentifier("open-settings")
            }
            Text("Solve it, draw it, and give it a try.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var workCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Solve it on the canvas")
                        .font(.system(.headline, design: .rounded))
                    Text("Write the problem out and show your work.")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    isCanvasExpanded = true
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(StepperButtonStyle())
                .accessibilityLabel("Expand canvas")
                .accessibilityIdentifier("expand-canvas")
                Button("Clear") {
                    strokes = []
                    currentStroke = []
                }
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .accessibilityIdentifier("clear-work")
            }

            WorkArea(strokes: $strokes, currentStroke: $currentStroke, problem: problem)
                .frame(height: 300)
                .accessibilityIdentifier("work-area")
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private var multiplicationTableCard: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Multiplication table")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text("Fill in each answer.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Clear") {
                    clearMultiplicationTableAnswers()
                }
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .accessibilityIdentifier("clear-table-answers")
            }
            .padding(.bottom, 4)

            ForEach(1...10, id: \.self) { multiplier in
                let answer = multiplicationTableNumber * multiplier
                let isCorrect = Int(multiplicationTableAnswers[multiplier - 1]) == answer

                HStack(spacing: 8) {
                    Text("\(multiplicationTableNumber) × \(multiplier) =")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .monospacedDigit()

                    Spacer(minLength: 4)

                    TextField("?", text: Binding(
                        get: { multiplicationTableAnswers[multiplier - 1] },
                        set: { value in
                            multiplicationTableAnswers[multiplier - 1] = String(value.filter(\.isNumber).prefix(3))
                            multiplicationTableChecked = false
                            multiplicationTableFeedback = nil
                        }
                    ))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .frame(width: 76, height: 46)
                    .background(Color(red: 0.94, green: 0.97, blue: 1), in: RoundedRectangle(cornerRadius: 10))
                    .accessibilityLabel("Answer for \(multiplicationTableNumber) times \(multiplier)")
                    .accessibilityIdentifier("table-answer-\(multiplier)")

                    if multiplicationTableChecked {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(isCorrect ? Color.green : Color.orange)
                            .frame(width: 24)
                    }
                }
                .padding(8)
                .background(
                    multiplicationTableChecked
                        ? (isCorrect ? Color.green.opacity(0.10) : Color.orange.opacity(0.10))
                        : Color.white,
                    in: RoundedRectangle(cornerRadius: 14)
                )
            }

            if let multiplicationTableFeedback {
                Text(multiplicationTableFeedback)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("table-feedback")
            }

            Button(action: checkMultiplicationTable) {
                Label("Check answers", systemImage: "checkmark.circle.fill")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("check-table-answers")
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private var answerCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Text("Your answer")
                    .font(.system(.headline, design: .rounded))
                Spacer()
                if !answerInput.isEmpty {
                    Button("Clear") {
                        answerInput = ""
                        feedbackMessage = nil
                        feedbackIsCorrect = nil
                    }
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                }
                Text(answerInput.isEmpty ? " " : answerInput)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color(red: 0.12, green: 0.23, blue: 0.42))
                    .frame(minWidth: 70, minHeight: 40, alignment: .trailing)
                    .padding(.horizontal, 10)
                    .background(Color(red: 0.94, green: 0.97, blue: 1), in: RoundedRectangle(cornerRadius: 10))
                    .accessibilityIdentifier("answer-display")
            }
            if problem.operation == .division {
                Text("Enter the quotient, tap R, then enter the remainder.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(1...9, id: \.self) { number in
                    numberButton("\(number)")
                }
                numberButton(problem.operation == .division ? "R" : (problem.answer < 0 ? "−" : "Clear"))
                numberButton("0")
                numberButton("⌫")
            }

            if let feedbackMessage {
                Text(feedbackMessage)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(feedbackIsCorrect == true ? Color.green : (feedbackIsCorrect == false ? Color.orange : Color.secondary))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("answer-feedback")
            }

            HStack(spacing: 10) {
                Button(action: checkAnswer) {
                    Label("Check answer", systemImage: "checkmark.circle.fill")
                        .font(.system(.headline, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("check-answer")

                Button(action: goToNextProblem) {
                    Image(systemName: "arrow.right")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .frame(width: 52, height: 50)
                }
                .buttonStyle(StepperButtonStyle())
                .accessibilityLabel("Next problem")
                .accessibilityIdentifier("next-problem")
            }
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private func numberButton(_ title: String) -> some View {
        Button {
            if title == "Clear" {
                answerInput = ""
            } else if title == "⌫" {
                if !answerInput.isEmpty {
                    answerInput.removeLast()
                }
            } else if title == "R" {
                if !answerInput.isEmpty && !answerInput.contains("R") {
                    answerInput.append("R")
                }
            } else if title == "−" {
                if answerInput.isEmpty {
                    answerInput = "-"
                }
            } else if answerInput.count < 8 {
                answerInput.append(contentsOf: title)
            }
            feedbackMessage = nil
            feedbackIsCorrect = nil
        } label: {
            Text(title)
                .font(.system(title.count > 1 ? .subheadline : .title3, design: .rounded, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color(red: 0.94, green: 0.97, blue: 1), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("key-\(title)")
    }

    private func checkAnswer() {
        guard !answerInput.isEmpty else {
            feedbackMessage = "Enter your answer using the number buttons."
            feedbackIsCorrect = nil
            return
        }

        let isCorrect = problem.isCorrect(answerInput)
        feedbackMessage = isCorrect ? "That's right! Great work!" : "Not quite. Use your work space and try again."
        feedbackIsCorrect = isCorrect
    }

    private func goToNextProblem() {
        if feedbackIsCorrect == true {
            makeNewProblem()
        } else {
            showSkipConfirmation = true
        }
    }

    private func makeNewProblem() {
        guard selectedMode != .multiplicationTable else { return }
        problem = MathProblem.generate(
            mode: selectedMode,
            firstDigitCount: firstDigitCount,
            secondDigitCount: secondDigitCount
        )
        answerInput = ""
        feedbackMessage = nil
        feedbackIsCorrect = nil
        strokes = []
        currentStroke = []
    }

    private func clearMultiplicationTableAnswers() {
        multiplicationTableAnswers = Array(repeating: "", count: 10)
        multiplicationTableChecked = false
        multiplicationTableFeedback = nil
    }

    private func checkMultiplicationTable() {
        let correctCount = multiplicationTableAnswers.enumerated().filter { item in
            Int(item.element) == multiplicationTableNumber * (item.offset + 1)
        }.count
        multiplicationTableChecked = true
        multiplicationTableFeedback = correctCount == 10
            ? "Perfect! All 10 answers are right!"
            : "You got \(correctCount) out of 10 right. Try the ones you missed!"
    }
}

private struct SettingsView: View {
    @Binding var selectedMode: PracticeMode
    @Binding var firstDigitCount: Int
    @Binding var secondDigitCount: Int
    @Binding var multiplicationTableNumber: Int

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.97, blue: 1)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Choose your practice")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.12, green: 0.23, blue: 0.42))
                        Text("Pick what to practice and set each number's size.")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("PICK YOUR PRACTICE")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(PracticeMode.allCases) { mode in
                                Button {
                                    selectedMode = mode
                                } label: {
                                    Text(mode.title)
                                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .frame(minHeight: 44)
                                        .padding(.vertical, 6)
                                        .background(selectedMode == mode ? Color.blue : Color.white)
                                        .foregroundStyle(selectedMode == mode ? .white : Color.primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("mode-\(mode.rawValue)")
                            }
                        }

                        if selectedMode == .multiplicationTable {
                            tableNumberPicker
                        } else {
                            digitPicker(title: "First number", digitCount: $firstDigitCount, identifier: "first")
                            digitPicker(title: "Second number", digitCount: $secondDigitCount, identifier: "second")
                        }
                    }
                    .padding(16)
                    .background(.white, in: RoundedRectangle(cornerRadius: 20))
                }
                .frame(maxWidth: 560)
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Setting")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 0.94, green: 0.97, blue: 1), for: .navigationBar)
    }

    private var tableNumberPicker: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Table number")
                    .font(.system(.headline, design: .rounded))
                Text("Choose a number from 1 to 10.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                multiplicationTableNumber = max(1, multiplicationTableNumber - 1)
            } label: {
                Image(systemName: "minus")
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(StepperButtonStyle())
            .accessibilityLabel("Decrease table number")
            .accessibilityIdentifier("table-number-decrease")
            .disabled(multiplicationTableNumber == 1)

            Text("\(multiplicationTableNumber)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .monospacedDigit()
                .frame(minWidth: 24)
                .accessibilityIdentifier("table-number")

            Button {
                multiplicationTableNumber = min(10, multiplicationTableNumber + 1)
            } label: {
                Image(systemName: "plus")
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(StepperButtonStyle())
            .accessibilityLabel("Increase table number")
            .accessibilityIdentifier("table-number-increase")
            .disabled(multiplicationTableNumber == 10)
        }
        .padding(.top, 2)
    }

    private func digitPicker(title: String, digitCount: Binding<Int>, identifier: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                Text("\(digitCount.wrappedValue) digit\(digitCount.wrappedValue == 1 ? "" : "s")")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                digitCount.wrappedValue = max(1, digitCount.wrappedValue - 1)
            } label: {
                Image(systemName: "minus")
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(StepperButtonStyle())
            .accessibilityLabel("Fewer digits for \(title.lowercased())")
            .accessibilityIdentifier("\(identifier)-digits-decrease")
            .disabled(digitCount.wrappedValue == 1)

            Text("\(digitCount.wrappedValue)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .monospacedDigit()
                .frame(minWidth: 24)
                .accessibilityIdentifier("\(identifier)-digit-count")

            Button {
                digitCount.wrappedValue = min(4, digitCount.wrappedValue + 1)
            } label: {
                Image(systemName: "plus")
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(StepperButtonStyle())
            .accessibilityLabel("More digits for \(title.lowercased())")
            .accessibilityIdentifier("\(identifier)-digits-increase")
            .disabled(digitCount.wrappedValue == 4)
        }
        .padding(.top, 2)
    }
}

private struct WorkArea: View {
    @Binding var strokes: [[CGPoint]]
    @Binding var currentStroke: [CGPoint]
    let problem: MathProblem

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.98, green: 0.99, blue: 1))
                Canvas { context, size in
                    for stroke in strokes + (currentStroke.isEmpty ? [] : [currentStroke]) {
                        guard let firstPoint = stroke.first else { continue }
                        var path = Path()
                        path.move(to: CGPoint(x: firstPoint.x * size.width, y: firstPoint.y * size.height))
                        for point in stroke.dropFirst() {
                            path.addLine(to: CGPoint(x: point.x * size.width, y: point.y * size.height))
                        }
                        context.stroke(
                            path,
                            with: .color(Color.blue.opacity(0.85)),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                    }
                }

                HStack {
                    Spacer(minLength: 0)
                    if problem.operation == .division {
                        LongDivisionEquation(dividend: problem.firstNumber, divisor: problem.secondNumber)
                    } else {
                        VStack(spacing: 4) {
                            VStack(alignment: .trailing, spacing: 0) {
                                Text("\(problem.firstNumber)")
                                    .tracking(4)
                                HStack(spacing: 12) {
                                    Text(problem.operation.symbol)
                                        .foregroundStyle(Color.blue)
                                    Text("\(problem.secondNumber)")
                                        .tracking(4)
                                }
                                Rectangle()
                                    .fill(Color(red: 0.23, green: 0.43, blue: 0.76))
                                    .frame(height: 3)
                                    .padding(.top, 4)
                                Color.clear
                                    .frame(height: 52)
                            }
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .frame(width: 240, alignment: .trailing)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, geometry.size.height * (problem.operation == .division ? 0.2 : 0.1))
                .allowsHitTesting(false)
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.blue.opacity(0.12), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .allowsHitTesting(false)
            }
            .contentShape(RoundedRectangle(cornerRadius: 14))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        currentStroke.append(
                            CGPoint(
                                x: value.location.x / geometry.size.width,
                                y: value.location.y / geometry.size.height
                            )
                        )
                    }
                    .onEnded { _ in
                        if !currentStroke.isEmpty {
                            strokes.append(currentStroke)
                            currentStroke = []
                        }
                    }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct LongDivisionEquation: View {
    let dividend: Int
    let divisor: Int

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("\(divisor)")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .tracking(3)

            DivisionBracket()
                .stroke(Color(red: 0.23, green: 0.43, blue: 0.76), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .frame(width: 175, height: 100)
                .overlay(alignment: .topLeading) {
                    Text("\(dividend)")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .tracking(3)
                        .padding(.leading, 17)
                        .padding(.top, 3)
                }
        }
        .foregroundStyle(Color(red: 0.12, green: 0.23, blue: 0.42))
        .monospacedDigit()
    }
}

private struct DivisionBracket: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.28))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.22, y: rect.minY),
            control1: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.1),
            control2: CGPoint(x: rect.minX + rect.width * 0.05, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}
private struct ExpandedCanvasView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var strokes: [[CGPoint]]
    @Binding var currentStroke: [CGPoint]
    let problem: MathProblem

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Show your work")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Spacer()
                Button("Clear") {
                    strokes = []
                    currentStroke = []
                }
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(StepperButtonStyle())
                .accessibilityLabel("Close expanded canvas")
            }

            WorkArea(strokes: $strokes, currentStroke: $currentStroke, problem: problem)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(16)
        .background(Color(red: 0.94, green: 0.97, blue: 1).ignoresSafeArea())
    }
}

private struct StepperButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded, weight: .bold))
            .foregroundStyle(configuration.isPressed ? Color.white : Color.blue)
            .background(configuration.isPressed ? Color.blue : Color(red: 0.91, green: 0.95, blue: 1), in: RoundedRectangle(cornerRadius: 12))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(configuration.isPressed ? Color(red: 0.12, green: 0.34, blue: 0.68) : Color.blue, in: RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

#Preview {
    ContentView()
}
