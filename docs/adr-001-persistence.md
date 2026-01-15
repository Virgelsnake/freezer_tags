# ADR 001: Persistence Layer - Core Data vs SwiftData

**Status:** Accepted  
**Date:** January 15, 2026  
**Decision Makers:** Development Team

## Context

The Freezer Tag Tracker app requires local data persistence to store container records. Two primary options are available:

1. **SwiftData** - Modern, declarative persistence framework introduced in iOS 17
2. **Core Data** - Mature, battle-tested persistence framework available since iOS 3

## Decision

**We will use Core Data for the prototype.**

## Rationale

### Factors Considered

**SwiftData Advantages:**
- Modern, cleaner API with less boilerplate
- Better integration with SwiftUI
- Declarative model definitions using macros
- Simpler setup and configuration

**SwiftData Disadvantages:**
- Requires iOS 17+ (limits device compatibility)
- Newer framework with less community resources
- May have undiscovered edge cases

**Core Data Advantages:**
- Supports iOS 13+ (broader device compatibility)
- Mature, well-documented framework
- Extensive community knowledge and troubleshooting resources
- Proven reliability in production apps

**Core Data Disadvantages:**
- More boilerplate code required
- Steeper learning curve
- More complex setup

### Decision Factors

1. **Device Compatibility:** Target iOS 15.0+ allows testing on more physical devices, which is critical for NFC validation
2. **Prototype Stability:** Core Data's maturity reduces risk of framework-related issues during prototype phase
3. **Known Patterns:** Well-established patterns for Core Data implementation reduce development uncertainty
4. **Migration Path:** If needed, Core Data can be migrated to SwiftData in future versions

## Consequences

### Positive
- Broader device support for physical NFC testing
- Reduced risk of framework-related bugs
- Access to extensive documentation and examples

### Negative
- More boilerplate code to write and maintain
- Less "modern" code patterns compared to SwiftData

### Mitigation
- Implement a clean DataStore abstraction layer to isolate Core Data details
- Design for potential future migration to SwiftData if the app moves to production

## Implementation Notes

- Use Core Data with in-memory store option for unit testing
- Implement singleton DataStore pattern for easy access
- Keep Core Data logic isolated in Persistence layer
- Use ContainerRecord as the primary model, with ContainerEntity as Core Data backing
