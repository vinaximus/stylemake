-- Migration 003: Seed Master Data
-- This inserts initial test data for styles and vendors

-- Insert Styles
INSERT INTO styles (id, name, company_id, user_id) VALUES
    ('a1111111-1111-1111-1111-111111111111', 'T-Shirt Basic', '00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000'),
    ('a2222222-2222-2222-2222-222222222222', 'Polo Shirt', '00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000'),
    ('a3333333-3333-3333-3333-333333333333', 'Hoodie', '00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000')
ON CONFLICT (id) DO NOTHING;

-- Insert Vendors
INSERT INTO vendors (id, name, gst, address, city, pin_code, company_id, user_id) VALUES
    (
        'b1111111-1111-1111-1111-111111111111',
        'Embroidery Works Ltd',
        '27AABCU9603R1ZX',
        '123 Industrial Area, Phase 1',
        'Mumbai',
        '400001',
        '00000000-0000-0000-0000-000000000000',
        '00000000-0000-0000-0000-000000000000'
    ),
    (
        'b2222222-2222-2222-2222-222222222222',
        'Premium Stitching Co',
        '29AABCT1332L1Z1',
        '45 Garment District, Near Station',
        'Bangalore',
        '560001',
        '00000000-0000-0000-0000-000000000000',
        '00000000-0000-0000-0000-000000000000'
    ),
    (
        'b3333333-3333-3333-3333-333333333333',
        'Quality Finishing Services',
        '24AABCS9876K1Z5',
        '78 Export Zone, Industrial Estate',
        'Delhi',
        '110001',
        '00000000-0000-0000-0000-000000000000',
        '00000000-0000-0000-0000-000000000000'
    )
ON CONFLICT (id) DO NOTHING;

