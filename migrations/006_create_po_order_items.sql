-- Migration 006: Create PO Order Items Table
-- This adds support for multiple order items per Purchase Order

-- PO Order Items Table
CREATE TABLE IF NOT EXISTS po_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_id UUID NOT NULL,
    order_description TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    rate DECIMAL(10, 2) NOT NULL CHECK (rate >= 0),
    note TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    user_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    CONSTRAINT fk_po_order_items_po FOREIGN KEY (po_id) REFERENCES fabrication_pos(id) ON DELETE CASCADE
);

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_po_order_items_po_id ON po_order_items(po_id);
CREATE INDEX IF NOT EXISTS idx_po_order_items_company_id ON po_order_items(company_id);

-- Add unique constraint for display_order per PO (optional, for ordering)
-- This allows ordering items within a PO

