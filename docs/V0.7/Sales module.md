# Product Requirements Document (PRD)

# Project: Sales & Dispatch Management Module - Supabase Version

# Version: 2.0

# Date: 2025-10-29

# Status: Draft for Review

---

## 1. Executive Summary

This document outlines the requirements for building a **Sales & Dispatch Management Module** as part of a larger enterprise application. The module will provide functionality for managing customers, product styles, and dispatch operations with real-time data synchronization. This version will use **Supabase** as the backend database and real-time engine, replacing the original Firebase implementation.

The module is designed to be integrated into a parent application as a self-contained feature set, providing seamless sales workflow management from customer onboarding through product catalog management to dispatch tracking and reporting.

---

## 2. Goals & Objectives

* **Goal 1:** Create a production-ready, modular sales and dispatch management system that can be embedded into a larger Flutter application.
* **Goal 2:** Implement real-time data synchronization using Supabase for immediate updates across devices.
* **Goal 3:** Provide optimistic UI updates for instant responsiveness while maintaining data consistency.
* **Goal 4:** Enable efficient search and filtering across all major data entities.
* **Goal 5:** Generate printable dispatch documents (challans) for physical record-keeping.

---

## 3. Scope

### 3.1. In Scope

#### Core Modules
1. **Customer Management**
   - Create, Read, Update, Delete (CRUD) operations
   - Customer details including contact info, location, transport preferences
   - Search and filter functionality
   - Real-time updates across all connected clients

2. **Product/Style Management**
   - CRUD operations for product catalog
   - Product details including name and designer information
   - Search and filter functionality
   - Reference integrity checks before deletion

3. **Dispatch Management**
   - Create and manage dispatch records (challans)
   - Auto-generated sequential challan numbers
   - Customer-dispatch relationships
   - Line item management with product references, quantities, rates
   - Optimistic UI updates for instant feedback
   - Real-time synchronization
   - Search and filter on challan number, date, customer
   - Print dispatch challans as PDF

4. **Data Features**
   - Optimistic UI: instant local updates with background sync
   - Offline resilience: pending/error indicators with manual retry
   - Real-time streams for list views
   - Referential integrity (prevent deletion of entities in use)
   - Search/filter on all major list screens

5. **Technical Features**
   - Material 3 theming
   - Riverpod state management
   - Supabase backend (PostgreSQL with real-time subscriptions)
   - PDF generation for dispatch documents

### 3.2. Out of Scope

* User authentication and authorization (assumed to be handled by parent app)
* Multi-tenancy or role-based access control
* Advanced analytics or reporting dashboards
* Mobile-specific optimizations beyond responsive layout
* Internationalization (English only for v1.0)
* Job Order / Purchase Order management (present in codebase but not actively used)
* Inventory tracking or stock management

---

## 4. Detailed Requirements

### 4.1. Data Models

#### Customer
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | Yes | Auto-generated primary key |
| name | String | Yes | Customer/company name |
| city | String | No | City location |
| state | String | No | State/province |
| address | String | No | Full address |
| contact_no | String | No | Phone number |
| preferred_transport | String | No | Preferred shipping method |
| notes | String | No | Additional notes |
| type | String | No | Customer category/type |
| created_at | Timestamp | Yes | Auto-generated |
| updated_at | Timestamp | Yes | Auto-updated |

#### Product (Style)
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | Yes | Auto-generated primary key |
| name | String | Yes | Product/style name |
| designer | String | No | Designer name |
| created_at | Timestamp | Yes | Auto-generated |
| updated_at | Timestamp | Yes | Auto-updated |

#### Dispatch
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | Yes | Auto-generated primary key |
| date | Date | Yes | Dispatch date |
| challan_no | String | Yes | Sequential challan number |
| customer_id | UUID | Yes | Foreign key to Customer |
| remarks | String | No | Additional notes |
| created_at | Timestamp | Yes | Auto-generated |
| updated_at | Timestamp | Yes | Auto-updated |

