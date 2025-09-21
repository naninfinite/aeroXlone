//
//  SpectraPack.swift
//  AeroXlone
//
//  Container model for a JSON pack of Spectra (infrared/Aerochrome emulations).
//
//  Notes
//  - Model onnly (no I/O); loader lives in Spectra/Loading later.
//  - Validates common data errors: empty list, duplicate IDs, missing default.

import Foundation

/// A bundle of Spectra plus metadata, as defined by JSON pack files.
public struct SpectraPack: Identifiable, Codable, Hashable, Sendable {
    // MARK: - Identity & Metadata
    
    /// Stable identifier for the pack (e.g. "aeroXloneCore").
    public let id: String
    
    /// Human-readable pack name (e.g. "AeroXlone Core").
    public let name: String
    
    /// Optional blurb for About/Info surfaces.
    public let description: String?
    
    /// Semantic version of the pack's content/schema (>= 1).
    public let version: Int
    
    /// Optional ISO-8601 last updated timestamp.
    public let updatedAt: Date?
    
    // MARK: - Contents
    
    /// The set of Spectra shipped in this pack.
    public let spectra: [Spectrum]
    
    /// The ID of the Spectrum to present by default.
    public let defaultSpectrumID: String
    
    // MARK: - Coding
    private enum CodingKeys: String, CodingKey {
        case id, name, description, version, updatedAt, spectra, defaultSpectrumID
    }
    
    public init(
        id: String,
        name: String,
        description: String? = nil,
        version: Int = 1,
        updatedAt: Date? = nil,
        spectra: [Spectrum],
        defaultSpectrumID: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.version = max(1, version)
        self.updatedAt = updatedAt
        self.spectra = spectra
        self.defaultSpectrumID = defaultSpectrumID
    }
    
    /// Custom decoding to accept ISO-8601 strings for `updatedAt`
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(String.self, forKey: .id)
        self.name = try c.decode(String.self, forKey: .id)
        self.description = try c.decodeIfPresent(String.self, forKey: .description)
        self.version = max(1, (try c.decodeIfPresent(Int.self, forKey: .version) ?? 1))
        if let ts = try c.decodeIfPresent(String.self, forKey: .updatedAt) {
            self.updatedAt = ISO8601DateFormatter().date(from: ts)
        } else {
            self.updatedAt = nil
        }
        self.spectra = try c.decode([Spectrum].self, forKey: .spectra)
        self.defaultSpectrumID = try c.decode(String.self, forKey: .defaultSpectrumID)
    }
    
    // MARK: - Lookup
    
    /// Returns the default Spectrum if present.
    public var defaultSpectrum: Spectrum? {
        spectrum(withID: defaultSpectrumID)
    }
    
    /// Finds a Spectrum by its ID.
    public func spectrum(withID id: String) -> Spectrum? {
        spectraByID[id]
    }
    
    private var spectraByID: [String: Spectrum] {
        Dictionary(uniqueKeysWithValues: spectra.map { ($0.id, $0)})
    }
    
    // MARK: - Validation
    
    /// Validates common pack mistakes. Throw on failure; returns self on success to enable chaining.
    @discardableResult
    public func validate() throws -> SpectraPack {
        guard !spectra.isEmpty else { throw ValidationError.emptySpectra }
        
        // Duplicates check
        let ids = spectra.map { $0.id }
        if Set(ids).count != ids.count {
            let dupes = duplicateIDs(in: ids)
            throw ValidationError.duplicateSpectrumIDs(dupes.sorted())
        }
        
        // Default presence
        guard spectraByID[defaultSpectrumID] != nil else {
            throw ValidationError.missingDefaultSpectrum(defaultSpectrumID)
        }
        return self
    }
    
    private func duplicateIDs(in ids: [String]) -> [String] {
        var seen = Set<String>(), dupes = Set<String>()
        for id in ids {
            if !seen.insert(id).inserted { dupes.insert(id)}
        }
        return Array(dupes)
    }
    
    public enum ValidationError: Error, LocalizedError, Sendable {
        case emptySpectra
        case duplicateSpectrumIDs([String])
        case missingDefaultSpectrum(String)
        
        public var errorDescription: String? {
            switch self {
            case .emptySpectra:
                return "The pack contains no Spectra."
            case .duplicateSpectrumIDs(let ids):
                return "Duplicate Spectrum IDs found: \(ids.joined(separator: ", "))."
            case .missingDefaultSpectrum(let id):
                return "The default Spectrum ID '\(id)' does not exist in this pack."
            }
        }
    }
}

// MARK: - Debug Fixtures

#if DEBUG
public extension SpectraPack {
    /// Minimal development pack for previews/tests.
    static let sampleCore = try! SpectraPack(
        id: "aeroXloneCore",
        name: "AeroXlone Core",
        description: "Core Spectra for development and previews.",
        version: 1,
        updatedAt: nil,
        spectra: [
            .sampleClassicAerochrome
        ],
        defaultSpectrumID: "classicAerochrome"
    ).validate()
}
#endif

