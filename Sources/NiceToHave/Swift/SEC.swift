import Foundation

// Conform to (S)endable, (E)quatable and (C)odable
public protocol SEC: Sendable, Equatable, Codable {}

// Conform to (S)endable, (E)quatable, (C)odable and Identifiable
public protocol SECI: SEC, Identifiable {}

public protocol SECH: Codable, Hashable, Equatable, Sendable {}