#### Dispatch Item (nested within Dispatch)
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| product_id | UUID | Yes | Foreign key to Product |
| qty | Integer | Yes | Quantity dispatched |
| rate | Decimal | No | Unit price |
| note | String | No | Line item notes |

**Note:** Dispatch items are stored as JSONB array within the dispatch record for simplicity and atomic updates.

#### Config (for sequence numbers)
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | Yes | Primary key |
| key | String | Yes | Config key (e.g., 'next_challan_no') |
| value | Integer | Yes | Current value |

### 4.2. Functional Requirements

#### FR-001: Customer Management
* **FR-001.1:** Users can create a new customer with name (required) and optional fields
* **FR-001.2:** Users can view a list of all customers in a grid layout with name and city displayed
* **FR-001.3:** Users can search customers by name, city, or type in real-time
* **FR-001.4:** Users can edit existing customer details
* **FR-001.5:** Users can delete a customer only if they are not referenced in any dispatch records
* **FR-001.6:** Customer list updates in real-time when changes occur from any client

#### FR-002: Product/Style Management
* **FR-002.1:** Users can create a new product with name (required) and designer (optional)
* **FR-002.2:** Users can view all products in a grid layout showing name and designer
* **FR-002.3:** Users can search products by name or designer in real-time
* **FR-002.4:** Users can edit existing product details
* **FR-002.5:** Users can delete a product only if it is not referenced in any dispatch items
* **FR-002.6:** Product list updates in real-time when changes occur

#### FR-003: Dispatch Management - Basic Operations
* **FR-003.1:** Users can create a new dispatch record with:
  - Auto-generated sequential challan number (format: 0001, 0002, etc.)
  - Date selection (default: today)
  - Customer selection from dropdown
  - Optional remarks
* **FR-003.2:** Users can view a list of all dispatches showing challan number, customer name, and date
* **FR-003.3:** Users can search dispatches by challan number, date, or remarks
* **FR-003.4:** Users can edit existing dispatch records
* **FR-003.5:** Users can delete a dispatch record with confirmation
* **FR-003.6:** Dispatch list updates in real-time

#### FR-004: Dispatch Management - Line Items (Optimistic Updates)
* **FR-004.1:** Users can add line items to a dispatch with:
  - Product selection via autocomplete
  - Quantity (required, integer)
  - Rate (optional, decimal)
  - Note (optional)
* **FR-004.2:** Line items appear instantly in the UI (optimistic update)
* **FR-004.3:** Background sync to Supabase occurs automatically after UI update
* **FR-004.4:** Users can edit line items with instant UI updates
* **FR-004.5:** Users can delete line items with instant UI updates
* **FR-004.6:** No explicit "Save" button - all changes persist automatically
* **FR-004.7:** Pending indicator shown during background sync
* **FR-004.8:** Error indicator with retry button shown if sync fails
* **FR-004.9:** Date, customer, and remarks changes trigger automatic save

#### FR-005: Printing
* **FR-005.1:** Users can print a dispatch challan as PDF
* **FR-005.2:** PDF includes:
  - Company/app branding
  - Challan number and date
  - Customer details
  - Table of line items with product name, quantity, rate
  - Remarks if present

#### FR-006: Data Validation
* **FR-006.1:** Customer name must be at least 2 characters
* **FR-006.2:** Product name is required
* **FR-006.3:** Challan number cannot be empty
* **FR-006.4:** Customer selection is required for dispatch
* **FR-006.5:** Line item quantity must be a positive integer
* **FR-006.6:** Line item rate must be non-negative if provided
* **FR-006.7:** Product selection is required for line items

### 4.3. Non-Functional Requirements

#### NFR-001: Performance
* **NFR-001.1:** List screens must load within 2 seconds on a standard connection
* **NFR-001.2:** Optimistic UI updates must appear within 100ms
* **NFR-001.3:** Search filtering must respond within 300ms

