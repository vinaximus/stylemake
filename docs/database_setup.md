# Database Setup Guide - Stylemake v0.5

This guide walks you through setting up the Supabase database for the Stylemake Production Module.

---

## Prerequisites

- A Supabase account (free tier is sufficient for development)
- Your Supabase project URL and anon key

---

## Step 1: Create or Access Your Supabase Project

1. Go to [https://supabase.com](https://supabase.com) and sign in
2. If you don't have a project yet:
   - Click "New Project"
   - Choose your organization
   - Enter a project name (e.g., "stylemake-dev")
   - Set a secure database password (save this!)
   - Select a region closest to you
   - Click "Create new project"
   - Wait 2-3 minutes for provisioning

3. Once your project is ready, go to **Settings > API** and note:
   - **Project URL** (looks like `https://xxxxx.supabase.co`)
   - **Anon/Public Key** (starts with `eyJ...`)

---

## Step 2: Configure Environment Variables

1. Open your `.env` file in the project root (copy from `.env.example` if needed)
2. Update with your Supabase credentials:

```env
SUPABASE_URL=https://your-actual-project-id.supabase.co
SUPABASE_ANON_KEY=your-actual-anon-key-here
```

3. Save the file

---

## Step 3: Run Database Migrations

Open the **SQL Editor** in your Supabase dashboard (left sidebar).

### Migration 1: Create Base Tables

1. Click **New Query**
2. Copy the entire contents of `migrations/001_create_base_tables.sql`
3. Paste into the SQL editor
4. Click **Run** (or press Ctrl+Enter)
5. Verify: You should see "Success. No rows returned" (this is correct)

**What this creates:**
- 7 tables: `styles`, `vendors`, `cuttings`, `fabrication_pos`, `item_issues`, `bills`, `receipts`
- All tables have `company_id` and `user_id` with default values for single-user mode
- Auto-update triggers for `updated_at` timestamps

### Migration 2: Add Indexes and Constraints

1. Click **New Query** again
2. Copy the entire contents of `migrations/002_add_indexes_and_constraints.sql`
3. Paste into the SQL editor
4. Click **Run**
5. Verify: You should see "Success. No rows returned"

**What this adds:**
- Foreign key relationships between tables
- Unique constraints on reference numbers
- Performance indexes on frequently queried columns
- Multi-tenancy indexes on `company_id`

### Migration 3: Seed Master Data

1. Click **New Query** again
2. Copy the entire contents of `migrations/003_seed_master_data.sql`
3. Paste into the SQL editor
4. Click **Run**
5. Verify: You should see "Success. No rows returned" or "3 rows inserted"

**What this inserts:**
- 3 test styles: T-Shirt Basic, Polo Shirt, Hoodie
- 3 test vendors with realistic Indian GST numbers and addresses

---

## Step 4: Verify Database Setup

Run these verification queries in the SQL Editor:

### Check All Tables Exist

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

**Expected result:** 7 tables listed (bills, cuttings, fabrication_pos, item_issues, receipts, styles, vendors)

### Check Styles Data

```sql
SELECT id, name, created_at 
FROM styles 
ORDER BY name;
```

**Expected result:** 3 rows (Hoodie, Polo Shirt, T-Shirt Basic)

### Check Vendors Data

```sql
SELECT id, name, city, gst 
FROM vendors 
ORDER BY name;
```

**Expected result:** 3 rows with vendor details

### Check Foreign Key Constraints

```sql
SELECT
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name;
```

**Expected result:** 7 foreign key relationships

---

## Database Schema Overview

### Table Relationships

```
styles (Master)
  ├─→ cuttings (cutting_date, quantity_cut, notes)
  │     ├─→ fabrication_pos (PO to vendors)
  │     │     ├─→ item_issues (items issued under PO)
  │     │     └─→ bills (supplier invoices)
  │     └─→ receipts (finished goods received)
  │
vendors (Master)
  └─→ fabrication_pos (POs issued to vendors)
```

### Core Entities

1. **Styles** - Master data for garment styles
2. **Vendors** - Master data for fabrication vendors
3. **Cuttings** - Production cutting records
4. **Fabrication POs** - Purchase orders to vendors (Embroidery or Stitching & Finishing)
5. **Item Issues** - Materials/items issued under a PO
6. **Bills** - Supplier invoices against POs
7. **Receipts** - Finished goods received from production

### Key Features

- **Multi-tenancy Ready:** All tables have `company_id` (defaulting to a zero UUID in v0.5)
- **Auto-timestamps:** `created_at` and `updated_at` managed automatically
- **Data Integrity:** Foreign keys with appropriate CASCADE/RESTRICT rules
- **Performance:** Indexes on commonly queried columns and dates
- **Validation:** CHECK constraints on quantities, rates, and dates

---

## Testing the Connection from Flutter

After completing the migrations:

1. Ensure your `.env` file has the correct credentials
2. Run the Flutter app:
   ```bash
   flutter run -d chrome
   ```
3. The home screen should show a connection status
4. If successful, it will display the number of styles in the database (should be 3)

---

## Common Issues & Troubleshooting

### "relation does not exist" error
- Make sure you ran migration 001 first
- Check you're in the correct Supabase project

### Foreign key constraint errors
- Ensure migration 001 completed successfully before running 002
- Verify all tables exist using the verification query above

### Connection timeout from Flutter
- Double-check your SUPABASE_URL in `.env` (no trailing slash)
- Verify your SUPABASE_ANON_KEY is correct (should be very long)
- Check your internet connection
- Ensure Supabase project is active (not paused)

### "No rows returned" but expected data
- For seed data, run migration 003
- Check you're looking at the correct Supabase project

---

## Next Steps

Once your database is set up and verified:

1. ✅ Test the Flutter app connection
2. ✅ Proceed to Phase 2: Shared UI components
3. ✅ Start building the Masters screens (Style & Vendor CRUD)

---

## Rolling Back (If Needed)

If you need to start fresh, run this in SQL Editor:

```sql
-- WARNING: This drops all tables and data
DROP TABLE IF EXISTS receipts CASCADE;
DROP TABLE IF EXISTS bills CASCADE;
DROP TABLE IF EXISTS item_issues CASCADE;
DROP TABLE IF EXISTS fabrication_pos CASCADE;
DROP TABLE IF EXISTS cuttings CASCADE;
DROP TABLE IF EXISTS vendors CASCADE;
DROP TABLE IF EXISTS styles CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column CASCADE;
```

Then re-run all three migrations in order.

---

## Schema Version

**Current Schema Version:** v0.5.0  
**Last Updated:** October 2025  
**Compatible with:** Stylemake v0.5 (Production Module)

