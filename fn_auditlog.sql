CREATE OR REPLACE FUNCTION fn_auditlog()
  RETURNS trigger AS
$BODY$
if {[string match $TG_op INSERT]} {
	foreach field $TG_relatts {
		if {[info exists NEW($field)]} {
			spi_exec "INSERT INTO auditlog (auditwhat, audittable, auditkeyval, auditfield, newval) values ('INSERT', '$1', '$NEW($2)', '$field', '[ quote $NEW($field)]')"
		}
	}
} elseif {[string match $TG_op DELETE]} {
	foreach field $TG_relatts {
		if {[info exists OLD($field)]} {
			spi_exec "INSERT INTO auditlog (auditwhat, audittable, auditkeyval, auditfield, oldval) VALUES ('DELETE', '$1', '$OLD($2)', '$field', '[ quote $OLD($field)]')"
		}
	}
} elseif {[string match $TG_op UPDATE]} {
	foreach field $TG_relatts {

		if {([info exists NEW($field)] &&
			[info exists OLD($field)] &&
		![string match $OLD($field) $NEW($field)])} {
			spi_exec "INSERT INTO auditlog (auditwhat, audittable, auditkeyval, auditfield, oldval, newval) VALUES ('UPDATE', '$1', '$NEW($2)', '$field', '[ quote $OLD($field)]', '[ quote $NEW($field)]')"
			
		} elseif {[info exists NEW($field)] && ![info exists OLD($field)]} {
			spi_exec "INSERT INTO auditlog (auditwhat, audittable, auditkeyval, auditfield, newval) VALUES ('UPDATE', '$1', '$NEW($2)', '$field', '[ quote $NEW($field)]')"
			
		} elseif {![info exists NEW($field)] && [info exists OLD($field)]} {
			spi_exec "INSERT INTO auditlog (auditwhat, audittable, auditkeyval, auditfield, oldval) VALUES ('UPDATE', '$1', '$NEW($2)', '$field', '[ quote $OLD($field)]')"
		}
	}
}

return "OK"
$BODY$
  LANGUAGE pltcl VOLATILE
  COST 100;
