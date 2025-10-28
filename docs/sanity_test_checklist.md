# Stylemake v0.5 - Sanity Test Checklist

**Pre-Release Testing Guide**

## Purpose

This checklist ensures all critical functionality works correctly before releasing v0.5. Perform these tests in order on a clean database instance.

## Environment Setup

### Prerequisites
- [ ] Clean Supabase database with migrations applied
- [ ] `.env` file configured with test credentials
- [ ] App running on target platform (Web/Android/iOS)
- [ ] Browser DevTools or Flutter DevTools open for debugging

### Test Data Cleanup
```bash
# Start with fresh database
# Run migrations 001, 002, 003
# Verify seed data exists
dart scripts/verify_backup.dart
```

**Expected Output:**
- 3 styles (from seed data)
- 3 vendors (from seed data)
- 0 cuttings, POs, issues, bills, receipts

---

## Test Suite

### Test 1: Master Data Management

#### 1.1 Create Style
- [ ] Navigate to **Masters** → **Styles**
- [ ] Click **"+" button**
- [ ] Enter style name: "Test Style Alpha"
- [ ] Click **Save**
- [ ] **Verify:** Success message shown
- [ ] **Verify:** "Test Style Alpha" appears in styles list
- [ ] **Verify:** Total style count is now 4

#### 1.2 Edit Style
- [ ] Click on "Test Style Alpha"
- [ ] Click **Edit** button
- [ ] Change name to: "Test Style Alpha - Updated"
- [ ] Click **Save**
- [ ] **Verify:** Name updated in list
- [ ] **Verify:** List refreshes automatically

#### 1.3 Search Style
- [ ] Use search bar, type: "Alpha"
- [ ] **Verify:** Only "Test Style Alpha - Updated" shown
- [ ] Clear search
- [ ] **Verify:** All 4 styles shown

#### 1.4 Create Vendor
- [ ] Navigate to **Masters** → **Vendors**
- [ ] Click **"+" button**
- [ ] Enter details:
  - Name: "Test Vendor Embroidery"
  - GST: "29ABCDE1234F1Z5"
  - Address: "123 Test Street"
  - City: "Mumbai"
  - PIN: "400001"
- [ ] Click **Save**
- [ ] **Verify:** Success message shown
- [ ] **Verify:** Vendor appears in list
- [ ] **Verify:** Total vendor count is now 4

#### 1.5 Filter Vendor by City
- [ ] Use city filter dropdown, select: "Mumbai"
- [ ] **Verify:** Only vendors in Mumbai shown
- [ ] Clear filter
- [ ] **Verify:** All 4 vendors shown

---

### Test 2: Production Workflow (Complete End-to-End)

#### 2.1 Create Cutting Record
- [ ] Navigate to **Production** → **Cuttings**
- [ ] Click **"+" button**
- [ ] Enter details:
  - Cutting Ref: "CUT-TEST-001"
  - Date: Today's date
  - Style: "Test Style Alpha - Updated"
  - Quantity Cut: 100
  - Notes: "Test cutting for sanity check"
- [ ] Click **Save**
- [ ] **Verify:** Success message shown
- [ ] **Verify:** Cutting appears in list with correct details
- [ ] **Verify:** Style name displayed correctly

#### 2.2 Create PO Linked to Cutting
- [ ] Click on "CUT-TEST-001" to open detail
- [ ] Click **"Create PO"** button
- [ ] **Verify:** Cutting pre-selected (CUT-TEST-001)
- [ ] **Verify:** Style pre-filled from cutting
- [ ] Enter PO details:
  - Job Order No: "JOB-001"
  - Vendor: "Test Vendor Embroidery"
  - Fabrication Type: "Embroidery"
  - Issue Date: Today
  - Completion Date: Tomorrow
  - Quantity Issued: 100
  - Rate per Unit: 50.00
  - Instructions: "Test PO - Handle with care"
- [ ] Click **Save**
- [ ] **Verify:** Success message shown
- [ ] **Verify:** PO Number auto-generated (e.g., "PO-0001")
- [ ] **Verify:** Total calculated correctly (100 × 50 = 5000)
- [ ] **Verify:** Redirected to PO detail screen

