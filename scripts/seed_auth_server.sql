INSERT INTO clients (id, name, supplemental) VALUES 
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'all-scopes', '{"scheme_ids": [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]}'),
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'epb_frontend', '{}'),
  ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', 'epb_data_warehouse', '{}'),
  ('bcef78ba-8e31-4639-8dc7-0754d1f67db8', 'epb_register_api', '{}')
  ON CONFLICT (id) DO NOTHING;

INSERT INTO client_secrets (client_id, secret) VALUES 
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', crypt('all-scopes-secret', gen_salt('bf'))),
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', crypt('frontend-secret', gen_salt('bf'))),
  ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', crypt('data-warehouse-secret', gen_salt('bf'))),
  ('bcef78ba-8e31-4639-8dc7-0754d1f67db8', crypt('register-api-secret', gen_salt('bf')));

-- Security scan and local testing - all scopes
INSERT INTO client_scopes (client_id, scope) VALUES 
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'address:search'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'addressing:read'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'admin:opt-out'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'admin:update-address-id'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'assessment:domestic-epc:search'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'assessment:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'assessment:lodge'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'assessment:search'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'assessmentmetadata:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'assessor:search'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'bus:assessment:search'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'dec_summary:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'ecoplus:assessment:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'epb-data-front:read'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'greendeal:charge-update'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'greendeal:plans'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'heat-pump-check:assessment:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'migrate:assessment'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'migrate:scotland'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'prsdatabase:assessment:search'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'report:assessor:status'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'reporting:assessment_by_scheme_and_type'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'reporting:assessment_by_type_and_region'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'retrofit-advice:assessment:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'retrofit-funding:assessment:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scheme:assessor:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scheme:assessor:list'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scheme:assessor:update'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scheme:create'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scheme:list'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scheme:update'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scotland_admin:opt_out'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scotland_admin:update_address_id'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scotland_assessment:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scotland_assessment:lodge'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scotland_assessment:search'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scotland_assessor:search'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scotland_data:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scotland_dec_summary:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'statistics:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'warehouse:read'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'warm-home-discount:assessment:fetch');

-- Frontend
INSERT INTO client_scopes (client_id, scope) VALUES 
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessor:search'),
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessment:fetch'),
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessment:search'),
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'dec_summary:fetch'),
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'statistics:fetch'),
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'warehouse:read');

-- Data-warehouse + Data-frontend
INSERT INTO client_scopes (client_id, scope) VALUES 
  ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', 'assessment:fetch'),
  ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', 'assessmentmetadata:fetch'),
  ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', 'epb-data-front:read');

-- Register API
INSERT INTO client_scopes (client_id, scope) VALUES 
  ('bcef78ba-8e31-4639-8dc7-0754d1f67db8', 'addressing:read');
