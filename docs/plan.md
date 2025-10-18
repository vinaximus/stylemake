# Stylemake

Purpose: Stylemake is a mobile friendly and web friendly app that Manage Fabric to Dispatch of a garment Manufacturing company. Contains 3 modules. The app will be realsed on Android/IOS and on web as a web app.

1. Fabric Module:
2. Production Module: Manage Production from Cutting to Dispatch
3. Dispatch Module: Manages Finished stock

### Requirements from each module

#### Production Module

* Maintain Cuttings Records along with Qty Cut, Cutting Reference No, Date
* For Each Cutting Record, Issue Fabrication PO. Contains Job Order No, Name of Vendor, Date, Completion Date, Fabrication Type: a) Embroidery or b) Stitching and Finishing, Instructions, Notes, Rate per Unit, Qty Issued. For Embroidery, additional paper sheet will be issued, which is out of the scope of Version 1 of this project.
* Record Items issued with Date, Name of Item, Quantity, Rate, related PO ID, and Notes. Name of Item is simply description of the item and is not a separate entity.
* Bills Issued against PO: Contains Supplier Invoice Date, Invoice No, Rate, Quantity, Notes
* Receipts of Finished Goods against The Cutting: Contains Cutting Referecne ID for which the goods has been received, style ID, Qty, Date
* Masters: Style Table (Style ID, Name of the style)
* Vendors: Vendor GST, Vendor Name, Pin, City, Address

#### Technology to Use

Primarily Flutter and Dart will be used, For Statemanagement Riverpod will be used and Supabase will be used as backend.

Plans for Fabric Module and dispatch Module will be written later.
