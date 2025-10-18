# Stylemake v0.5

## Overview

Stylemake is a mobile and web-friendly application designed to manage the entire workflow of a garment manufacturing company — from **Fabric management to Dispatch**.

### Current Version (v0.5)
- **Focus:** Production Module
- **Platforms:** Android, iOS, and Web
- **Tech Stack:** Flutter + Supabase + Riverpod

## Purpose

Stylemake v0.5 manages garment production workflow from **Cutting to Receipt of Finished Goods**, including:
- Cutting Records
- Fabrication Purchase Orders (PO)
- Item Issue Records
- Bills Issued Against PO
- Receipts of Finished Goods
- Masters (Style Master & Vendor Master)

## Features

### Production Module
- ✅ Manage cutting records with style tracking
- ✅ Issue fabrication POs to vendors (embroidery/stitching)
- ✅ Track item issues against POs
- ✅ Record supplier bills and invoices
- ✅ Receive finished goods and generate production reports
- ✅ Master data management (Styles & Vendors)

### Future Modules (v1.0+)
- Fabric Management
- Dispatch Module
- Multi-user authentication
- Multi-company SaaS support

## Architecture

- **Frontend:** Flutter (Material 3 Design)
- **Backend:** Supabase (Database + Authentication + Storage)
- **State Management:** Riverpod
- **Language:** Dart

## Setup

### Prerequisites
- Flutter SDK (3.x or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Supabase account

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd stylemake

# Install dependencies
flutter pub get

# Configure environment variables
cp .env.example .env
# Edit .env with your Supabase credentials

# Run the app
flutter run -d chrome  # For web
flutter run             # For mobile (connected device/emulator)
```

## Development

### Branch Strategy
- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - Feature branches

### Commands

```bash
# Format code
flutter format .

# Analyze code
dart analyze

# Run tests
flutter test
```

## Version Information

| Field | Detail |
|-------|--------|
| **App Version** | v0.5 |
| **Release Date** | October 2025 |
| **Status** | Production Module MVP |

## License

Proprietary - All rights reserved

## Contact

For support or inquiries, please contact the development team.

