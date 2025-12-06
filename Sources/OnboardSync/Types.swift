//
//  Types.swift
//  OnboardSync
//
//  Created by OnboardSync on 2025-01-19.
//

import Foundation

/// A single question response from the onboarding flow.
///
/// This represents the user's answer to a single question in the
/// onboarding flow. The `answer` type depends on the question type:
/// - For text input questions: String
/// - For single choice questions: String
/// - For multiple choice questions: Array of Strings
/// - For picker questions: Array of Strings (e.g., ["175"] for height, ["June", "15", "1995"] for date)
public struct OnboardingResponse: Codable {
    /// The text of the question that was asked
    public let questionText: String
    
    /// The type of question: 'question_text', 'question_single_choice', 'question_multiple_choice', or 'question_picker'
    public let questionType: String
    
    /// The user's answer. Can be a String or [String] depending on question type.
    public let answer: OnboardingAnswer
    
    /// The screen ID where this question appeared (optional)
    public let screenId: String?
    
    /// The measurement unit for height/weight pickers: 'metric' or 'imperial' (optional)
    public let unit: String?
    
    public init(questionText: String, questionType: String, answer: OnboardingAnswer, screenId: String? = nil, unit: String? = nil) {
        self.questionText = questionText
        self.questionType = questionType
        self.answer = answer
        self.screenId = screenId
        self.unit = unit
    }
    
    /// Returns the answer as a String (for text and single choice questions)
    public var answerAsString: String? {
        switch answer {
        case .string(let value):
            return value
        case .array(let values):
            return values.first
        }
    }
    
    /// Returns the answer as an array of Strings (for multiple choice questions)
    public var answerAsList: [String] {
        switch answer {
        case .string(let value):
            return [value]
        case .array(let values):
            return values
        }
    }
    
    /// Whether this response is from a picker question
    public var isPicker: Bool {
        questionType == "question_picker"
    }
    
    /// Whether this response uses metric units (for height/weight pickers)
    public var isMetric: Bool {
        unit == "metric"
    }
    
    /// Whether this response uses imperial units (for height/weight pickers)
    public var isImperial: Bool {
        unit == "imperial"
    }
}

/// Represents an answer that can be either a single string or an array of strings
public enum OnboardingAnswer: Codable {
    case string(String)
    case array([String])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let arrayValue = try? container.decode([String].self) {
            self = .array(arrayValue)
        } else {
            throw DecodingError.typeMismatch(OnboardingAnswer.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected String or [String]"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .array(let values):
            try container.encode(values)
        }
    }
}

/// Contains all form responses from a completed onboarding flow.
///
/// This object is passed to the `OnboardingCompleteCallback` when the user
/// finishes the onboarding flow, allowing you to access all the responses
/// the user provided to questions in the flow.
///
/// Example usage:
/// ```swift
/// OnboardSync.showOnboarding(
///     config: OnboardSyncConfig(
///         projectId: "xxx",
///         secretKey: "xxx",
///         onComplete: { result in
///             if let result = result {
///                 for response in result.responses {
///                     print("\(response.questionText): \(response.answer)")
///                 }
///             }
///         }
///     )
/// )
/// ```
public struct OnboardingResult: Codable {
    /// The ID of the completed flow
    public let flowId: String
    
    /// All responses from the onboarding flow
    public let responses: [OnboardingResponse]
    
    public init(flowId: String, responses: [OnboardingResponse]) {
        self.flowId = flowId
        self.responses = responses
    }
    
    /// Gets a response by matching the question text (case-insensitive)
    public func getResponseByQuestion(_ questionText: String) -> OnboardingResponse? {
        responses.first { $0.questionText.lowercased() == questionText.lowercased() }
    }
    
    /// Gets all text input responses
    public var textResponses: [OnboardingResponse] {
        responses.filter { $0.questionType == "question_text" }
    }
    
    /// Gets all single choice responses
    public var singleChoiceResponses: [OnboardingResponse] {
        responses.filter { $0.questionType == "question_single_choice" }
    }
    
    /// Gets all multiple choice responses
    public var multipleChoiceResponses: [OnboardingResponse] {
        responses.filter { $0.questionType == "question_multiple_choice" }
    }
    
    /// Gets all choice responses (single + multiple)
    public var choiceResponses: [OnboardingResponse] {
        responses.filter { $0.questionType == "question_single_choice" || $0.questionType == "question_multiple_choice" }
    }
    
    /// Gets all picker responses (height, weight, date, custom pickers)
    public var pickerResponses: [OnboardingResponse] {
        responses.filter { $0.questionType == "question_picker" }
    }
    
    /// Whether this result contains any responses
    public var hasResponses: Bool {
        !responses.isEmpty
    }
    
    /// The number of responses
    public var responseCount: Int {
        responses.count
    }
}

/// Callback triggered when onboarding is completed
/// - Parameter result: Optional OnboardingResult containing form responses, or nil if no questions were answered
public typealias OnboardingCompleteCallback = (_ result: OnboardingResult?) -> Void

/// Configuration for the OnboardSync SDK
public struct OnboardSyncConfig {
    /// Your OnboardSync project ID
    public let projectId: String
    
    /// Your OnboardSync secret key
    public let secretKey: String
    
    /// If true, shows onboarding every time regardless of completion status
    public let testingEnabled: Bool
    
    /// Optional callback when onboarding completes
    public let onComplete: OnboardingCompleteCallback?
    
    public init(projectId: String, 
                secretKey: String, 
                testingEnabled: Bool = false,
                onComplete: OnboardingCompleteCallback? = nil) {
        self.projectId = projectId
        self.secretKey = secretKey
        self.testingEnabled = testingEnabled
        self.onComplete = onComplete
    }
}

/// Response from the global config endpoint
internal struct ConfigResponse: Codable {
    let backendDomain: String
}

/// Response from the flow resolution endpoint
internal struct FlowResolutionResponse: Codable {
    let flowId: String
}