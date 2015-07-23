-- View: auditlog_sql

-- DROP VIEW auditlog_sql;

CREATE OR REPLACE VIEW auditlog_sql AS 
 SELECT auditlog.audittable,
    auditlog.auditwhat,
    auditlog.auditkeyval,
    auditlog.auditwho,
    auditlog.auditwhen,
    ((((((((auditlog.auditwhat::text || ' INTO '::text) || auditlog.audittable::text) || ' ('::text) || string_agg(auditlog.auditfield::text, ', '::text ORDER BY auditlog.auditlog_id)) || ') '::text) || chr(10)) || 'VALUES ('::text) || string_agg((''''::text || auditlog.newval) || ''''::text, ', '::text ORDER BY auditlog.auditlog_id)) || ');'::text AS cmd,
    ((((('DELETE FROM '::text || auditlog.audittable::text) || ' WHERE '::text) || auditlog.audittable::text) || '_id = '::text) || auditlog.auditkeyval::text) || ';'::text AS rollback
   FROM auditlog
  WHERE auditlog.auditwhat = 'INSERT'::bpchar
  GROUP BY auditlog.audittable, auditlog.auditwhat, auditlog.auditkeyval, auditlog.auditwhen, auditlog.auditwho
UNION
 SELECT auditlog.audittable,
    auditlog.auditwhat,
    auditlog.auditkeyval,
    auditlog.auditwho,
    auditlog.auditwhen,
    ((((((('UPDATE '::text || auditlog.audittable::text) || ' SET '::text) || string_agg((auditlog.auditfield::text || ' = '::text) ||
        CASE
            WHEN auditlog.newval IS NOT NULL THEN (''''::text || auditlog.newval) || ''''::text
            ELSE 'NULL'::text
        END, ', '::text ORDER BY auditlog.auditlog_id)) || ' WHERE '::text) || auditlog.audittable::text) || '_id = '::text) || auditlog.auditkeyval::text) || ';'::text AS cmd,
    ((((((((auditlog.auditwhat::text || ' '::text) || auditlog.audittable::text) || ' SET '::text) || string_agg((auditlog.auditfield::text || ' = '::text) ||
        CASE
            WHEN auditlog.oldval IS NOT NULL THEN (''''::text || auditlog.oldval) || ''''::text
            ELSE 'NULL'::text
        END, ', '::text ORDER BY auditlog.auditlog_id)) || ' WHERE '::text) || auditlog.audittable::text) || '_id = '::text) || auditlog.auditkeyval::text) || ';'::text AS rollback
   FROM auditlog
  WHERE auditlog.auditwhat = 'UPDATE'::bpchar
  GROUP BY auditlog.audittable, auditlog.auditwhat, auditlog.auditkeyval, auditlog.auditwhen, auditlog.auditwho
UNION
 SELECT auditlog.audittable,
    auditlog.auditwhat,
    auditlog.auditkeyval,
    auditlog.auditwho,
    auditlog.auditwhen,
    ((((((auditlog.auditwhat::text || ' FROM '::text) || auditlog.audittable::text) || ' WHERE '::text) || auditlog.audittable::text) || '_id = '::text) || auditlog.auditkeyval::text) || ';'::text AS cmd,
    ((((((('INSERT INTO '::text || auditlog.audittable::text) || ' ('::text) || string_agg(auditlog.auditfield::text, ', '::text ORDER BY auditlog.auditlog_id)) || ') '::text) || chr(10)) || 'VALUES ('::text) || string_agg((''''::text || auditlog.oldval) || ''''::text, ', '::text ORDER BY auditlog.auditlog_id)) || ');'::text AS rollback
   FROM auditlog
  WHERE auditlog.auditwhat = 'DELETE'::bpchar
  GROUP BY auditlog.audittable, auditlog.auditwhat, auditlog.auditkeyval, auditlog.auditwhen, auditlog.auditwho;