#### 2.3 Export PO to PDF
- [ ] On PO detail screen, click **"Export PDF"** button
- [ ] **Verify:** PDF opens/downloads
- [ ] **Verify:** PDF contains:
  - PO Number
  - Vendor details
  - Cutting reference
  - Style name
  - All PO details
  - Total amount

#### 2.4 Issue Items Against PO
- [ ] On PO detail screen, click **"Issue Items"** button
- [ ] Enter item issue details:
  - Issue Date: Today
  - Item Description: "Thread - Red"
  - Quantity: 10
  - Rate: 25.00
  - Notes: "High quality thread"
- [ ] Click **Save**
- [ ] **Verify:** Success message shown
- [ ] **Verify:** Item appears in "Item Issues" section
- [ ] **Verify:** Total calculated (10 × 25 = 250)
- [ ] Click **"Issue Items"** again and add another:
  - Item Description: "Thread - Blue"
  - Quantity: 15
  - Rate: 25.00
- [ ] Click **Save**
- [ ] **Verify:** Both items shown
- [ ] **Verify:** Total issued amount aggregated (250 + 375 = 625)

#### 2.5 Record Bill Against PO
- [ ] On PO detail screen, click **"Add Bill"** button
- [ ] Enter bill details:
  - Supplier Invoice No: "INV-VEN-001"
  - Invoice Date: Today
  - Quantity: 100
  - Rate: 50.00
  - Notes: "First batch completed"
- [ ] Click **Save**
- [ ] **Verify:** Success message shown
- [ ] **Verify:** Bill appears in "Bills" section
- [ ] **Verify:** Amount calculated correctly (100 × 50 = 5000)

#### 2.6 Receive Finished Goods
- [ ] Navigate to **Production** → **Receipts**
- [ ] Click **"+" button**
- [ ] Enter receipt details:
  - Cutting: "CUT-TEST-001"
  - Style: Auto-filled ("Test Style Alpha - Updated")
  - Quantity Received: 95
  - Date: Today
  - Notes: "5 pieces damaged in transit"
- [ ] Click **Save**
- [ ] **Verify:** Success message shown
- [ ] **Verify:** Receipt ID auto-generated (e.g., "REC-0001")
- [ ] **Verify:** Receipt appears in list

---

### Test 3: Data Linkage Verification

#### 3.1 Verify Cutting Detail Shows Linked Records
- [ ] Navigate to **Production** → **Cuttings**
- [ ] Click on "CUT-TEST-001"
- [ ] **Verify:** Displays:
  - Cutting details (ref, date, style, quantity)
  - 1 PO (PO-0001)
  - 2 Item Issues (total ₹625)
  - 1 Bill (₹5000)
  - 1 Receipt (95 pieces)

#### 3.2 Verify PO Detail Shows Parent Cutting
- [ ] From cutting detail, click on PO-0001
- [ ] **Verify:** PO detail displays:
  - Linked cutting: CUT-TEST-001
  - Style: Test Style Alpha - Updated
  - All PO details
  - 2 Item issues
  - 1 Bill

---

### Test 4: Real-time Sync

#### 4.1 Test Multi-Tab Sync (Web)
- [ ] Open app in **TWO browser tabs** (Tab A and Tab B)
- [ ] Both tabs on **Cuttings List** screen
- [ ] In **Tab A**: Create new cutting "CUT-TEST-002"
- [ ] **Verify:** "CUT-TEST-002" appears automatically in **Tab B** (within 2 seconds)
- [ ] In **Tab B**: Edit "CUT-TEST-002", change quantity
- [ ] **Verify:** Change appears automatically in **Tab A**
- [ ] In **Tab A**: Delete "CUT-TEST-002"
- [ ] **Verify:** Record disappears from **Tab B** automatically

#### 4.2 Test Cross-Entity Sync
- [ ] Tab A: Cuttings List
- [ ] Tab B: POs List
- [ ] In **Tab A**: Create new cutting "CUT-TEST-003"
- [ ] In **Tab B**: Click "+" to create PO
- [ ] **Verify:** "CUT-TEST-003" appears in cutting dropdown immediately

---

### Test 5: Search and Filtering

