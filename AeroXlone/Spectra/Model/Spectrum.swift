//
//  Spectrum.swift
//  AeroXlone
//
//  Role: Core model representing a single infrared look ("Spectrum").
//  Invariants:
//  - JSON keys are lowerCamelCase.
//  - intensity range gate is 0.40...1.00 for MVP (see clamp()).
//  - lutPath points to a .cube file within bundle resources.
//  - digest may be "TBD" during development; compare skipped when "TBD.

import Foundation

/// Represents one infrared emulation look in AeroXlone.
/// Backed by JSON in Spectra/Resources/Packs/*.spectrum.json.
public struct Spectrum: Codable, Equatable, Hashable, Identifiable {
    
    // MARK: - Identity
    public let id: String               // e.g., "AeroXloneClassic"
    public let displayName: String      // e.g., "Classic Aerochrome"
    public let summary: String          // short UI description
    
    // MARK: - Resources
    /// Example: "Spectra/Resources/Packs/LUTs/AeroXloneClassic_33.cube"
    public let lutPath: String
    /// Optional digest (e.g., SHA-256) for LUT validation; "TBD" means skip.
    public let lutDigest: String?
    
    // MARK: - Paremeters
    /// Default intensity for this Spectrum. Must be within 0.40...1.00.
    public let defaultIntensity: Double
    /// Optional tone curve parameters (placeholder for MVP).
    public let toneCurve: ToneCurveParams?
    /// Optional named presets a user can pick quickly.
    public let presets: [SpectrumPreset]?
    
    //MARK: - Runtime Helpers
    /// Clamp any intensity into the accepted MVP band (0.40...1.00).
    public static func clamp(_ value: Double) -> Double {
        min(1.0, max(0.40, value))
    }
    
    /// Whether the LUT digest is usable for validation.
    public var hasUsableDigest: Bool {
        guard let d = lutDigest?.trimmingCharacters(in: .whitespacesAndNewlines),
              !d.isEmpty else { return false}
        return d.uppercased() != "TBD"
    }
}

// MARK: - ToneCurveParams

/// Placeholder tone curve model for MVP (expandable).
public struct ToneCurveParams: Codable, Equatable, Hashable {
    /// Typical range 0.0...2.0; 1.0 = neutral.
    public let lift: Double
    public let gamma: Double
    public let gain: Double
    
    public init(lift: Double = 1.0, gamma: Double = 1.0, gain: Double = 1.0) {
        self.lift = lift
        self.gamma = gamma
        self.gain = gain
    }
}

// MARK: - SpectrumPreset

/// A named preset of parameters for a Spectrum.
public struct SpectrumPreset: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let intensity: Double
    public let toneCurve: ToneCurveParams?
    
    public init(id: String, name: String, intensity: Double, toneCurve: ToneCurveParams? = nil) {
        self.id = id
        self.name = name
        self.intensity = Spectrum.clamp(intensity)
        self.toneCurve = toneCurve
    }
}

