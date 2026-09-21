DELETE FROM environments WHERE name = 'production';

INSERT into features (name) VALUES 
  ('register-api-read-only-mode'),
  ('epb-frontend-data-restrict-user-access'),
  ('block-address-matching-during-lodgement')
  ON CONFLICT (name) DO NOTHING;

INSERT into feature_environments (environment, feature_name, enabled, variants) VALUES 
  ('development', 'register-api-read-only-mode', false, '[]'),
  ('development', 'epb-frontend-data-restrict-user-access', false, '[]'),
  ('development', 'block-address-matching-during-lodgement', false, '[]')
  ON CONFLICT (environment, feature_name) DO NOTHING;