#### 5.1 Cuttings Search
- [ ] Navigate to **Cuttings List**
- [ ] Search: "CUT-TEST"
- [ ] **Verify:** Only test cuttings shown
- [ ] Search: "Alpha"
- [ ] **Verify:** Cuttings with "Alpha" style shown
- [ ] Clear search
- [ ] **Verify:** All cuttings shown

#### 5.2 POs Filtering
- [ ] Navigate to **POs List**
- [ ] Filter by Style: "Test Style Alpha - Updated"
- [ ] **Verify:** Only POs for that style shown
- [ ] Filter by Vendor: "Test Vendor Embroidery"
- [ ] **Verify:** Only POs for that vendor shown
- [ ] Filter by Type: "Embroidery"
- [ ] **Verify:** Only embroidery POs shown
- [ ] Clear all filters
- [ ] **Verify:** All POs shown

#### 5.3 Receipts Date Range Filter
- [ ] Navigate to **Receipts List**
- [ ] Set date range: Last 7 days
- [ ] **Verify:** Only recent receipts shown
- [ ] Set date range: Last 30 days
- [ ] **Verify:** More receipts shown
- [ ] Clear date range
- [ ] **Verify:** All receipts shown

---

### Test 6: CSV Export

#### 6.1 Export Cuttings to CSV
- [ ] Navigate to **Cuttings List**
- [ ] Ensure at least 2 cuttings visible
- [ ] Click **download icon** in header
- [ ] **Verify:** Success message shown
- [ ] **Verify:** CSV file downloaded/shared
- [ ] Open CSV in Excel/Sheets
- [ ] **Verify:** Contains all expected columns and data

#### 6.2 Export POs to CSV
- [ ] Navigate to **POs List**
- [ ] Click **download icon**
- [ ] **Verify:** CSV exported successfully
- [ ] Open CSV
- [ ] **Verify:** Contains PO Number, Job Order, Vendor, Cutting Ref, Style, etc.
- [ ] **Verify:** Calculated totals correct

#### 6.3 Export Receipts to CSV
- [ ] Navigate to **Receipts List**
- [ ] Click **download icon**
- [ ] **Verify:** CSV exported successfully
- [ ] Open CSV
- [ ] **Verify:** Contains Receipt ID, Date, Cutting Ref, Style, Qty

---

### Test 7: Reports

#### 7.1 Production Summary Report
- [ ] Navigate to **Reports** → **Production Summary**
- [ ] Set date range: This month
- [ ] Leave style filter empty (all styles)
- [ ] Click **Generate Report** (if button exists) or view automatically
- [ ] **Verify:** KPIs displayed:
  - Total Quantity Cut > 0
  - Total Quantity Issued > 0
  - Total Quantity Received > 0
  - Total Bill Cost > 0
- [ ] **Verify:** Numbers match data entered

#### 7.2 Export Production Summary
- [ ] On Production Summary screen
- [ ] Click **"Export CSV"** button
- [ ] **Verify:** CSV exported successfully
- [ ] Open CSV
- [ ] **Verify:** Contains all KPIs

---

### Test 8: Error Handling

#### 8.1 Required Field Validation
- [ ] Try to create cutting without filling "Cutting Ref"
- [ ] **Verify:** Error message shown
- [ ] **Verify:** Save prevented
- [ ] Fill all required fields
- [ ] **Verify:** Save succeeds

#### 8.2 Date Validation
- [ ] Create PO with Completion Date **before** Issue Date
- [ ] **Verify:** Error message shown
- [ ] Correct dates (Completion ≥ Issue)
- [ ] **Verify:** Save succeeds

#### 8.3 Numeric Validation
- [ ] Try to enter negative quantity
- [ ] **Verify:** Error or prevented entry
- [ ] Try to enter non-numeric value
- [ ] **Verify:** Error or prevented entry
- [ ] Enter valid positive number
- [ ] **Verify:** Save succeeds

#### 8.4 Network Error Simulation
- [ ] Disconnect internet
- [ ] Try to create a new record
- [ ] **Verify:** User-friendly error message shown
- [ ] **Verify:** Error logged to Crashlytics (check Firebase Console)
- [ ] Reconnect internet
- [ ] Retry operation
- [ ] **Verify:** Operation succeeds

---

### Test 9: Performance

