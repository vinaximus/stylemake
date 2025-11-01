-- Migration 007: Remove quantity_issued and rate_per_unit from fabrication_pos
-- These fields are now recorded in po_order_items table

-- Drop the columns
ALTER TABLE fabrication_pos
DROP COLUMN IF EXISTS quantity_issued;

ALTER TABLE fabrication_pos
DROP COLUMN IF EXISTS rate_per_unit;

