CREATE TABLE auditlog
(
  auditlog_id bigserial NOT NULL,
  auditwhen timestamp without time zone NOT NULL DEFAULT ('now'::text)::timestamp(6) with time zone,
  auditwhat character(10) NOT NULL,
  auditwho varchar NOT NULL DEFAULT CURRENT_USER,
  audittable character varying NOT NULL,
  auditkeyval character varying(255) NOT NULL,
  auditfield character varying NOT NULL,
  oldval text,
  newval text,
  CONSTRAINT auditlog_pkey PRIMARY KEY (auditlog_id)
)