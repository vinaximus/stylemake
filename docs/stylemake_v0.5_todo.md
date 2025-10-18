# Stylemake — v0.5 TODOs (phased, step-by-step)
*Derived from the PRD: “Stylemake v0.5 — Production Requirement Document”.*

Below is a phased, minimal-step TODO list for **v0.5 (Production Module)**. Tasks are ordered **easy → hard**. Each item has clear acceptance criteria. Use this as a sprint backlog (each checkbox = one dev task).

---

## Phase 0 — Project initialization (very small, must be first) ✅ COMPLETED
- [x] **Create repo & branches**
  - Acceptance criteria:
    - Git repo created (GitHub/GitLab). ✅
    - Branches: `main`, `develop`, `feature/*` exist. ✅
    - README with short project purpose present. ✅
- [x] **Create Flutter project skeleton (web + mobile)**
  - Acceptance criteria:
    - `flutter create` project exists and builds for `android`, `ios`, `web`. ✅
    - App runs on emulator/browser and shows placeholder home screen. ✅
- [x] **Add core dependencies & scaffolding**
  - Acceptance criteria:
    - `pubspec.yaml` includes Riverpod, Supabase client, Material 3 support, and routing package. ✅
    - App compiles without analyzer errors (except TODO comments). ✅
- [x] **Configure environment & secrets (local dev)**
  - Acceptance criteria:
    - `.env.example` with keys (SUPABASE_URL, SUPABASE_ANON_KEY) added. ✅
    - `flutter_dotenv` (or chosen approach) integrated; app reads env without crashing. ✅
- [x] **Project linting & formatting**
  - Acceptance criteria:
    - `analysis_options.yaml` present. ✅
    - `flutter format`/`dart analyze` pass on added files. ✅

---

## Phase 1 — Supabase baseline & DB schema (single-company defaults) ✅ COMPLETED
- [x] **Create Supabase project & baseline tables (schema from PRD)**
  - Acceptance criteria:
    - Supabase project created and accessible. ✅
    - Tables created: `cuttings`, `fabrication_pos`, `item_issues`, `bills`, `receipts`, `styles`, `vendors`. ✅
    - All tables include `company_id` and `user_id` defaulting to `00000000-0000-0000-0000-000000000000` as specified. ✅
- [x] **Add basic indices and constraints**
  - Acceptance criteria:
    - Primary keys present. ✅
    - Foreign key references where applicable (e.g., PO → cutting, issue → PO). ✅
- [x] **Seed minimal master data**
  - Acceptance criteria:
    - At least 3 styles and 3 vendors inserted for UI testing. ✅

---

## Phase 2 — Shared UI components & navigation (Material 3) ✅ COMPLETED
- [x] **Implement AppShell & bottom navigation**
  - Acceptance criteria:
    - Bottom nav shows tabs: Production, Masters (Style/Vendor), Reports. ✅
    - Navigation routes work on mobile & web. ✅
- [x] **Create reusable Card list item & FAB**
  - Acceptance criteria:
    - Card item component usable with title, subtitle, trailing actions. ✅
    - FAB appears on list pages and opens the Add form. ✅
- [x] **Form component & validation utilities**
  - Acceptance criteria:
    - Centralized form field widget with validation messages. ✅
    - Required field validations wired; invalid forms prevent submit and show errors. ✅

---

## Phase 3 — Masters: Style Master & Vendor Master (CRUD) ✅ COMPLETED
- [x] **Style Master — Add/Edit/Delete/List**
  - Acceptance criteria:
    - Create Style form saves to `styles`. ✅
    - Edit and Delete work with confirmation modal. ✅
    - List supports search & pagination. ✅
- [x] **Vendor Master — Add/Edit/Delete/List**
  - Acceptance criteria:
    - Vendor create form collects Vendor Name, GST, Address, City, PIN Code and stores in `vendors`. ✅
    - List can filter by City or Name. ✅
- [x] **Master integration in dropdowns**
  - Acceptance criteria:
    - Styles and Vendors populate dropdowns in other forms (Cutting, PO) instantly (or on refresh). ✅

---

