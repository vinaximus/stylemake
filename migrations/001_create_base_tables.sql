-- Migration 001: Create Base Tables for Stylemake v0.5 Production Module
-- This creates all 7 core tables with company_id and user_id defaults for future multi-tenancy

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Styles Master Table
CREATE TABLE IF NOT EXISTS styles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 2. Vendors Master Table
CREATE TABLE IF NOT EXISTS vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    gst TEXT,
    address TEXT,
    city TEXT,
    pin_code TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 3. Cuttings Table
CREATE TABLE IF NOT EXISTS cuttings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cutting_ref TEXT NOT NULL,
    cutting_date DATE NOT NULL,
    quantity_cut INTEGER NOT NULL CHECK (quantity_cut > 0),
    style_id UUID NOT NULL,
    notes TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 4. Fabrication Purchase Orders Table
CREATE TABLE IF NOT EXISTS fabrication_pos (
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
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT check_completion_date CHECK (completion_date IS NULL OR completion_date >= date_of_issue)
);

-- 5. Item Issues Table
CREATE TABLE IF NOT EXISTS item_issues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    issue_date DATE NOT NULL,
    po_id UUID NOT NULL,
    item_description TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    rate DECIMAL(10, 2) NOT NULL CHECK (rate >= 0),
    notes TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 6. Bills Table
CREATE TABLE IF NOT EXISTS bills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    supplier_invoice_no TEXT NOT NULL,
    invoice_date DATE NOT NULL,
    po_id UUID NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    rate DECIMAL(10, 2) NOT NULL CHECK (rate >= 0),
    notes TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 7. Receipts of Finished Goods Table
CREATE TABLE IF NOT EXISTS receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    receipt_id TEXT NOT NULL,
    cutting_id UUID NOT NULL,
    style_id UUID NOT NULL,
    quantity_received INTEGER NOT NULL CHECK (quantity_received > 0),
    date_of_receipt DATE NOT NULL,
    notes TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create updated_at trigger function (reusable for all tables)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers to auto-update updated_at on all tables
CREATE TRIGGER update_styles_updated_at BEFORE UPDATE ON styles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vendors_updated_at BEFORE UPDATE ON vendors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cuttings_updated_at BEFORE UPDATE ON cuttings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fabrication_pos_updated_at BEFORE UPDATE ON fabrication_pos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_item_issues_updated_at BEFORE UPDATE ON item_issues
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bills_updated_at BEFORE UPDATE ON bills
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_receipts_updated_at BEFORE UPDATE ON receipts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

