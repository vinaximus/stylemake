# Stylemake v0.5 🎨

**Production Module for Garment Manufacturing Management**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)
[![Version](https://img.shields.io/badge/version-0.5.0-blue)](https://github.com/yourusername/stylemake/releases/tag/v0.5)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Setup](#setup)
- [Database Schema](#database-schema)
- [Usage](#usage)
- [Development](#development)
- [Documentation](#documentation)
- [Known Limitations](#known-limitations)
- [Roadmap](#roadmap)

## 🎯 Overview

Stylemake is a **mobile and web-friendly application** designed to manage the entire workflow of a garment manufacturing company — from **Cutting to Dispatch**.

### Current Version (v0.5)
- **Focus:** Production Module (Cutting to Finished Goods Receipt)
- **Platforms:** Android, iOS, Web
- **Architecture:** Flutter + Supabase + Riverpod
- **Status:** Production-ready MVP
- **Release Date:** October 2025

### What's Included

Stylemake v0.5 manages garment production workflow from **Cutting to Receipt of Finished Goods**:

✅ **Cutting Records** - Track cutting operations with style and quantity  
✅ **Fabrication Purchase Orders** - Issue POs to vendors for embroidery/stitching  
✅ **Item Issues** - Record items issued against POs  
✅ **Bills & Invoices** - Track supplier bills and costs  
✅ **Finished Goods Receipts** - Record received goods and generate reports  
✅ **Master Data Management** - Manage styles and vendors  
✅ **Real-time Sync** - Automatic updates across all devices  
✅ **CSV Export** - Export data for external analysis  
✅ **PDF Generation** - Print-ready PO documents  

### Future Modules (v1.0+)
- 📦 Fabric Management Module
- 🚚 Dispatch Module
- 👥 Multi-user Authentication
- 🏢 Multi-company SaaS Support
- 📊 Advanced Analytics Dashboard

## 🚀 Features

### Production Module

**Master Data:**
- Style Master (CRUD operations with search)
- Vendor Master (CRUD with city filtering)

**Production Workflow:**
- Create cutting records with style linkage
- Generate fabrication POs linked to cuttings
- Issue items to vendors with rate tracking
- Record supplier bills with auto-calculation
- Receive finished goods against cuttings
- Production summary reports with CSV export

**Real-time Capabilities:**
- Automatic list updates when data changes
- Multi-tab synchronization
- Live data refresh without manual reload

**Export & Reporting:**
- CSV export for Cuttings, POs, and Receipts
- PDF generation for Purchase Orders
- Production summary with cost analysis
- Date range and style-based filtering

**Error Monitoring:**
- Firebase Crashlytics integration
- User-friendly error messages
- Automatic error reporting

**Performance:**
- Lists load < 2 seconds (500 records)
- Optimized database queries
- Performance monitoring built-in

## ⚡ Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd stylemake

# Install dependencies
flutter pub get

# Set up environment variables
cp .env.example .env
# Edit .env with your Supabase credentials

# Run the app
flutter run -d chrome  # For web
flutter run             # For mobile
```

## 🔧 Setup

### Prerequisites

| Requirement | Version | Notes |
|------------|---------|-------|
| Flutter SDK | 3.9.2+ | [Install Flutter](https://flutter.dev/docs/get-started/install) |
| Dart SDK | 3.9.2+ | Included with Flutter |
| Supabase Account | - | [Sign up free](https://supabase.com) |
| Android Studio | Latest | For Android development |
| Xcode | Latest | For iOS development (macOS only) |

### Environment Variables

Create a `.env` file in the project root:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**Security Note:** Never commit `.env` to version control. Use `.env.example` as a template.

### Installation Steps

**Step 1: Install Flutter**
```bash
# Verify Flutter installation
flutter doctor

# Should show Flutter SDK 3.9.2 or higher
```

**Step 2: Clone and Install Dependencies**
```bash
git clone <repository-url>
cd stylemake
flutter pub get
```

**Step 3: Database Setup**

1. **Create Supabase Project:**
   - Go to [https://supabase.com](https://supabase.com)
   - Click "New Project"
   - Name: "Stylemake"
   - Set a secure database password
   - Select region closest to your users
   - Wait for project to be ready (~2 minutes)

2. **Get Credentials:**
   - Go to Project Settings → API
   - Copy "Project URL" and "anon public" key
   - Update `.env` file with these values

3. **Run Migrations:**
   - Open Supabase SQL Editor
   - Run migrations in order:
     1. `migrations/001_create_base_tables.sql`
     2. `migrations/002_add_indexes_and_constraints.sql`
     3. `migrations/003_seed_master_data.sql`
   - Each migration should complete without errors

4. **Verify Database:**
   ```bash
   dart scripts/verify_backup.dart
   ```
   Should show 3 styles, 3 vendors, 0 other records

**Step 4: Firebase Setup (Optional)**

For error monitoring, set up Firebase Crashlytics:
- See [docs/firebase_setup.md](docs/firebase_setup.md) for complete instructions
- App works without Firebase, but monitoring is recommended for production

**Step 5: Run the App**

```bash
# For web development
flutter run -d chrome

# For Android
flutter run -d android

# For iOS (macOS only)
flutter run -d ios

# Production build
flutter build apk           # Android
flutter build ios           # iOS
flutter build web          # Web
```

## 🗄️ Database Schema

### Core Tables

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `styles` | Style master data | id, name, company_id |
| `vendors` | Vendor master data | id, name, gst, city, company_id |
| `cuttings` | Cutting records | id, cutting_ref, style_id, quantity_cut, cutting_date |
| `fabrication_pos` | Purchase orders | id, po_number, cutting_id, vendor_id, quantity_issued, rate_per_unit |
| `item_issues` | Items issued | id, po_id, item_description, quantity, rate |
| `bills` | Supplier bills | id, po_id, supplier_invoice_no, quantity, rate |
| `receipts` | Finished goods | id, cutting_id, style_id, quantity_received |

### Default Values

For v0.5 (single-company mode):
- `company_id`: `00000000-0000-0000-0000-000000000000`
- `user_id`: `00000000-0000-0000-0000-000000000000`

See [docs/database_schema_reference.md](docs/database_schema_reference.md) for complete schema.

## 📖 Usage

### Quick Workflow Guide

**1. Set Up Master Data**
   - Navigate to "Masters" tab
   - Add Styles (e.g., "Summer Shirt", "Winter Jacket")
   - Add Vendors with contact details

**2. Create Cutting Record**
   - Go to "Production" → "Cuttings"
   - Click "+" to add new cutting
   - Enter cutting reference, date, style, and quantity

**3. Issue Purchase Order**
   - Open the cutting record
   - Click "Create PO"
   - Select vendor, enter job details, qty, and rate
   - PO is automatically numbered

**4. Issue Items (Optional)**
   - Open PO detail
   - Click "Issue Items"
   - Add materials/items issued to vendor

**5. Record Bill**
   - Open PO detail
   - Click "Add Bill"
   - Enter supplier invoice details

**6. Receive Finished Goods**
   - Go to "Receipts"
   - Click "+" to add receipt
   - Select cutting, enter quantity received

**7. Generate Reports**
   - Go to "Reports" → "Production Summary"
   - Select date range and style
   - View KPIs and export CSV

For detailed user guide with screenshots, see [docs/user_guide.md](docs/user_guide.md).

## 💻 Development

### Project Structure

```
stylemake/
├── lib/
│   ├── core/                 # Core functionality
│   │   ├── models/          # Data models
│   │   ├── repositories/    # Database access
│   │   ├── services/        # Business services
│   │   ├── providers/       # Riverpod providers
│   │   ├── widgets/         # Reusable widgets
│   │   └── utils/           # Utilities
│   ├── features/            # Feature modules
│   │   ├── masters/        # Style & Vendor masters
│   │   ├── production/     # Production workflows
│   │   └── reports/        # Reporting
│   └── main.dart           # App entry point
├── migrations/             # Database migrations
├── docs/                   # Documentation
└── test/                   # Test files
```

### Commands

```bash
# Development
flutter run -d chrome              # Run web dev server
flutter run --release             # Run release build

# Code Quality
flutter format .                  # Format code
dart analyze                      # Static analysis
flutter test                      # Run tests

# Build
flutter build apk --release       # Android APK
flutter build appbundle          # Android App Bundle
flutter build ios                # iOS build
flutter build web                # Web build

# Database
dart scripts/verify_backup.dart   # Verify database

# Performance
flutter run --profile            # Profile mode
```

### Branch Strategy

- `main` - Production releases only
- `develop` - Integration branch
- `fluent_integration` - Fluent UI features
- `feature/*` - Feature branches
- `hotfix/*` - Production hotfixes

### Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/features/masters/style_repository_test.dart

# Test with coverage
flutter test --coverage
```

## 📚 Documentation

### User & Setup Guides
- [User Guide](docs/user_guide.md) - Complete user manual with workflows
- [Database Setup Guide](docs/database_setup.md) - Database configuration
- [Database Schema Reference](docs/database_schema_reference.md) - Complete schema
- [Firebase Setup](docs/firebase_setup.md) - Crashlytics configuration

### Release & Technical Documentation
- [Release Guide v0.5](docs/release_guide_v0.5.md) - Complete release documentation
- [Release Checklist](docs/RELEASE_CHECKLIST.md) - Quick release reference
- [Release Notes v0.5](RELEASE_NOTES_v0.5.md) - Official release notes
- [Post-Release Monitoring](docs/post_release_monitoring.md) - 48-hour monitoring plan
- [Sanity Test Checklist](docs/sanity_test_checklist.md) - Testing procedures
- [Performance Report](docs/performance_report.md) - Performance benchmarks

### Planning & Requirements
- [Product Requirements Document (PRD)](docs/prd.md) - Original requirements
- [TODO Tracking](docs/stylemake_v0.5_todo.md) - Development checklist

### Historical & Future
- [Implementation History](docs/archive/implementation_history/) - Phase 0-12 summaries
- [Future Features](docs/future_features/) - Planned features and roadmap

## ⚠️ Known Limitations

### v0.5 Scope

- **Single User:** No authentication (planned for v0.6)
- **Single Company:** One company per installation
- **No Offline Mode:** Requires internet connection
- **Basic Reporting:** CSV export only (no Excel/PDF reports)
- **Web Download:** CSV download on web is basic (mobile works fully)

### Performance

- Lists optimized for up to 500 records
- Real-time sync refetches entire list (not incremental)
- No pagination (use filters for large datasets)

### Data Integrity

- No cascade delete protection in UI (handle with care)
- Manual data entry only (no import functionality yet)

See [GitHub Issues](https://github.com/yourusername/stylemake/issues) for known bugs.

## 🗺️ Roadmap

### v0.6 (Q1 2026)
- User authentication (Supabase Auth)
- Role-based access control
- User profile management
- Activity logging

### v0.7 (Q2 2026)
- Multi-company support
- Company-level data isolation
- Subscription management

### v1.0 (Q3 2026)
- Fabric Management Module
- Dispatch Module
- Advanced analytics
- Mobile app stores release

## 📄 License

Proprietary - All rights reserved © 2025

## 🤝 Support

For support, bug reports, or feature requests:
- Email: support@stylemake.com
- GitHub Issues: [Report a bug](https://github.com/yourusername/stylemake/issues)
- Documentation: [docs/](docs/)

## 👏 Acknowledgments

Built with:
- [Flutter](https://flutter.dev) - Google's UI toolkit
- [Supabase](https://supabase.com) - Open source Firebase alternative
- [Riverpod](https://riverpod.dev) - State management
- [Material Design 3](https://m3.material.io) - Design system

---

**Version:** 0.5.0  
**Status:** Production Ready  
**Last Updated:** October 2025

