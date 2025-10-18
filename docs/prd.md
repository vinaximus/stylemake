# Stylemake v0.5 — Production Requirement Document (PRD)

## 1. Overview

**App Name:** Stylemake
**Purpose:** Stylemake is a mobile and web-friendly application designed to manage the entire workflow of a garment manufacturing company — from **Fabric management to Dispatch**.
**Scope (v0.5):** Focused on the **Production Module**.
**Future Versions:** Will include Fabric and Dispatch modules, along with full multi-user authentication and SaaS support.

**Target Platforms:**

- Android (Mobile)
- iOS (Mobile)
- Web (Responsive Web App)

**Technology Stack:**

- **Frontend:** Flutter (Material 3 Design)
- **Backend:** Supabase (Database + Authentication + Storage)
- **State Management:** Riverpod
- **Language:** Dart

---

## 2. Module Overview

### 2.1 Fabric Module *(Placeholder)*

**Purpose:** Manage fabric inward, allocation, and stock.**Status:** Planned for future release (v1.0).**Key Features (Future Scope):**

- Fabric Inward Entry
- Fabric Allocation to Cutting
- Fabric Stock and Wastage Tracking

---

### 2.2 Production Module *(Implemented in v0.5)*

**Purpose:** Manage garment production workflow from **Cutting to Receipt of Finished Goods**.

#### Screens & Functional Requirements

---

### **1. Cutting Records**

**Purpose:** Record all cuttings for production tracking.

**Data Fields:**

- Cutting Reference No (Auto/Manual)
- Cutting Date
- Quantity Cut
- Style ID (Dropdown from Style Master)
- Notes

**Functions:**

- Add/Edit/Delete Cutting Record
- List and Filter by Date, Style, or Reference No
- Link to Fabrication POs

---

### **2. Fabrication Purchase Orders (PO)**

**Purpose:** Issue job orders to vendors for embroidery or stitching/finishing.

**Data Fields:**

- PO Number (Auto-generated)
- Cutting Reference No (Linked)
- Job Order No
- Vendor Name (Dropdown from Vendor Master)
- Fabrication Type (Embroidery / Stitching & Finishing)
- Date of Issue
- Completion Date
- Quantity Issued
- Rate per Unit
- Instructions / Notes

**Functions:**

- Create, Edit, Delete PO
- Link PO to Cutting Record
- View PO List (filter by Vendor, Type, Date)
- Export PO to PDF

---

### **3. Item Issue Records**

**Purpose:** Record items issued under a specific PO.

**Data Fields:**

- Issue Date
- Related PO ID (Dropdown)
- Item Description
- Quantity
- Rate
- Notes

**Functions:**

- Add/Edit/Delete Issue Record
- View Issues by PO
- Filter by Date or PO

---

### **4. Bills Issued Against PO**

**Purpose:** Track supplier invoices for fabrication work.

**Data Fields:**

- Supplier Invoice No
- Invoice Date
- Related PO ID
- Quantity
- Rate
- Notes

**Functions:**

- Add/Edit/Delete Bill
- Link Bill to PO
- Auto-calculate Bill Total (Qty × Rate)
- View Bill Summary per Vendor

---

### **5. Receipts of Finished Goods**

**Purpose:** Record finished goods received against cuttings.

**Data Fields:**

- Receipt ID (Auto-generated)
- Cutting Reference ID
- Style ID
- Quantity Received
- Date of Receipt
- Notes

**Functions:**

- Add/Edit/Delete Receipt
- Link to Cutting Record
- View Receipts by Date or Style
- Generate Production Summary Report

---

### **6. Masters**

#### **Style Master**

**Fields:**

- Style ID
- Style Name

**Functions:**

- Add/Edit/Delete Style
- View Style List

#### **Vendor Master**

**Fields:**

- Vendor ID
- Vendor Name
- Vendor GST
- Address
- City
- PIN Code

**Functions:**

- Add/Edit/Delete Vendor
- View Vendor List
- Filter by City or Name

---

### 2.3 Dispatch Module *(Placeholder)*

**Purpose:** Manage finished goods dispatch and delivery.**Status:** Planned for v1.0.**Future Features:**

- Dispatch Note Creation
- Delivery Tracking
- Dispatch Reports

---

## 3. System Requirements

### 3.1 Functional Requirements

