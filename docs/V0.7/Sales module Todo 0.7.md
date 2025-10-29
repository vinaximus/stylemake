Absolutely 👍 — here’s the **entire Stylemake v0.7 Dispatch Module PRD + Implementation TODO List** in one perfectly formatted **Markdown block**.
You can copy everything below directly into a file named
`Sales_Dispatch_Module_PRD_v0.7.md`.

---

````markdown
# Stylemake v0.7 — Dispatch Module — Production Requirement Document (PRD)

## 1. Overview

**App Name:** Stylemake  
**Module:** Dispatch Management  
**Version:** v0.7  

### Purpose
The Dispatch Module manages the outward movement of finished goods.  
Each Dispatch Challan represents goods leaving the factory for a single customer.  
This module integrates with existing Stylemake infrastructure (Supabase + Flutter).

### Scope
- Create and manage dispatch challans  
- Each challan linked to one customer  
- Record item details, transport info, and challan date  
- Generate a **generic PDF challan**  
- Reference **styles/products** from the Production Module  
- Integrated into the **existing Stylemake Supabase project**  
- No dispatch status (each record represents dispatched goods)

### Not in Scope (for future versions)
- Quantity validation against production stock  
- Invoice linkage  
- Delivery confirmation  

---

## 2. Workflow

1. User opens **Dispatch List Screen** to view all dispatch challans  
2. User clicks **Add Dispatch** → fills in customer, item, and transport details  
3. On save → records created in `dispatch_master` and `dispatch_items`  
4. User can **generate a generic PDF challan**  
5. Data synced via **optimistic UI** to Supabase backend  

---

## 3. Database Schema (Supabase Structure)

### 3.1 `dispatch_master`
Holds main dispatch-level data.