## Phase 4 — Cutting Records (CRUD + list + filters) ✅ COMPLETED
- [x] **Cutting — Add form**
  - Acceptance criteria:
    - Form fields: Cutting Ref (auto/manual), Cutting Date, Quantity Cut, Style ID, Notes. ✅
    - On save, record appears in Cuttings table with company_id default. ✅
- [x] **Cutting — Edit/Delete**
  - Acceptance criteria:
    - Edit updates the DB; delete requires confirmation and removes the record. ✅
- [x] **Cutting — List & Filters**
  - Acceptance criteria:
    - List shows cutting ref, date, qty, style. ✅
    - Filters: Date range, Style, Reference No. ✅
    - List loads within 2 seconds for up to 500 records. ✅
- [x] **Linking placeholder for Fabrication POs**
  - Acceptance criteria:
    - Cutting detail screen shows linked POs (initially empty) and button to create PO linked to this Cutting. ✅

---

## Phase 5 — Fabrication Purchase Orders (PO) ✅ COMPLETED
- [x] **PO — Create form**
  - Acceptance criteria:
    - Fields: Auto PO No, Cutting Ref (linked), Job Order No, Vendor (dropdown), Fabrication Type, Issue Date, Completion Date, Qty Issued, Rate per unit, Notes. ✅
    - On save, PO saved to `fabrication_pos` and linked to cutting. ✅
- [x] **PO — Edit/Delete & validations**
  - Acceptance criteria:
    - Edit updates DB; deletion requires confirmation. ✅
    - Qty and Rate validations: positive numbers; Completion Date ≥ Issue Date. ✅
- [x] **PO — List, filters, and export to PDF**
  - Acceptance criteria:
    - PO list supports filtering by Vendor, Type, Date. ✅
    - "Export to PDF" creates a simple, readable PDF of the PO (downloadable) containing PO details and cutting ref. ✅
    - Exported PDF opens and displays correctly in browser/mobile PDF viewer. ✅
- [x] **Auto-generate PO Number**
  - Acceptance criteria:
    - PO number follows consistent pattern (e.g., `PO-0001`) and increments. ✅

---

## Phase 6 — Item Issue Records (per PO)
- [ ] **Issue — Create & link to PO**
  - Acceptance criteria:
    - Issue form contains Issue Date, Related PO dropdown, Item Description, Qty, Rate, Notes.
    - On save, total (qty × rate) stored or calculable.
- [ ] **Issue — Edit/Delete & view by PO**
  - Acceptance criteria:
    - Issues editable/deletable.
    - Issue list view filterable by PO and Date.
- [ ] **Show issues on PO detail**
  - Acceptance criteria:
    - PO detail displays a list of Issues linked to it with totals.

---

## Phase 7 — Bills issued against PO (supplier invoices)
- [ ] **Bill — Create form & auto-calc**
  - Acceptance criteria:
    - Fields: Supplier Invoice No, Invoice Date, Related PO, Qty, Rate, Notes.
    - Total auto-calculated (Qty × Rate) and displayed.
- [ ] **Bill — Edit/Delete & link**
  - Acceptance criteria:
    - Bills editable/deletable and linked to PO.
    - Bill list shows supplier, PO ref, invoice date, total.
- [ ] **Bill summary per vendor**
  - Acceptance criteria:
    - Vendor detail page shows aggregated bills (count + sum) for selected date range.

---

## Phase 8 — Receipts of Finished Goods + Production Summary
- [ ] **Receipt — Create & link to Cutting**
  - Acceptance criteria:
    - Receipt form: Receipt ID auto, Cutting Ref, Style ID, Qty Received, Date, Notes.
    - On save, updates `receipts` table and marks quantities against cutting.
- [ ] **Receipt — Edit/Delete & list**
  - Acceptance criteria:
    - Receipt CRUD works; list filterable by date/style.
- [ ] **Production Summary Report**
  - Acceptance criteria:
    - Report combines Cuttings, POs, Issues, Bills, Receipts for a date range and style.
    - Report can be exported as CSV.
    - Summary shows totals: qty cut, qty issued to vendors, qty received, total cost from bills.

