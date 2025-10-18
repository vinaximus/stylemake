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

### Database Setup

Stylemake uses Supabase for the backend database. Follow these steps to set up your database:

1. **Create a Supabase Project:**
   - Sign up at [https://supabase.com](https://supabase.com)
   - Create a new project
   - Save your project URL and anon key

2. **Configure Environment Variables:**
   - Copy `.env.example` to `.env`
   - Update with your Supabase credentials:
     ```env
     SUPABASE_URL=https://your-project-id.supabase.co
     SUPABASE_ANON_KEY=your-anon-key-here
     ```

3. **Run Database Migrations:**
   - Open Supabase SQL Editor from your project dashboard
   - Run each migration file in order:
     1. `migrations/001_create_base_tables.sql`
     2. `migrations/002_add_indexes_and_constraints.sql`
     3. `migrations/003_seed_master_data.sql`
   
4. **Verify Setup:**
   - Run the app - it should show "Database Connected" with style count of 3
   - See [docs/database_setup.md](docs/database_setup.md) for detailed instructions

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

