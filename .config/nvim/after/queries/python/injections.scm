; extends

; Odoo: highlight SQL inside SQL("""...""") from odoo.tools
((call
  function: (identifier) @_fn (#eq? @_fn "SQL")
  arguments: (argument_list
    . (string (string_content) @injection.content)))
 (#set! injection.language "sql"))