---

## Phase 9 — Supabase sync, offline considerations & security defaults
- [ ] **Supabase integration for CRUD**
  - Acceptance criteria:
    - All create/read/update/delete operations use Supabase client.
    - Errors from Supabase gracefully surfaced to user with meaningful messages.
- [ ] **Real-time sync baseline (optional subscription)**
  - Acceptance criteria:
    - Implement basic real-time listeners for lists (e.g., cuttings) using Supabase Realtime.
    - When a new item is added elsewhere (test with two browser tabs), list updates automatically.
- [ ] **Security & defaults (single-user mode)**
  - Acceptance criteria:
    - All queries include `company_id = '00000000-0000-0000-0000-000000000000'` by default.

---

## Phase 10 — UI/UX polish, accessibility, testing
- [ ] **Material 3 styling & theme**
  - Acceptance criteria:
    - Theme uses primary Indigo/Deep Blue and specified typography.
    - Components follow Material 3 guidelines (cards, FABs).
- [ ] **Mobile-first responsive fixes**
  - Acceptance criteria:
    - Views render correctly on narrow (mobile) and wide (desktop) screens.
- [ ] **Accessibility basics**
  - Acceptance criteria:
    - Buttons have semantic labels; forms have `aria`-equivalents where applicable.
- [ ] **Unit & integration tests**
  - Acceptance criteria:
    - Add tests for at least: Creating a Style, Creating a Cutting, Creating a PO, and exporting PDF.
    - CI runs tests on `develop` branch; failing tests block merge.

---

## Phase 11 — Non-functional requirements (perf, backup, logging)
- [ ] **Performance checks**
  - Acceptance criteria:
    - Lists (Cuttings, POs, Vendors) load within **2 seconds** with 500 records in staging.
    - Sync operations tested to complete within 5 seconds on simulated 4G/broadband.
- [ ] **Daily backup verification**
  - Acceptance criteria:
    - Supabase automatic daily backups configured.
    - Manual CSV export for Cuttings/POs/Receipts available from UI.
- [ ] **Error logging & monitoring**
  - Acceptance criteria:
    - Basic error logging (Sentry or similar) integrated; uncaught errors sent to monitoring dashboard.
    - Alerts configured for repeated failures (optional).

---

## Phase 12 — Release checklist (v0.5)
- [ ] **Sanity tests**
  - Acceptance criteria:
    - Walkthrough: Create Style → Create Cutting → Create PO linked to Cutting → Issue Items → Create Bill → Receive goods; all steps succeed and data links show correctly.
- [ ] **Documentation (short)**
  - Acceptance criteria:
    - README includes setup steps, env vars, schema overview.
    - One-pager user guide for the Production module with screenshots.
- [ ] **Tag & release**
  - Acceptance criteria:
    - `v0.5` tag created, release notes published listing implemented features and known limitations (no auth, single-company).
- [ ] **Post-release smoke monitoring**
  - Acceptance criteria:
    - Monitor logs and error rates for 48 hours; critical issues triaged.

---

## Quick prioritization (sprint sizing)
1. Phase 0 (init) — 0.5 day  
2. Phase 1 (Supabase & schema) — 1 day  
3. Phase 2 (shared UI) — 1 day  
4. Phase 3 (Masters) — 1 day  
5. Phase 4 (Cuttings) — 1.5 days  
6. Phase 5 (POs) — 2 days  
7. Phase 6 (Issues) — 1 day  
8. Phase 7 (Bills) — 1 day  
9. Phase 8 (Receipts & reports) — 1.5 days  
10. Phase 9–11 (sync, polish, tests, non-functional) — 2–3 days  
11. Release checklist — 0.5–1 day

*(Adjust estimates to your team size — these are rough priorities, not deadlines.)*

---

## Notes / assumptions
- v0.5 is **single-user / single-company** per PRD (authentication is planned for v0.6+). All DB rows use the default `company_id`/`user_id` placeholders.  
- PDF export can initially be serverless (render in client) — keep design minimal for v0.5.
- Real-time sync is helpful but not mandatory for MVP — implement a basic listener first.