#### 9.1 List Loading Performance
- [ ] Navigate to **Cuttings List**
- [ ] Note load time
- [ ] **Verify:** List loads in < 2 seconds
- [ ] Navigate to **POs List**
- [ ] **Verify:** List loads in < 2 seconds
- [ ] Navigate to **Vendors List**
- [ ] **Verify:** List loads in < 2 seconds

#### 9.2 Real-time Update Latency
- [ ] Open two tabs
- [ ] Create record in Tab A
- [ ] Measure time until visible in Tab B
- [ ] **Verify:** Update appears within 5 seconds

---

### Test 10: Deletion and Cascade Effects

#### 10.1 Delete Style (With Dependencies)
- [ ] Try to delete "Test Style Alpha - Updated" (has cuttings)
- [ ] **Verify:** Deletion succeeds (no cascade protection warning in v0.5)
- [ ] Navigate to Cuttings List
- [ ] **Verify:** Cuttings still exist but may show orphaned style

**Note:** v0.5 does not have cascade delete protection. Document this as a known limitation.

#### 10.2 Delete Cutting (With Dependencies)
- [ ] Try to delete "CUT-TEST-001" (has POs, receipts)
- [ ] **Verify:** Deletion succeeds
- [ ] Navigate to POs List
- [ ] **Verify:** POs still exist but may show orphaned cutting

**Note:** Same as above - document as known limitation.

---

## Test Results Summary

### Test Environment

| Item | Details |
|------|---------|
| Platform | [Web / Android / iOS] |
| OS Version | [e.g., Chrome 120, Android 14, iOS 17] |
| Database | Supabase (Fresh instance) |
| Test Date | [YYYY-MM-DD] |
| Tester | [Your Name] |

### Test Outcomes

| Test Suite | Status | Issues Found | Notes |
|------------|--------|--------------|-------|
| Test 1: Master Data | ✅/❌ | | |
| Test 2: Production Workflow | ✅/❌ | | |
| Test 3: Data Linkage | ✅/❌ | | |
| Test 4: Real-time Sync | ✅/❌ | | |
| Test 5: Search & Filter | ✅/❌ | | |
| Test 6: CSV Export | ✅/❌ | | |
| Test 7: Reports | ✅/❌ | | |
| Test 8: Error Handling | ✅/❌ | | |
| Test 9: Performance | ✅/❌ | | |
| Test 10: Deletion | ✅/❌ | | |

### Critical Issues

List any blocking issues that must be fixed before release:

1. [Issue description]
2. [Issue description]

### Non-Critical Issues

List any minor issues that can be fixed post-release:

1. [Issue description]
2. [Issue description]

### Sign-off

- [ ] All critical tests passed
- [ ] All known limitations documented
- [ ] Performance meets acceptance criteria
- [ ] Ready for release

**Approved By:** _______________  
**Date:** _______________

---

## Post-Test Cleanup

### Reset Database
```sql
-- Run in Supabase SQL Editor to clear test data
DELETE FROM receipts WHERE cutting_id IN (SELECT id FROM cuttings WHERE cutting_ref LIKE 'CUT-TEST%');
DELETE FROM bills WHERE po_id IN (SELECT id FROM fabrication_pos WHERE cutting_id IN (SELECT id FROM cuttings WHERE cutting_ref LIKE 'CUT-TEST%'));
DELETE FROM item_issues WHERE po_id IN (SELECT id FROM fabrication_pos WHERE cutting_id IN (SELECT id FROM cuttings WHERE cutting_ref LIKE 'CUT-TEST%'));
DELETE FROM fabrication_pos WHERE cutting_id IN (SELECT id FROM cuttings WHERE cutting_ref LIKE 'CUT-TEST%');
DELETE FROM cuttings WHERE cutting_ref LIKE 'CUT-TEST%';
DELETE FROM styles WHERE name LIKE 'Test Style%';
DELETE FROM vendors WHERE name LIKE 'Test Vendor%';
```

### Verify Cleanup
```bash
dart scripts/verify_backup.dart
```

Should show only seed data (3 styles, 3 vendors, 0 production records).

---

**Version:** 0.5.0  
**Last Updated:** October 2025  
**Document:** Sanity Test Checklist

