# Database Schema Reference
## Stylemake v0.5 - Production Module

**Schema Version:** v0.5.0  
**Last Updated:** October 18, 2025  
**Database:** PostgreSQL (via Supabase)

---

## Table of Contents

1. [Overview](#overview)
2. [Schema Conventions](#schema-conventions)
3. [Table Definitions](#table-definitions)
4. [Relationships](#relationships)
5. [Indexes](#indexes)
6. [Constraints](#constraints)
7. [Default Values](#default-values)
8. [Query Patterns](#query-patterns)
9. [Multi-Tenancy Design](#multi-tenancy-design)

---

## Overview

The Stylemake Production Module uses 7 core tables to manage the garment manufacturing workflow:

1. **styles** - Master data for garment styles
2. **vendors** - Master data for fabrication vendors
3. **cuttings** - Production cutting records
4. **fabrication_pos** - Purchase orders to vendors
5. **item_issues** - Items issued under purchase orders
6. **bills** - Supplier invoices against POs
7. **receipts** - Finished goods received

### Data Flow

```
[styles] ──┐
           ├──> [cuttings] ──┬──> [fabrication_pos] ──┬──> [item_issues]
           │                 │                         │
           │                 │                         └──> [bills]
           │                 │
           │                 └──> [receipts]
           │                        ↑
           └────────────────────────┘
[vendors] ────> [fabrication_pos]
```

---

## Schema Conventions

### Naming Conventions

- **Tables:** Plural, lowercase, underscores (e.g., `fabrication_pos`)
- **Columns:** Lowercase, underscores (e.g., `cutting_date`)
- **Primary Keys:** Always `id` (UUID)
- **Foreign Keys:** `{table_singular}_id` (e.g., `style_id`, `vendor_id`)
- **Timestamps:** `created_at`, `updated_at`

### Standard Columns (All Tables)

Every table includes these standard columns:

```sql
id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL
user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL
created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
```

### Data Types

- **IDs:** UUID (automatically generated)
- **Dates:** DATE (for business dates like cutting_date)
- **Timestamps:** TIMESTAMP WITH TIME ZONE (for audit trails)
- **Money:** DECIMAL(10, 2) (for rates, amounts)
- **Text:** TEXT (no length limit, PostgreSQL optimizes automatically)
- **Numbers:** INTEGER (for quantities, counts)

---

## Table Definitions

### 1. styles

Master table for garment styles (e.g., T-Shirt, Polo, Hoodie).

```sql
CREATE TABLE styles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);
```

**Columns:**
- `id` - Unique identifier (UUID, auto-generated)
- `name` - Style name (e.g., "T-Shirt Basic")
- `company_id` - Company ownership (for multi-tenancy)
- `user_id` - User who created the record
- `created_at` - Record creation timestamp
- `updated_at` - Last update timestamp (auto-updated)

**Relationships:**
- Referenced by: `cuttings.style_id`, `receipts.style_id`

**Business Rules:**
- Style names should be unique per company (not enforced in v0.5)
- Styles cannot be deleted if referenced by cuttings

---

### 2. vendors

Master table for fabrication vendors.

```sql
CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    gst TEXT,
    address TEXT,
    city TEXT,
    pin_code TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);
```

**Columns:**
- `id` - Unique identifier (UUID, auto-generated)
- `name` - Vendor business name (required)
- `gst` - GST registration number (optional, format: 15 chars)
- `address` - Vendor address (optional)
- `city` - City name (optional, used for filtering)
- `pin_code` - Postal/ZIP code (optional)
- `company_id` - Company ownership
- `user_id` - User who created the record
- `created_at` - Record creation timestamp
- `updated_at` - Last update timestamp

**Relationships:**
- Referenced by: `fabrication_pos.vendor_id`

**Business Rules:**
- Vendor names should be unique per company (not enforced in v0.5)
- Vendors cannot be deleted if referenced by POs
- GST format for India: 2-digit state code + 10-digit PAN + 1-digit entity + 1-digit Z + 1-digit checksum

---

### 3. cuttings

Records of fabric cuttings for production.

```sql
CREATE TABLE cuttings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cutting_ref TEXT NOT NULL,
    cutting_date DATE NOT NULL,
    quantity_cut INTEGER NOT NULL CHECK (quantity_cut > 0),
    style_id UUID NOT NULL,
    notes TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT fk_cuttings_style FOREIGN KEY (style_id) REFERENCES styles(id)
);
```

**Columns:**
- `id` - Unique identifier (UUID, auto-generated)
- `cutting_ref` - Cutting reference number (e.g., "CUT-2025-001")
- `cutting_date` - Date when cutting was performed
- `quantity_cut` - Number of pieces cut (must be > 0)
- `style_id` - Reference to style being cut (FK to styles)
- `notes` - Additional notes or remarks (optional)
- `company_id` - Company ownership
- `user_id` - User who created the record
- `created_at` - Record creation timestamp
- `updated_at` - Last update timestamp

**Relationships:**
- References: `styles.id` via `style_id`
- Referenced by: `fabrication_pos.cutting_id`, `receipts.cutting_id`

**Business Rules:**
- Cutting reference must be unique per company
- Quantity must be positive
- Style must exist before creating cutting
- Cuttings cannot be deleted if referenced by POs or receipts

**Unique Constraint:**
- `(cutting_ref, company_id)` - Prevents duplicate cutting references

---

### 4. fabrication_pos

Purchase orders issued to vendors for fabrication work.

```sql
CREATE TABLE fabrication_pos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_number TEXT NOT NULL,
    cutting_id UUID NOT NULL,
    job_order_no TEXT,
    vendor_id UUID NOT NULL,
    fabrication_type TEXT NOT NULL CHECK (fabrication_type IN ('Embroidery', 'Stitching & Finishing')),
    date_of_issue DATE NOT NULL,
    completion_date DATE,
    quantity_issued INTEGER NOT NULL CHECK (quantity_issued > 0),
    rate_per_unit DECIMAL(10, 2) NOT NULL CHECK (rate_per_unit >= 0),
    instructions TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT fk_fabrication_pos_cutting FOREIGN KEY (cutting_id) REFERENCES cuttings(id),
    CONSTRAINT fk_fabrication_pos_vendor FOREIGN KEY (vendor_id) REFERENCES vendors(id),
    CONSTRAINT check_completion_date CHECK (completion_date IS NULL OR completion_date >= date_of_issue)
);
```

**Columns:**
- `id` - Unique identifier (UUID, auto-generated)
- `po_number` - Purchase order number (e.g., "PO-2025-001")
- `cutting_id` - Reference to cutting record (FK to cuttings)
- `job_order_no` - Internal job order number (optional)
- `vendor_id` - Vendor receiving the PO (FK to vendors)
- `fabrication_type` - Type of work: "Embroidery" or "Stitching & Finishing"
- `date_of_issue` - When PO was issued
- `completion_date` - Expected/actual completion date (optional)
- `quantity_issued` - Number of pieces issued (must be > 0)
- `rate_per_unit` - Cost per piece (must be >= 0)
- `instructions` - Special instructions for vendor (optional)
- `company_id` - Company ownership
- `user_id` - User who created the record
- `created_at` - Record creation timestamp
- `updated_at` - Last update timestamp

**Relationships:**
- References: `cuttings.id` via `cutting_id`
- References: `vendors.id` via `vendor_id`
- Referenced by: `item_issues.po_id`, `bills.po_id`

**Business Rules:**
- PO number must be unique per company
- Completion date must be >= issue date (if specified)
- Quantity and rate must be positive
- Fabrication type is constrained to specific values
- Cutting and vendor must exist before creating PO
- POs can be deleted (CASCADE to item_issues and bills)

**Unique Constraint:**
- `(po_number, company_id)` - Prevents duplicate PO numbers

**Check Constraints:**
- `fabrication_type IN ('Embroidery', 'Stitching & Finishing')`
- `quantity_issued > 0`
- `rate_per_unit >= 0`
- `completion_date >= date_of_issue` (if not null)

---

### 5. item_issues

Items issued to vendors under a purchase order.

```sql
CREATE TABLE item_issues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    issue_date DATE NOT NULL,
    po_id UUID NOT NULL,
    item_description TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    rate DECIMAL(10, 2) NOT NULL CHECK (rate >= 0),
    notes TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT fk_item_issues_po FOREIGN KEY (po_id) REFERENCES fabrication_pos(id) ON DELETE CASCADE
);
```

**Columns:**
- `id` - Unique identifier (UUID, auto-generated)
- `issue_date` - Date when items were issued
- `po_id` - Reference to purchase order (FK to fabrication_pos)
- `item_description` - Description of items issued (e.g., "Thread - Blue", "Buttons")
- `quantity` - Number of items issued (must be > 0)
- `rate` - Cost per item (must be >= 0)
- `notes` - Additional notes (optional)
- `company_id` - Company ownership
- `user_id` - User who created the record
- `created_at` - Record creation timestamp
- `updated_at` - Last update timestamp

**Relationships:**
- References: `fabrication_pos.id` via `po_id` (CASCADE delete)

**Business Rules:**
- PO must exist before creating item issue
- Quantity and rate must be positive
- Multiple issues can be created per PO
- Issues are deleted if parent PO is deleted (CASCADE)

**Calculated Values:**
- Total value = quantity × rate (calculated in application)

---

### 6. bills

Supplier invoices for fabrication work.

```sql
CREATE TABLE bills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    supplier_invoice_no TEXT NOT NULL,
    invoice_date DATE NOT NULL,
    po_id UUID NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    rate DECIMAL(10, 2) NOT NULL CHECK (rate >= 0),
    notes TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT fk_bills_po FOREIGN KEY (po_id) REFERENCES fabrication_pos(id) ON DELETE CASCADE
);
```

**Columns:**
- `id` - Unique identifier (UUID, auto-generated)
- `supplier_invoice_no` - Vendor's invoice number
- `invoice_date` - Date on the invoice
- `po_id` - Reference to purchase order (FK to fabrication_pos)
- `quantity` - Quantity billed (must be > 0)
- `rate` - Rate per unit on invoice (must be >= 0)
- `notes` - Additional notes (optional)
- `company_id` - Company ownership
- `user_id` - User who created the record
- `created_at` - Record creation timestamp
- `updated_at` - Last update timestamp

**Relationships:**
- References: `fabrication_pos.id` via `po_id` (CASCADE delete)

**Business Rules:**
- PO must exist before creating bill
- Multiple bills can be created per PO (partial billing supported)
- Bills are deleted if parent PO is deleted (CASCADE)
- Quantity and rate should match PO (not enforced)

**Calculated Values:**
- Bill total = quantity × rate (calculated in application)

---

### 7. receipts

Records of finished goods received from production.

```sql
CREATE TABLE receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    receipt_id TEXT NOT NULL,
    cutting_id UUID NOT NULL,
    style_id UUID NOT NULL,
    quantity_received INTEGER NOT NULL CHECK (quantity_received > 0),
    date_of_receipt DATE NOT NULL,
    notes TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT fk_receipts_cutting FOREIGN KEY (cutting_id) REFERENCES cuttings(id),
    CONSTRAINT fk_receipts_style FOREIGN KEY (style_id) REFERENCES styles(id)
);
```

**Columns:**
- `id` - Unique identifier (UUID, auto-generated)
- `receipt_id` - Receipt reference number (e.g., "RCP-2025-001")
- `cutting_id` - Reference to cutting record (FK to cuttings)
- `style_id` - Style being received (FK to styles, redundant but useful)
- `quantity_received` - Number of finished pieces received (must be > 0)
- `date_of_receipt` - Date when goods were received
- `notes` - Additional notes (optional)
- `company_id` - Company ownership
- `user_id` - User who created the record
- `created_at` - Record creation timestamp
- `updated_at` - Last update timestamp

**Relationships:**
- References: `cuttings.id` via `cutting_id`
- References: `styles.id` via `style_id`

**Business Rules:**
- Receipt ID must be unique per company
- Cutting and style must exist before creating receipt
- Style should match the cutting's style (not enforced)
- Multiple receipts can be created per cutting (partial receipts)
- Quantity must be positive
- Receipts cannot be deleted if cutting is deleted (RESTRICT)

**Unique Constraint:**
- `(receipt_id, company_id)` - Prevents duplicate receipt IDs

---

## Relationships

### Entity Relationship Diagram (Text)

```
styles (1) ──────< (M) cuttings (1) ──────< (M) fabrication_pos
   │                      │                           │
   │                      │                           ├──< (M) item_issues
   │                      │                           │
   │                      │                           └──< (M) bills
   │                      │
   └──────────────< (M) receipts (M) >────────────────┘

vendors (1) ──────< (M) fabrication_pos
```

### Foreign Key Details

| Child Table | Column | Parent Table | Parent Column | On Delete |
|-------------|--------|--------------|---------------|-----------|
| cuttings | style_id | styles | id | RESTRICT |
| fabrication_pos | cutting_id | cuttings | id | RESTRICT |
| fabrication_pos | vendor_id | vendors | id | RESTRICT |
| item_issues | po_id | fabrication_pos | id | CASCADE |
| bills | po_id | fabrication_pos | id | CASCADE |
| receipts | cutting_id | cuttings | id | RESTRICT |
| receipts | style_id | styles | id | RESTRICT |

**On Delete Behaviors:**
- **RESTRICT** - Prevents deletion if child records exist (styles, vendors, cuttings)
- **CASCADE** - Deletes child records when parent is deleted (item_issues, bills)

---

## Indexes

### Performance Indexes

All tables have these standard indexes:

```sql
-- Company ID indexes (for multi-tenancy filtering)
CREATE INDEX idx_<table>_company_id ON <table>(company_id);
```

### Foreign Key Indexes

```sql
-- Cuttings
CREATE INDEX idx_cuttings_style_id ON cuttings(style_id);

-- Fabrication POs
CREATE INDEX idx_fabrication_pos_cutting_id ON fabrication_pos(cutting_id);
CREATE INDEX idx_fabrication_pos_vendor_id ON fabrication_pos(vendor_id);

-- Item Issues
CREATE INDEX idx_item_issues_po_id ON item_issues(po_id);

-- Bills
CREATE INDEX idx_bills_po_id ON bills(po_id);

-- Receipts
CREATE INDEX idx_receipts_cutting_id ON receipts(cutting_id);
CREATE INDEX idx_receipts_style_id ON receipts(style_id);
```

### Date Indexes (for filtering and reporting)

```sql
CREATE INDEX idx_cuttings_cutting_date ON cuttings(cutting_date);
CREATE INDEX idx_fabrication_pos_date_of_issue ON fabrication_pos(date_of_issue);
CREATE INDEX idx_fabrication_pos_completion_date ON fabrication_pos(completion_date);
CREATE INDEX idx_item_issues_issue_date ON item_issues(issue_date);
CREATE INDEX idx_bills_invoice_date ON bills(invoice_date);
CREATE INDEX idx_receipts_date_of_receipt ON receipts(date_of_receipt);
```

### Text Search Indexes

```sql
CREATE INDEX idx_vendors_city ON vendors(city);
CREATE INDEX idx_vendors_name ON vendors(name);
CREATE INDEX idx_styles_name ON styles(name);
```

### Composite Indexes (for common queries)

```sql
-- Most common: filter by company and sort by date
CREATE INDEX idx_cuttings_company_date ON cuttings(company_id, cutting_date DESC);
CREATE INDEX idx_fabrication_pos_company_date ON fabrication_pos(company_id, date_of_issue DESC);
```

---

## Constraints

### Primary Keys
All tables use UUID primary keys named `id`.

### Unique Constraints

```sql
-- Cuttings: Unique cutting reference per company
ALTER TABLE cuttings
ADD CONSTRAINT unique_cutting_ref_per_company
UNIQUE (cutting_ref, company_id);

-- Fabrication POs: Unique PO number per company
ALTER TABLE fabrication_pos
ADD CONSTRAINT unique_po_number_per_company
UNIQUE (po_number, company_id);

-- Receipts: Unique receipt ID per company
ALTER TABLE receipts
ADD CONSTRAINT unique_receipt_id_per_company
UNIQUE (receipt_id, company_id);
```

### Check Constraints

```sql
-- Positive quantities
CHECK (quantity_cut > 0)          -- cuttings
CHECK (quantity_issued > 0)       -- fabrication_pos
CHECK (quantity > 0)              -- item_issues, bills
CHECK (quantity_received > 0)     -- receipts

-- Non-negative rates
CHECK (rate_per_unit >= 0)        -- fabrication_pos
CHECK (rate >= 0)                 -- item_issues, bills

-- Valid fabrication types
CHECK (fabrication_type IN ('Embroidery', 'Stitching & Finishing'))

-- Date validation
CHECK (completion_date IS NULL OR completion_date >= date_of_issue)
```

---

## Default Values

### Standard Defaults (All Tables)

```sql
id DEFAULT uuid_generate_v4()
company_id DEFAULT '00000000-0000-0000-0000-000000000000'
user_id DEFAULT '00000000-0000-0000-0000-000000000000'
created_at DEFAULT NOW()
updated_at DEFAULT NOW()
```

### Special Meanings

- **company_id = '00000000-0000-0000-0000-000000000000'**
  - Indicates default/single company in v0.5
  - Will be replaced with actual company IDs in v1.0
  - Used for filtering in all queries

- **user_id = '00000000-0000-0000-0000-000000000000'**
  - Indicates system/default user in v0.5
  - Will be replaced with actual user IDs in v0.6+
  - Tracks who created records

### Auto-Update Triggers

All tables have triggers to automatically update `updated_at`:

```sql
CREATE TRIGGER update_<table>_updated_at
BEFORE UPDATE ON <table>
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

---

## Query Patterns

### Basic CRUD Operations

**Select All (with company filter):**
```sql
SELECT * FROM styles
WHERE company_id = '00000000-0000-0000-0000-000000000000'
ORDER BY name;
```

**Select by ID:**
```sql
SELECT * FROM styles
WHERE id = 'uuid-here'
AND company_id = '00000000-0000-0000-0000-000000000000';
```

**Insert:**
```sql
INSERT INTO styles (name, company_id, user_id)
VALUES ('New Style', '00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000')
RETURNING *;
```

**Update:**
```sql
UPDATE styles
SET name = 'Updated Style'
WHERE id = 'uuid-here'
AND company_id = '00000000-0000-0000-0000-000000000000'
RETURNING *;
```

**Delete:**
```sql
DELETE FROM styles
WHERE id = 'uuid-here'
AND company_id = '00000000-0000-0000-0000-000000000000';
```

### Common Joins

**Cuttings with Style:**
```sql
SELECT c.*, s.name as style_name
FROM cuttings c
JOIN styles s ON c.style_id = s.id
WHERE c.company_id = '00000000-0000-0000-0000-000000000000'
ORDER BY c.cutting_date DESC;
```

**POs with Cutting and Vendor:**
```sql
SELECT 
    fp.*,
    c.cutting_ref,
    s.name as style_name,
    v.name as vendor_name
FROM fabrication_pos fp
JOIN cuttings c ON fp.cutting_id = c.id
JOIN styles s ON c.style_id = s.id
JOIN vendors v ON fp.vendor_id = v.id
WHERE fp.company_id = '00000000-0000-0000-0000-000000000000'
ORDER BY fp.date_of_issue DESC;
```

**PO with Items and Bills:**
```sql
SELECT 
    fp.po_number,
    fp.quantity_issued,
    fp.rate_per_unit,
    (SELECT COUNT(*) FROM item_issues WHERE po_id = fp.id) as item_count,
    (SELECT COUNT(*) FROM bills WHERE po_id = fp.id) as bill_count
FROM fabrication_pos fp
WHERE fp.id = 'po-uuid-here';
```

### Reporting Queries

**Production Summary by Style:**
```sql
SELECT 
    s.name as style,
    COUNT(DISTINCT c.id) as cuttings_count,
    SUM(c.quantity_cut) as total_cut,
    SUM(r.quantity_received) as total_received
FROM styles s
LEFT JOIN cuttings c ON s.id = c.style_id
LEFT JOIN receipts r ON c.id = r.cutting_id
WHERE s.company_id = '00000000-0000-0000-0000-000000000000'
GROUP BY s.id, s.name
ORDER BY s.name;
```

**Vendor Bill Summary:**
```sql
SELECT 
    v.name as vendor,
    COUNT(DISTINCT fp.id) as po_count,
    COUNT(b.id) as bill_count,
    SUM(b.quantity * b.rate) as total_billed
FROM vendors v
LEFT JOIN fabrication_pos fp ON v.id = fp.vendor_id
LEFT JOIN bills b ON fp.id = b.po_id
WHERE v.company_id = '00000000-0000-0000-0000-000000000000'
GROUP BY v.id, v.name
ORDER BY total_billed DESC;
```

**Date Range Filtering:**
```sql
SELECT *
FROM cuttings
WHERE cutting_date BETWEEN '2025-01-01' AND '2025-12-31'
AND company_id = '00000000-0000-0000-0000-000000000000'
ORDER BY cutting_date DESC;
```

---

## Multi-Tenancy Design

### Current State (v0.5)
- Single company mode
- All records use default company_id: `'00000000-0000-0000-0000-000000000000'`
- All queries filter by this default company_id

### Future State (v1.0)

**New Tables:**
```sql
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    subscription_plan TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    company_id UUID REFERENCES companies(id) NOT NULL,
    name TEXT,
    role TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Row Level Security (RLS):**
```sql
-- Enable RLS
ALTER TABLE styles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their company's data
CREATE POLICY "Company data isolation" ON styles
FOR SELECT USING (
    auth.uid() IN (
        SELECT id FROM profiles 
        WHERE company_id = styles.company_id
    )
);

-- Similar policies for all other tables
```

### Migration Path (v0.5 → v1.0)

1. **Create companies table**
2. **Create profiles table**
3. **Update default company_id** in all existing records
4. **Enable RLS** on all tables
5. **Create policies** for each table
6. **Update application** to use session user_id

---

## Best Practices

### When Querying

1. **Always filter by company_id** (even in v0.5)
   ```dart
   .eq('company_id', defaultCompanyId)
   ```

2. **Use indexes** - All date and foreign key columns are indexed

3. **Order by dates DESC** for recent-first views

4. **Use COUNT with COUNT_OPTION.exact** for accurate counts

### When Inserting

1. **Always include company_id and user_id**
   ```dart
   {
     'name': 'New Style',
     'company_id': defaultCompanyId,
     'user_id': defaultUserId,
   }
   ```

2. **Don't insert id** (auto-generated)

3. **Don't insert created_at or updated_at** (auto-generated)

### When Updating

1. **Filter by both id and company_id**
   ```dart
   .eq('id', id)
   .eq('company_id', defaultCompanyId)
   ```

2. **Don't update updated_at** (trigger handles it)

### When Deleting

1. **Always filter by company_id**

2. **Check for foreign key constraints** before deleting master data

3. **Use CASCADE carefully** - Only on child records (item_issues, bills)

---

## Common Pitfalls

❌ **Forgetting company_id filter**
```dart
// Wrong
await client.from('styles').select();

// Correct
await client.from('styles')
    .select()
    .eq('company_id', defaultCompanyId);
```

❌ **Not handling cascade deletes**
```dart
// Deleting a PO will CASCADE delete its item_issues and bills
// Make sure this is intentional!
await client.from('fabrication_pos').delete().eq('id', poId);
```

❌ **Violating check constraints**
```dart
// Wrong - quantity must be > 0
{'quantity_cut': 0}

// Correct
{'quantity_cut': 10}
```

❌ **Ignoring foreign key requirements**
```dart
// Wrong - style_id must exist
{'style_id': 'non-existent-uuid'}

// Correct - verify style exists first
final styleExists = await checkStyleExists(styleId);
if (styleExists) { /* proceed */ }
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| v0.5.0 | Oct 2025 | Initial schema with 7 tables, single-company mode |
| v0.6.0 | Planned | Add authentication, profiles, multi-company support |
| v1.0.0 | Planned | Enable RLS, full multi-tenancy |

---

## Quick Reference

### Default Company/User IDs
```
'00000000-0000-0000-0000-000000000000'
```

### Table Count
7 tables total

### Foreign Keys
7 foreign key relationships

### Indexes
27+ indexes for performance

### Constraints
- 3 unique constraints (cutting_ref, po_number, receipt_id)
- 10+ check constraints (quantities, rates, dates, enums)
- 7 foreign key constraints

---

**For setup instructions, see:** [`database_setup.md`](./database_setup.md)  
**For implementation details, see:** [`phase1_implementation_summary.md`](./phase1_implementation_summary.md)


