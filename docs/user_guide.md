# Stylemake v0.5 - User Guide

**Production Module - Quick Start Guide**

## Table of Contents

1. [Getting Started](#getting-started)
2. [Master Data Setup](#master-data-setup)
3. [Production Workflow](#production-workflow)
4. [Reports and Export](#reports-and-export)
5. [Common Tasks](#common-tasks)
6. [Tips & Best Practices](#tips--best-practices)
7. [Troubleshooting](#troubleshooting)

## Getting Started

### First Time Setup

When you first open Stylemake, you'll see the main navigation with three tabs:
- **Production** - Manage cuttings, POs, issues, bills, and receipts
- **Masters** - Manage styles and vendors
- **Reports** - View production summaries and KPIs

**First Steps:**
1. Start with **Masters** tab to set up styles and vendors
2. Then move to **Production** to begin your workflow
3. Use **Reports** to analyze your data

### Navigation

The app uses a bottom navigation bar (mobile) or side navigation (web/desktop):
- Tap/click icons to switch between sections
- Use the "+" button or FAB to add new records
- Tap list items to view details
- Use search and filters to find records quickly

## Master Data Setup

### Adding Styles

Styles represent your product types (e.g., "Summer Shirt", "Denim Jeans").

**Steps:**
1. Go to **Masters** tab
2. Select **Styles**
3. Click the **"+" button**
4. Enter **Style Name**
5. Click **Save**

**Tips:**
- Use clear, descriptive names
- Keep names consistent
- Styles can be edited or deleted later
- Styles are used throughout the production workflow

### Adding Vendors

Vendors are your fabrication partners (embroidery, stitching, etc.).

**Steps:**
1. Go to **Masters** tab
2. Select **Vendors**
3. Click the **"+" button**
4. Fill in vendor details:
   - **Name** (required)
   - **GST Number** (optional)
   - **Address**
   - **City**
   - **PIN Code**
5. Click **Save**

**Search & Filter:**
- Use search bar to find vendors by name
- Filter by city using the dropdown
- Click vendor to view/edit details

## Production Workflow

### Step 1: Create Cutting Record

Cutting records track fabric cutting operations.

**Steps:**
1. Go to **Production** → **Cuttings**
2. Click **"+" button**
3. Enter details:
   - **Cutting Reference** (e.g., "CUT-001")
   - **Cutting Date**
   - **Style** (select from dropdown)
   - **Quantity Cut** (number of pieces)
   - **Notes** (optional)
4. Click **Save**

**What Happens:**
- Cutting record is created
- You can now create POs against this cutting
- Record appears in cuttings list

### Step 2: Issue Purchase Order (PO)

POs are issued to vendors for fabrication work.

**Steps:**
1. Open a **Cutting Record** from the list
2. Click **"Create PO"** button
3. Fill in PO details:
   - **Job Order Number** (your internal reference)
   - **Vendor** (select from dropdown)
   - **Fabrication Type** (Embroidery or Stitching & Finishing)
   - **Issue Date**
   - **Completion Date** (expected)
   - **Quantity Issued**
   - **Rate per Unit**
   - **Instructions** (optional)
4. Click **Save**

**What Happens:**
- PO Number auto-generated (e.g., "PO-0001")
- Total cost calculated automatically
- PO linked to cutting record
- PO can be exported to PDF

**PDF Export:**
- Click **"Export PDF"** button on PO detail
- PDF includes all PO details, vendor info, and cutting reference
- Can be printed or shared with vendor

### Step 3: Issue Items (Optional)

Track materials and items issued to vendors.

**Steps:**
1. Open a **PO Detail** screen
2. Click **"Issue Items"** button
3. Enter item details:
   - **Issue Date**
   - **Item Description** (e.g., "Thread spools", "Buttons")
   - **Quantity**
   - **Rate per unit**
   - **Notes** (optional)
4. Click **Save**

**What Happens:**
- Item issue recorded against PO
- Total cost calculated (Qty × Rate)
- All issues visible on PO detail
- Total issued amount aggregated

### Step 4: Record Bills

Track supplier invoices received.

**Steps:**
1. Open a **PO Detail** screen
2. Click **"Add Bill"** button
3. Enter bill details:
   - **Supplier Invoice Number**
   - **Invoice Date**
   - **Quantity** (billed quantity)
   - **Rate** (per unit)
   - **Notes** (optional)
4. Click **Save**

**What Happens:**
- Bill linked to PO
- Total amount calculated automatically
- All bills visible on PO detail and cutting detail
- Total billed amount aggregated

### Step 5: Receive Finished Goods

Record completed items received from vendor.

**Steps:**
1. Go to **Production** → **Receipts**
2. Click **"+" button**
3. Enter receipt details:
   - **Cutting Reference** (select from dropdown)
   - **Style** (auto-filled based on cutting)
   - **Quantity Received**
   - **Date of Receipt**
   - **Notes** (optional - damage, quality issues, etc.)
4. Click **Save**

**What Happens:**
- Receipt ID auto-generated (e.g., "REC-0001")
- Receipt linked to cutting and style
- Quantity received tracked
- Receipts visible on cutting detail

## Reports and Export

### Production Summary Report

View aggregated production data and KPIs.

**Steps:**
1. Go to **Reports** tab
2. Select **Production Summary**
3. Use filters:
   - **Date Range** (From/To dates)
   - **Style** (optional filter)
4. Click **Generate Report**

**KPIs Displayed:**
- **Total Quantity Cut**
- **Total Quantity Issued** (to vendors)
- **Total Quantity Received** (finished goods)
- **Total Bill Cost** (all supplier bills)

**Export to CSV:**
- Click **"Export CSV"** button
- CSV file contains all KPI data
- Can be opened in Excel/Google Sheets

### List CSV Exports

Export lists for external analysis.

**Available Exports:**
1. **Cuttings List**
   - Go to Cuttings List
   - Click download icon in header
   - Exports all filtered/searched cuttings

2. **POs List**
   - Go to POs List
   - Click download icon in header
   - Exports all filtered POs with calculated totals

3. **Receipts List**
   - Go to Receipts List
   - Click download icon in header
   - Exports all filtered receipts

**CSV Details:**
- Includes all visible columns
- Formatted dates and numbers
- Respects current filters/search
- Timestamped filename

## Common Tasks

### Editing Records

**To Edit:**
1. Navigate to the list
2. Click/tap the record
3. Click **"Edit"** button (pencil icon)
4. Make changes
5. Click **Save**

**Editable Fields:**
- Most fields can be edited
- Auto-generated IDs cannot be changed (PO Number, Receipt ID)
- Links to other records can be changed

### Deleting Records

**To Delete:**
1. Navigate to the list
2. Click/tap the record
3. Click **"Delete"** button (trash icon)
4. Confirm deletion

**Warning:**
- Deletion is permanent
- Related records are NOT automatically deleted
- Be careful with records that have dependencies

### Searching and Filtering

**Search:**
- Use search bar at top of lists
- Searches across multiple fields
- Real-time results as you type

**Filters:**
- Use dropdown filters (Style, Vendor, Type, etc.)
- Use date range picker for date filtering
- Click **"Clear Filters"** to reset
- Active filters show count badge

### Viewing Linked Records

**From Cutting Detail:**
- View all POs for this cutting
- View all item issues (across all POs)
- View all bills (across all POs)
- View all receipts for this cutting

**From PO Detail:**
- View parent cutting
- View all item issues for this PO
- View all bills for this PO

## Tips & Best Practices

### Data Entry

1. **Use Consistent Naming:**
   - Keep cutting references consistent (e.g., "CUT-001", "CUT-002")
   - Use clear style names
   - Vendor names should be official/legal names

2. **Fill in Optional Fields:**
   - Notes fields are helpful for tracking issues
   - Instructions on POs help vendors understand requirements
   - GST numbers help with tax compliance

3. **Enter Data Promptly:**
   - Record cuttings on the day they happen
   - Issue POs quickly to track timeline
   - Record receipts immediately upon arrival

### Workflow Organization

1. **Complete Workflow in Order:**
   - Always create cutting first
   - Then PO linked to cutting
   - Then issues/bills against PO
   - Finally receipt against cutting

2. **Use Reports Regularly:**
   - Check production summary weekly
   - Export data for external analysis
   - Monitor quantity cut vs. received for losses

3. **Keep Master Data Clean:**
   - Periodically review and clean up unused styles
   - Update vendor contact information as needed
   - Delete test/dummy data

### Real-time Sync

1. **Multiple Users:**
   - App updates automatically when others make changes
   - No need to refresh manually
   - Works across devices and browsers

2. **Network Issues:**
   - If connection lost, app shows error messages
   - Data is not saved until connection restored
   - Refresh page if updates stop appearing

## Troubleshooting

### Common Issues

**"Failed to load data"**
- Check internet connection
- Verify Supabase credentials in `.env`
- Run `dart scripts/verify_backup.dart` to test connection

**"Record not found"**
- Record may have been deleted by another user
- App will update automatically
- Go back and try again

**"Failed to save"**
- Check all required fields are filled
- Verify dates are valid (Completion Date ≥ Issue Date)
- Check quantities are positive numbers
- Look for specific error message

**CSV Export not working (Web)**
- CSV content logged to browser console
- Check Downloads folder
- Try export on mobile for full functionality

**Styles/Vendors not appearing in dropdowns**
- Refresh the page
- Ensure styles/vendors exist in Masters
- Check real-time sync is working

### Getting Help

**Before Contacting Support:**
1. Check this user guide
2. Review error messages carefully
3. Try refreshing the page
4. Check [Known Limitations](../README.md#known-limitations)

**Contact Support:**
- Email: support@stylemake.com
- Include: Error message, steps to reproduce, screenshots
- Check documentation: [docs/](../)

### Reset and Recovery

**Clear Local Data:**
```bash
# Clear browser cache and cookies
# Then reload the app
```

**Verify Database:**
```bash
dart scripts/verify_backup.dart
```

**Backup Data:**
- Use CSV exports to backup data regularly
- Supabase automatic backups configured (see admin docs)

## Keyboard Shortcuts

### Navigation
- `Tab` - Navigate through form fields
- `Enter` - Submit forms
- `Esc` - Close dialogs

### Lists
- `Ctrl/Cmd + F` - Focus search (if supported)
- Click items to open details

## Mobile-Specific Tips

### Gestures
- Tap to select
- Long-press may show additional options
- Swipe to scroll lists
- Pinch to zoom (some screens)

### Orientation
- Portrait mode recommended for forms
- Landscape works for lists and reports
- App adapts to device size

### Offline Mode
- Currently not supported
- Requires internet connection
- Future versions will add offline capability

## Best Practices Checklist

- [ ] Set up all styles before starting production
- [ ] Add all vendors with complete contact info
- [ ] Record cuttings immediately after cutting
- [ ] Issue POs within 24 hours of cutting
- [ ] Track all item issues for cost accuracy
- [ ] Record bills when invoices received
- [ ] Log receipts immediately upon arrival
- [ ] Review production summary weekly
- [ ] Export data for backup monthly
- [ ] Keep master data clean and updated

## Glossary

- **Cutting** - Fabric cutting operation record
- **PO** - Purchase Order issued to vendor
- **Fabrication** - Manufacturing process (embroidery/stitching)
- **Item Issue** - Materials/items given to vendor
- **Bill** - Supplier invoice for fabrication work
- **Receipt** - Finished goods received from vendor
- **Style** - Product type or design
- **Vendor** - External fabrication partner
- **Master Data** - Reference data (styles, vendors)

---

**For More Information:**
- [README](../README.md) - Setup and installation
- [Database Schema](database_schema_reference.md) - Technical reference
- [Performance Report](performance_report.md) - System performance

**Version:** 0.5.0  
**Last Updated:** October 2025

