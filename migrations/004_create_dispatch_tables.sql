-- Migration 004: Create Dispatch Module Tables for Stylemake v0.7
-- This creates customers, dispatch_master, and dispatch_items tables for the dispatch management module

-- 1. Customers Master Table
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_name TEXT NOT NULL,
    contact_person TEXT,
    phone TEXT,
    address TEXT,
    gst_no TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 2. Dispatch Master Table
CREATE TABLE IF NOT EXISTS dispatch_master (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dispatch_no TEXT NOT NULL,
    dispatch_date DATE NOT NULL DEFAULT CURRENT_DATE,
    customer_id UUID NOT NULL,
    transport_name TEXT,
    vehicle_no TEXT,
    lr_no TEXT,
    total_quantity NUMERIC DEFAULT 0 CHECK (total_quantity >= 0),
    remarks TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 3. Dispatch Items Table
CREATE TABLE IF NOT EXISTS dispatch_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dispatch_id UUID NOT NULL,
    style_id UUID NOT NULL,
    color TEXT,
    size TEXT,
    quantity NUMERIC NOT NULL CHECK (quantity > 0),
    rate NUMERIC CHECK (rate >= 0),
    remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Foreign Key Constraints
ALTER TABLE dispatch_master
ADD CONSTRAINT fk_dispatch_master_customer
FOREIGN KEY (customer_id) REFERENCES customers(id)
ON DELETE RESTRICT;

ALTER TABLE dispatch_items
ADD CONSTRAINT fk_dispatch_items_dispatch
FOREIGN KEY (dispatch_id) REFERENCES dispatch_master(id)
ON DELETE CASCADE;

ALTER TABLE dispatch_items
ADD CONSTRAINT fk_dispatch_items_style
FOREIGN KEY (style_id) REFERENCES styles(id)
ON DELETE RESTRICT;

-- Unique Constraints
ALTER TABLE dispatch_master
ADD CONSTRAINT unique_dispatch_no_per_company
UNIQUE (dispatch_no, company_id);

-- Performance Indexes

-- Company ID indexes (for multi-tenancy filtering)
CREATE INDEX idx_customers_company_id ON customers(company_id);
CREATE INDEX idx_dispatch_master_company_id ON dispatch_master(company_id);

-- Foreign key indexes (for join performance)
CREATE INDEX idx_dispatch_master_customer_id ON dispatch_master(customer_id);
CREATE INDEX idx_dispatch_items_dispatch_id ON dispatch_items(dispatch_id);
CREATE INDEX idx_dispatch_items_style_id ON dispatch_items(style_id);

-- Date indexes (for filtering and reporting)
CREATE INDEX idx_dispatch_master_dispatch_date ON dispatch_master(dispatch_date);

-- Text search indexes
CREATE INDEX idx_customers_customer_name ON customers(customer_name);
CREATE INDEX idx_dispatch_master_dispatch_no ON dispatch_master(dispatch_no);

-- Composite indexes (for common queries)
CREATE INDEX idx_dispatch_master_company_date ON dispatch_master(company_id, dispatch_date DESC);

-- Auto-update triggers for updated_at columns
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_dispatch_master_updated_at BEFORE UPDATE ON dispatch_master
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Seed data for customers (optional - for testing)
INSERT INTO customers (id, customer_name, contact_person, phone, address, gst_no, company_id, user_id) VALUES
    ('c1111111-1111-1111-1111-111111111111', 'Fashion Store Mumbai', 'Rajesh Kumar', '+91-9876543210', '123 Fashion Street, Mumbai', '27AABCF1234A1Z5', '00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000'),
    ('c2222222-2222-2222-2222-222222222222', 'Style Boutique Delhi', 'Priya Sharma', '+91-9876543211', '456 Style Avenue, Delhi', '07AABCF5678B2Z6', '00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000'),
    ('c3333333-3333-3333-3333-333333333333', 'Trendy Garments Bangalore', 'Amit Patel', '+91-9876543212', '789 Trend Road, Bangalore', '29AABCF9012C3Z7', '00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000')
ON CONFLICT (id) DO NOTHING;
