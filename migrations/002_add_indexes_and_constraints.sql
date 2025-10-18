-- Migration 002: Add Indexes and Constraints
-- This adds foreign keys, indexes for performance, and unique constraints

-- Foreign Key Constraints

-- Cuttings references Styles
ALTER TABLE cuttings
ADD CONSTRAINT fk_cuttings_style
FOREIGN KEY (style_id) REFERENCES styles(id)
ON DELETE RESTRICT;

-- Fabrication POs reference Cuttings and Vendors
ALTER TABLE fabrication_pos
ADD CONSTRAINT fk_fabrication_pos_cutting
FOREIGN KEY (cutting_id) REFERENCES cuttings(id)
ON DELETE RESTRICT;

ALTER TABLE fabrication_pos
ADD CONSTRAINT fk_fabrication_pos_vendor
FOREIGN KEY (vendor_id) REFERENCES vendors(id)
ON DELETE RESTRICT;

-- Item Issues reference Fabrication POs
ALTER TABLE item_issues
ADD CONSTRAINT fk_item_issues_po
FOREIGN KEY (po_id) REFERENCES fabrication_pos(id)
ON DELETE CASCADE;

-- Bills reference Fabrication POs
ALTER TABLE bills
ADD CONSTRAINT fk_bills_po
FOREIGN KEY (po_id) REFERENCES fabrication_pos(id)
ON DELETE CASCADE;

-- Receipts reference Cuttings and Styles
ALTER TABLE receipts
ADD CONSTRAINT fk_receipts_cutting
FOREIGN KEY (cutting_id) REFERENCES cuttings(id)
ON DELETE RESTRICT;

ALTER TABLE receipts
ADD CONSTRAINT fk_receipts_style
FOREIGN KEY (style_id) REFERENCES styles(id)
ON DELETE RESTRICT;

-- Unique Constraints (for reference numbers)

ALTER TABLE cuttings
ADD CONSTRAINT unique_cutting_ref_per_company
UNIQUE (cutting_ref, company_id);

ALTER TABLE fabrication_pos
ADD CONSTRAINT unique_po_number_per_company
UNIQUE (po_number, company_id);

ALTER TABLE receipts
ADD CONSTRAINT unique_receipt_id_per_company
UNIQUE (receipt_id, company_id);

-- Performance Indexes

-- Indexes on company_id for all tables (for multi-tenancy filtering)
CREATE INDEX idx_styles_company_id ON styles(company_id);
CREATE INDEX idx_vendors_company_id ON vendors(company_id);
CREATE INDEX idx_cuttings_company_id ON cuttings(company_id);
CREATE INDEX idx_fabrication_pos_company_id ON fabrication_pos(company_id);
CREATE INDEX idx_item_issues_company_id ON item_issues(company_id);
CREATE INDEX idx_bills_company_id ON bills(company_id);
CREATE INDEX idx_receipts_company_id ON receipts(company_id);

-- Indexes on foreign keys (for join performance)
CREATE INDEX idx_cuttings_style_id ON cuttings(style_id);
CREATE INDEX idx_fabrication_pos_cutting_id ON fabrication_pos(cutting_id);
CREATE INDEX idx_fabrication_pos_vendor_id ON fabrication_pos(vendor_id);
CREATE INDEX idx_item_issues_po_id ON item_issues(po_id);
CREATE INDEX idx_bills_po_id ON bills(po_id);
CREATE INDEX idx_receipts_cutting_id ON receipts(cutting_id);
CREATE INDEX idx_receipts_style_id ON receipts(style_id);

-- Indexes on date fields (for filtering and reporting)
CREATE INDEX idx_cuttings_cutting_date ON cuttings(cutting_date);
CREATE INDEX idx_fabrication_pos_date_of_issue ON fabrication_pos(date_of_issue);
CREATE INDEX idx_fabrication_pos_completion_date ON fabrication_pos(completion_date);
CREATE INDEX idx_item_issues_issue_date ON item_issues(issue_date);
CREATE INDEX idx_bills_invoice_date ON bills(invoice_date);
CREATE INDEX idx_receipts_date_of_receipt ON receipts(date_of_receipt);

-- Indexes on commonly searched text fields
CREATE INDEX idx_vendors_city ON vendors(city);
CREATE INDEX idx_vendors_name ON vendors(name);
CREATE INDEX idx_styles_name ON styles(name);

-- Composite indexes for common queries
CREATE INDEX idx_cuttings_company_date ON cuttings(company_id, cutting_date DESC);
CREATE INDEX idx_fabrication_pos_company_date ON fabrication_pos(company_id, date_of_issue DESC);

