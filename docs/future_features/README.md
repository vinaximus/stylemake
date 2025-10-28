# Future Features & Roadmap

This directory contains plans and documentation for features planned for future versions of Stylemake.

## Purpose

These documents outline:
- Features not included in v0.5
- Implementation plans for future releases
- Exploratory work and research
- Design system alternatives

## Contents

### Fluent Design Integration

**Status:** Explored but not implemented in v0.5

| File | Description |
|------|-------------|
| fluent_integration_plan.md | Complete plan for Microsoft Fluent Design System integration |
| fluent_integration_implementation_summary.md | Implementation details (proof of concept) |

**Overview:**
The Fluent Design integration provides a native Windows 11-style desktop experience while maintaining Material 3 for mobile platforms. This work was explored during development but Material 3 was chosen as the primary design system for v0.5.

**Target Release:** v0.7 or v1.0 (to be determined)

**Key Features:**
- Platform detection (desktop vs mobile)
- Fluent Design components (buttons, cards, navigation)
- Windows 11 styling for desktop
- Seamless transition between design systems

## Roadmap

### v0.6 (Q1 2026) - Authentication
- User authentication (Supabase Auth)
- Role-based access control
- User profile management
- Activity logging

### v0.7 (Q2 2026) - Multi-company
- Multi-company support
- Company-level data isolation
- Subscription management
- **Possible:** Fluent Design for desktop

### v1.0 (Q3 2026) - Complete Suite
- Fabric Management Module
- Dispatch Module
- Advanced analytics
- Mobile app stores release
- Offline mode with sync
- **Possible:** Fluent Design integration

## Contributing

When planning new features:
1. Create a detailed plan document (see fluent_integration_plan.md as template)
2. Add to this directory
3. Update this README with the feature entry
4. Link to roadmap in main README.md

---

**Note:** Features in this directory are NOT in v0.5. For current features, see `README.md` and `RELEASE_NOTES_v0.5.md`.