```sql
CREATE TABLE dispatch_master (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  dispatch_no text UNIQUE NOT NULL,
  dispatch_date date NOT NULL DEFAULT CURRENT_DATE,
  customer_id uuid REFERENCES customers(id),
  transport_name text,
  vehicle_no text,
  lr_no text,               -- Lorry receipt or transport reference
  total_quantity numeric DEFAULT 0,
  remarks text,
  created_at timestamptz DEFAULT now(),
  created_by uuid,
  updated_at timestamptz,
  updated_by uuid
);
````

---

### 3.2 `dispatch_items`

Stores item-level details for each challan.

```sql
CREATE TABLE dispatch_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  dispatch_id uuid REFERENCES dispatch_master(id) ON DELETE CASCADE,
  style_id uuid REFERENCES styles(id), -- From Production Module
  color text,
  size text,
  quantity numeric NOT NULL CHECK (quantity > 0),
  rate numeric,
  remarks text,
  created_at timestamptz DEFAULT now()
);
```

---

### 3.3 `customers`

If not already present in your project, add this table.

```sql
CREATE TABLE customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  customer_name text NOT NULL,
  contact_person text,
  phone text,
  address text,
  gst_no text,
  created_at timestamptz DEFAULT now(),
  created_by uuid
);
```

---

## 4. Screens (Screen-by-Screen Specification)

### 4.1 Dispatch List Screen

**Fields Displayed**

* Dispatch No
* Date
* Customer Name
* Total Quantity
* Vehicle No

**Functions**

* Add Dispatch
* View Dispatch
* Delete Dispatch
* Search / Filter by Date or Customer

**Acceptance Criteria**

* Displays all dispatch records sorted by date (latest first)
* Search and filter function correctly

---

### 4.2 Add/Edit Dispatch Screen

**Fields**

* Dispatch No (auto-generated, editable if needed)
* Dispatch Date
* Customer (dropdown from `customers`)
* Transport Name
* Vehicle No
* LR No
* Remarks

**Functions**

* Add Items (navigate to dispatch item entry list)
* Save Dispatch
* Print PDF

**Acceptance Criteria**

* User can save dispatch with at least one item
* All mandatory fields validated (Dispatch No, Customer, Date)
* PDF prints correctly with generic layout

---

### 4.3 Dispatch Item Entry Screen

**Fields per item**

* Style (dropdown from `styles` table)
* Color
* Size
* Quantity
* Rate
* Remarks

**Functions**

* Add Item
* Edit/Delete Item
* Auto-calculate total quantity for challan

**Acceptance Criteria**

* Item added and displayed in item list
* Total quantity updates dynamically

---

### 4.4 PDF Challan

**Layout**

* Company Header (name, address)
* Customer Name and Address
* Dispatch No, Date, Vehicle, LR No
* Item Table: Style, Color, Size, Qty, Rate
* Footer: “Authorized Signatory”

**Acceptance Criteria**

* PDF generated correctly from saved data
* PDF downloadable and shareable

---

## 5. Business Rules and Validations

* One dispatch = one customer
* Dispatch date defaults to current date
* Quantity must be positive
* Styles referenced from Production Module’s `styles` table
* Deleting a dispatch deletes its items
* No dispatch status field (every dispatch is final)

---

## 6. Future Enhancements (Beyond v0.7)

* Quantity validation with production stock
* Integration with invoicing ERP
* Delivery confirmation workflow
* Transport tracking integration
* Stock deduction based on dispatches

---

# TODO LIST — Implementation Roadmap (Starting from Phase 13)

## **Phase 13: Database and Supabase Setup**

* [x] Create tables `dispatch_master`, `dispatch_items`, and `customers` (if not present)
* [x] Establish relationships with `styles` table (Production Module)
* [x] Test CRUD operations in Supabase dashboard

**Acceptance Criteria:**

* Tables created successfully
* Able to insert, update, and fetch records via Supabase SQL or API

---

## **Phase 14: Customer Management UI** ✅

* [x] Create `CustomerListScreen` in Flutter
* [x] Fetch all customers from Supabase (sorted by name)
* [x] Add FAB to open Add Customer form
* [x] Create `AddEditCustomerScreen` with all customer fields
* [x] Implement real-time search by name, contact person, or phone
* [x] Add delete functionality with reference check

**Acceptance Criteria:**

* Customer list displays correctly with name and contact info
* Search filters customers instantly as user types
* User can create, edit, and conditionally delete customers
* Deletion blocked with clear message if customer referenced in dispatches
* Real-time updates when changes occur

---

## **Phase 15: Product/Style Management UI** ✅

* [x] Create `ProductListScreen` in Flutter
* [x] Fetch all products from Supabase (sorted by name)
* [x] Add FAB to open Add Product form
* [x] Create `AddEditProductScreen` with name and designer fields
* [x] Implement real-time search by name or designer
* [x] Add delete functionality with reference check

**Acceptance Criteria:**

* [x] Product list displays correctly with name and designer
* [x] Search filters products instantly as user types
* [x] User can create, edit, and conditionally delete products
* [x] Deletion blocked with clear message if product in use
* [x] Real-time updates when changes occur

---

## **Phase 16: Dispatch List & Detail UI** ✅

* [x] Create `DispatchListScreen` in Flutter
* [x] Fetch all dispatches from Supabase (latest first)
* [x] Add FAB to open Add Dispatch form
* [x] Create `DispatchDetailScreen` to view challan details

**Acceptance Criteria:**

* [x] Dispatch list displays correctly with search functionality
* [x] Tapping entry opens details with master and items data
* [x] Real-time updates and responsive design implemented
* [x] Delete functionality with confirmation dialog

---

## **Phase 17: Add/Edit Dispatch with Items** ✅

* [x] Build `DispatchFormScreen` with all master fields
* [x] Add dynamic list for items (add/edit/delete rows)
* [x] Save both master and items using Supabase transaction
* [x] Calculate total quantity dynamically
* [x] Auto-generate Dispatch No (e.g., DCH-0001)

**Acceptance Criteria:**

* [x] New dispatch can be created with one or more items
* [x] Data saved to Supabase and visible in list
* [x] Auto-numbering works correctly (DCH-XXXX format)
* [x] Complete CRUD cycle with validation and error handling

---

## **Phase 18: PDF Generation & Polishing**

* [ ] Generate generic PDF challan (using `printing` or `pdf` package)
* [ ] Include company name, dispatch details, and item table
* [ ] Enable download and share
* [ ] Add snackbar confirmations and form validations

**Acceptance Criteria:**

* PDF layout exports correctly
* All fields populate as expected
* User prevented from saving incomplete data

---

## **Phase 19: Deployment & QA**

* [ ] Deploy Supabase changes to production project
* [ ] Test thoroughly on Android, iOS, and Web
* [ ] Conduct QA with real dispatch data

**Acceptance Criteria:**

* Dispatch creation, viewing, and PDF printing work across all platforms
* Data syncs correctly and no major bugs

---

# ✅ Final Notes

* **Version:** v0.7
* **Module:** Dispatch Management
* **Integration:** Inside existing Stylemake project
* **Backend:** Supabase
* **Frontend:** Flutter (Material 3)
* **UI:** Optimistic update model (no local caching yet)
* **Output:** Generic printable PDF challan
* **Ready for production after Phase 19**

```

---

✅ **Instructions:**  
1. Copy everything between the triple backticks.  
2. Paste it into a new file.  
3. Save as **`Sales_Dispatch_Module_PRD_v0.7.md`** in your project folder.

Would you like me to follow this up with a **Cursor rule file** (to enforce clean architecture for this module)?  
It would automatically separate widgets, services, and state logic for cleaner code generation.
```
