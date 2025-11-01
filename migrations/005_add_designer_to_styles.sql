-- Migration 005: Add Designer Field to Styles Table
-- This adds a designer field to the styles table for Phase 15 implementation
-- This migration is idempotent and can be run multiple times safely

-- Add designer column to styles table (only if it doesn't exist)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'styles' 
        AND column_name = 'designer'
    ) THEN
        ALTER TABLE styles ADD COLUMN designer TEXT;
        
        -- Create index on designer field for better search performance
        CREATE INDEX idx_styles_designer ON styles(designer);
        
        -- Add comment to document the new field
        COMMENT ON COLUMN styles.designer IS 'Designer name for the style/product (optional)';
    END IF;
END $$;
