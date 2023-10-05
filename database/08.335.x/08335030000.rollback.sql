RENAME TABLE feature TO poc;


INSERT INTO db_version (revision, direction) VALUES (0, 'rollback');
