(** Utilities derive type and value representations and write ppx rewriters that
    leverage them. *)

val register_type_declaration_deriver :
  name:string ->
  (loc:Location.t ->
  Python_libgen.Repr.type_declaration ->
  Parsetree.structure_item list) ->
  unit

val register_value_declaration_expander :
  name:string ->
  (loc:Location.t ->
  rec_flag:Asttypes.rec_flag ->
  name:string ->
  args:(string * Python_libgen.Repr.arg_kind * Parsetree.core_type) list ->
  ret:Parsetree.core_type ->
  signature:Python_libgen.Repr.value_signature ->
  expr:Parsetree.expression ->
  Parsetree.structure_item) ->
  unit
