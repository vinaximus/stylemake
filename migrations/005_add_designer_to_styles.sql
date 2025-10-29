-- Migration 005: Add Designer Field to Styles Table
-- This adds a designer field to the styles table for Phase 15 implementation

-- Add designer column to styles table
ALTER TABLE styles ADD COLUMN designer TEXT;

-- Create index on designer field for better search performance
CREATE INDEX idx_styles_designer ON styles(designer);

-- Add comment to document the new field
COMMENT ON COLUMN styles.designer IS 'Designer name for the style/product (optional)';
