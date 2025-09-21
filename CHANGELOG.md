# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]

## [2025-09-21]
### Added
- `Spectrum` model with nested `Params` and `Preset`:
	- Codable/Sendable, lower-camel JSON keys
	- Safe clamping for all tunables (intensity, exposureEV, contrast, saturation, temperature, tint, bloomAmount, skinProtect)
	- Debug fixture: `Spectrum.sampleClassicAerochrome`