#### NFR-002: Platform Support
* **NFR-002.1:** Target iOS 14.0+
* **NFR-002.2:** Target Android 7.0 (API 24)+
* **NFR-002.3:** Desktop support (Windows, macOS, Linux) via Flutter

#### NFR-003: Design & UX
* **NFR-003.1:** Follow Material 3 design guidelines
* **NFR-003.2:** Consistent color scheme using defined app palette
* **NFR-003.3:** Clear visual feedback for all user actions
* **NFR-003.4:** Accessible with proper contrast ratios and tap targets
* **NFR-003.5:** Responsive layout adapting to different screen sizes

#### NFR-004: Data Consistency
* **NFR-004.1:** Eventual consistency model with optimistic updates
* **NFR-004.2:** Conflict resolution: last-write-wins
* **NFR-004.3:** Real-time sync for list views via Supabase subscriptions
* **NFR-004.4:** Local state synchronization after background writes

#### NFR-005: Reliability
* **NFR-005.1:** Graceful handling of network failures
* **NFR-005.2:** Clear error messages for user-facing errors
* **NFR-005.3:** Data validation at both client and database level
* **NFR-005.4:** Referential integrity enforced via foreign key constraints

### 4.4. Technical Architecture

#### Tech Stack
* **Frontend:** Flutter (Dart 3.8+)
* **State Management:** Riverpod 2.6+
* **Backend:** Supabase (PostgreSQL + Realtime)
* **PDF Generation:** `pdf` and `printing` packages
* **UI Framework:** Material 3

#### Supabase Schema

```sql
-- Customers table
CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  city TEXT,
  state TEXT,
  address TEXT,
  contact_no TEXT,
  preferred_transport TEXT,
  notes TEXT,
  type TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Products table
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  designer TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Dispatches table
CREATE TABLE dispatches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  challan_no TEXT NOT NULL UNIQUE,
  customer_id UUID NOT NULL REFERENCES customers(id),
  remarks TEXT,
  dispatch_items JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Config table for sequences
CREATE TABLE config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT NOT NULL UNIQUE,
  value INTEGER NOT NULL
);

-- Initialize challan sequence
INSERT INTO config (key, value) VALUES ('next_challan_no', 1);

-- Indexes
CREATE INDEX idx_customers_name ON customers(name);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_dispatches_challan_no ON dispatches(challan_no);
CREATE INDEX idx_dispatches_customer_id ON dispatches(customer_id);
CREATE INDEX idx_dispatches_date ON dispatches(date);

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  
CREATE TRIGGER update_dispatches_updated_at BEFORE UPDATE ON dispatches
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

#### Row Level Security (RLS) Policies
**Note:** Authentication is assumed to be handled by the parent application. Basic policies for authenticated users:

```sql
-- Enable RLS
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE dispatches ENABLE ROW LEVEL SECURITY;
ALTER TABLE config ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users full access (adjust based on parent app auth)
CREATE POLICY "Allow authenticated users" ON customers FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users" ON products FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users" ON dispatches FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users" ON config FOR ALL USING (auth.role() = 'authenticated');
```

#### Realtime Subscriptions
Enable realtime for relevant tables:
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE customers;
ALTER PUBLICATION supabase_realtime ADD TABLE products;
ALTER PUBLICATION supabase_realtime ADD TABLE dispatches;
```

### 4.5. Integration Requirements

#### INT-001: Module Integration
* **INT-001.1:** Module should be importable as a Flutter package/feature
* **INT-001.2:** Navigation to module screens via standard Flutter routing
* **INT-001.3:** Module should respect parent app's theme where applicable
* **INT-001.4:** Module maintains its own Riverpod providers (scoped if needed)

#### INT-002: Supabase Configuration
* **INT-002.1:** Supabase URL and anon key provided via environment config
* **INT-002.2:** Supabase client initialized at module entry point
* **INT-002.3:** Auth token management handled by parent application

---

## 5. User Stories