- CRUD operations for all core entities (Cuttings, POs, Issues, Bills, Receipts, Masters)
- Real-time sync with Supabase
- Form validation and field-level error handling
- Basic reporting with filters and search
- Single-user operation in v0.5

### 3.2 Non-Functional Requirements

#### **Performance**

- Lists (e.g., Cuttings, POs, Vendors) must load within 2 seconds (up to 500 records).
- Sync operations complete within 5 seconds on 4G/broadband.

#### **Security**

- All data stored securely in Supabase.
- Authentication planned for v1.0 with Supabase Auth and Row-Level Security.

#### **Scalability**

- Database schema designed for future **multi-user and multi-company support**.
- Modular app architecture to integrate Fabric and Dispatch modules later.

#### **Data Backup**

- Automatic daily backups via Supabase.
- Option for manual export (CSV).

---

## 4. UI/UX Design Guidelines

### **Principles**

- Follow **Material 3 Design**.
- Mobile-first design with responsive layouts for web.
- Minimal, clean UI using cards and lists.

### **Color & Typography**

- **Primary:** Indigo / Deep Blue
- **Secondary:** Light Gray / Off-white
- **Font:** Roboto or Inter (Google Fonts)

### **Layout Standards**

- Floating Action Button (FAB) for “Add” actions.
- Card-based lists for records.
- Bottom navigation bar for module switching.

---

## 5. Authentication & Multi-Tenancy Roadmap

Stylemake will be sold as a **SaaS product**. Multiple companies (tenants) will use it, each with their own users.
To ensure smooth evolution, authentication and multi-tenancy will be introduced in phases.

---

### **Phase 1 — v0.5 (Current)**

- **No authentication.**
- Single company, single user.
- Add placeholder columns to all tables:
  ```sql
  company_id uuid DEFAULT '00000000-0000-0000-0000-000000000000',
  user_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'
  ```
- All queries filter by a default company_id.
- Prepares the codebase for future multi-company expansion.

---

### **Phase 2 — v0.6 (Internal Beta)**

- Enable **Supabase Auth** with email/password.
- Introduce `companies` and `profiles` tables.
- Each user belongs to one company.
- Basic role support (admin, staff) without Row-Level Security (RLS).

```sql
companies (
  id uuid primary key,
  name text,
  subscription_plan text,
  created_at timestamp default now()
)

profiles (
  id uuid references auth.users(id) on delete cascade,
  company_id uuid references companies(id),
  name text,
  role text,
  created_at timestamp default now()
)
```

---

### **Phase 3 — v1.0 (SaaS Launch)**

- Full **multi-company authentication** using Supabase Auth.
- **Row-Level Security (RLS)** enabled on all tables:
  ```sql
  CREATE POLICY "Company data isolation"
  ON cuttings
  FOR SELECT USING (
    auth.uid() IN (
      SELECT id FROM profiles WHERE company_id = cuttings.company_id
    )
  );
  ```
- **Company-based data isolation** — each company sees only its own records.
- **Role-based access control (RBAC):**

  | Role    | Description                     |
  | --------- | --------------------------------- |
  | Admin   | Manages company, billing, users |
  | Manager | Full access to production data  |
  | Staff   | Limited data entry              |

---

### **Deployment Flow**

1. Admin signs up → Creates a new company record automatically.
2. Admin invites team members (manager/staff) via email.
3. Each user logs in → Supabase session used for data filtering.

---

### **Version Transition Summary**


| Version  | Auth Type           | Company Support    | Access Control | Status         |
| ---------- | --------------------- | -------------------- | ---------------- | ---------------- |
| **v0.5** | None                | Single Company     | Single User    | ✅ Implemented |
| **v0.6** | Basic Supabase Auth | Multiple Companies | No RLS         | 🔜 Planned     |
| **v1.0** | Full Supabase Auth  | Multi-Tenant (RLS) | Role-Based     | 🚀 SaaS Launch |

---

## 6. Future Scope (v1.0 and Beyond)

- Full implementation of Fabric & Dispatch modules
- Multi-user, multi-company SaaS release
- Integration with accounting/ERP systems
- Analytics dashboard
- Barcode scanning for production tracking
- Offline mode with local caching

---

## 7. Version Information


| Field                | Detail         |
| ---------------------- | ---------------- |
| **Document Version** | 0.5            |
| **App Version**      | Stylemake v0.5 |
| **Prepared By**      | [Your Name]    |
| **Date**             | October 2025   |