### Epic 1: Customer Management
* **US-1.1:** As a sales manager, I want to add new customers so that I can maintain an up-to-date customer database.
* **US-1.2:** As a sales representative, I want to search for customers by name or city so that I can quickly find contact information.
* **US-1.3:** As an admin, I want to edit customer details so that I can keep records current.
* **US-1.4:** As an admin, I want to be prevented from deleting customers with active dispatches so that data integrity is maintained.

### Epic 2: Product Catalog
* **US-2.1:** As a product manager, I want to add new styles with designer information so that our catalog is complete.
* **US-2.2:** As a sales rep, I want to search products by name or designer so that I can reference them quickly during dispatch creation.
* **US-2.3:** As a product manager, I want to edit product details so that I can correct errors or update information.

### Epic 3: Dispatch Operations
* **US-3.1:** As a dispatch clerk, I want to create a new dispatch with auto-generated challan numbers so that each dispatch is uniquely identified.
* **US-3.2:** As a dispatch clerk, I want to add line items instantly without waiting for a save operation so that I can work efficiently.
* **US-3.3:** As a dispatch clerk, I want to see pending indicators when data is syncing so that I know the operation is in progress.
* **US-3.4:** As a dispatch clerk, I want to retry failed operations so that I can recover from network issues without losing work.
* **US-3.5:** As a warehouse manager, I want to print dispatch challans so that I can include them with physical shipments.
* **US-3.6:** As a dispatch clerk, I want to search dispatches by challan number or date so that I can review past records.

---

## 6. Acceptance Criteria

### AC-1: Customer Management
- [ ] User can create, edit, view, and conditionally delete customers
- [ ] Customer list displays with real-time updates
- [ ] Search filters customers instantly as user types
- [ ] Deletion is blocked with clear message if customer is referenced in dispatches

### AC-2: Product Management
- [ ] User can create, edit, view, and conditionally delete products
- [ ] Product list displays with real-time updates
- [ ] Search filters products instantly
- [ ] Deletion is blocked with clear message if product is in use

### AC-3: Dispatch Basic Operations
- [ ] User can create dispatch with auto-generated challan number
- [ ] User can select customer from dropdown
- [ ] User can edit dispatch date, customer, and remarks
- [ ] Dispatch list displays with real-time updates
- [ ] Search filters dispatches instantly
- [ ] User can delete dispatch with confirmation dialog

### AC-4: Optimistic Dispatch Line Items
- [ ] Adding an item shows it instantly in the list
- [ ] Editing an item reflects changes instantly
- [ ] Removing an item removes it instantly from UI
- [ ] No "Save" button is present - changes persist automatically
- [ ] Pending spinner shows during background sync
- [ ] Error icon with retry button shows if sync fails
- [ ] Successfully synced items show no indicators

### AC-5: Printing
- [ ] User can tap print icon on dispatch entry screen
- [ ] PDF generates with all dispatch details
- [ ] PDF includes line items table
- [ ] PDF can be printed or saved

### AC-6: Data Validation
- [ ] All required fields show validation errors when empty
- [ ] Numeric fields reject non-numeric input
- [ ] Validation is consistent between client and server

---

## 7. Technical Considerations

### 7.1. Migration from Firebase to Supabase

| Aspect | Firebase | Supabase | Migration Notes |
|--------|----------|----------|-----------------|
| Database | Firestore (NoSQL) | PostgreSQL (SQL) | Restructure from documents to relational tables |
| Real-time | Firestore snapshots | Supabase Realtime (PostgreSQL LISTEN/NOTIFY) | Replace StreamProvider implementations |
| Auth | Firebase Auth | Supabase Auth | Delegate to parent app |
| File Storage | Firebase Storage | Supabase Storage | Not used in this module |
| SDKs | `cloud_firestore` | `supabase_flutter` | Update dependencies |
| Queries | Document/Collection queries | SQL queries | Rewrite all CRUD operations |

### 7.2. Data Migration Strategy
1. Export existing Firestore data as JSON
2. Transform document structure to relational format
3. Import into Supabase tables via SQL INSERT statements
4. Verify data integrity and foreign key relationships
5. Test real-time subscriptions

### 7.3. Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  supabase_flutter: ^2.0.0  # Replace firebase packages
  pdf: ^3.11.3
  path_provider: ^2.1.5
  printing: ^5.14.2
  collection: ^1.18.0
```

### 7.4. State Management Pattern
* **Notifier pattern:** For mutable state (products, dispatch operations)
* **StreamProvider:** For real-time data (customer/product lists)
* **FutureProvider:** For one-time lookups (customer by ID, product by ID)
* **StateProvider:** For search queries

### 7.5. Error Handling
* Network errors: Show retry UI
* Validation errors: Inline form feedback
* Constraint violations (FK checks): User-friendly error messages
* Optimistic update failures: Revert UI or show error indicator

---

## 8. Open Questions

1. **Parent App Integration:**
   - How should authentication tokens be passed to the module?
   - Should the module use the parent app's Supabase client or initialize its own?
   - What theming customization does the parent app require?

2. **Multi-Tenancy:**
   - Will the parent app use tenant isolation (e.g., organization_id in tables)?
   - Should RLS policies enforce tenant boundaries?

3. **Permissions:**
   - Will the parent app provide role information (admin, clerk, viewer)?
   - Should certain operations (delete, print) be role-restricted?

4. **Data Retention:**
   - Are there requirements for archiving old dispatches?
   - Should deleted records be soft-deleted or hard-deleted?

5. **Offline Support:**
   - Should the module work fully offline with local-first architecture?
   - Or is optimistic UI with retry sufficient?

6. **Reporting:**
   - Are summary reports or dashboards needed beyond raw data access?

---

## 9. Success Metrics

* **Performance:** 95% of operations complete within target times (NFR-001)
* **Reliability:** <1% error rate for optimistic updates
* **Usability:** Users can complete dispatch creation in <2 minutes
* **Data Integrity:** Zero data loss incidents due to failed syncs
* **Real-time:** Updates propagate to connected clients within 2 seconds

---

## 10. Timeline Estimate (Development Phases)

### Phase 1: Setup & Infrastructure (1 week)
- Supabase project setup
- Database schema creation
- RLS policies and indexes
- Flutter project structure
- Dependency integration

### Phase 2: Data Models & Providers (1 week)
- Dart model classes with Supabase serialization
- Riverpod providers for CRUD operations
- Real-time stream implementations
- Unit tests for data layer

### Phase 3: Customer & Product Modules (1.5 weeks)
- Customer CRUD screens
- Product CRUD screens
- Search and filter UI
- Validation and error handling

### Phase 4: Dispatch Module - Basic (1 week)
- Dispatch list and search
- Dispatch entry form
- Customer selection
- Challan number generation

### Phase 5: Dispatch Module - Line Items (1.5 weeks)
- Item entry dialog with autocomplete
- Optimistic add/edit/delete
- Pending/error indicators
- Retry mechanism

### Phase 6: Printing & Polish (1 week)
- PDF generation
- Print service implementation
- UI polish and theming
- Integration testing

### Phase 7: Testing & Documentation (1 week)
- End-to-end testing
- Bug fixes
- API documentation
- Integration guide for parent app

**Total Estimate:** 8 weeks for MVP

---

## 11. Appendices

### A. Glossary
* **Challan:** A dispatch note or delivery note accompanying shipped goods
* **Optimistic UI:** UI pattern where changes appear instantly before server confirmation
* **RLS:** Row Level Security - database-level access control
* **Realtime:** Supabase feature for live database subscriptions

### B. References
* Supabase Documentation: https://supabase.com/docs
* Flutter Documentation: https://flutter.dev/docs
* Riverpod Documentation: https://riverpod.dev
* Material 3 Guidelines: https://m3.material.io

### C. Related Documents
* Original PRD (Firebase version): `docs/PRD.md`
* TODO List: `docs/Todo.md`
* Phase 3 Implementation Plan: `phase.plan.md`

