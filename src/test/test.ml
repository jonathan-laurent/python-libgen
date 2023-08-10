open Base
open Stdio
open Python_libgen

type enum_type = A | B [@@deriving python, python_export_type]

type simple_alias = int * (string * float)
[@@deriving python, python_export_type]

type sum_type = C of bool * string | D of enum_type | E of {x: int; y: bool}
[@@deriving python, python_export_type]

type type_with_lists = L of int option list
[@@deriving python, python_export_type]

type record_type = {x: int; y: float option}
[@@deriving python, python_export_type]

type record_type_alias = record_type = {x: int; y: float option}
[@@deriving python, python_export_type]

type ('a, 'b) polymorphic = {x: 'a; y: 'b}
[@@deriving python, python_export_type]

module M = struct
  type loc = int * int * int * int [@@deriving python, python_export_type]

  type 'a with_loc = {data: 'a; loc: loc}
  [@@deriving python, python_export_type]
end

type located_name = string M.with_loc [@@deriving python, python_export_type]

let%python_export f (x : int) : int = x + 1

let%python_export rec fact (n : int) : int =
  if n <= 0 then 1 else n * fact (n - 1)

let%python_docstring fact =
  {|
      Compute the factorial of an integer number.
      Return 1 on negative inputs.
  |}

let%python_export sum (l : int list) : int = List.fold_left ~f:( + ) ~init:0 l

let%python_export make_record (x : int) : record_type = {x; y= None}

let%test_unit "functions preserved" =
  assert (f 5 = 6) ;
  assert (fact 3 = 6) ;
  assert (sum [1; 2; 3] = 6)

let%expect_test "registered types" =
  let open Python_libgen.Repr in
  List.iter (registered_python_types ()) ~f:(fun v ->
      printf !"%{sexp: type_declaration}\n\n" v ) ;
  [%expect
    {|
    ((type_name EnumType) (type_vars ()) (definition (Enum (A B))))

    ((type_name SimpleAlias) (type_vars ())
     (definition
      (Alias (Tuple ((App Int ()) (Tuple ((App String ()) (App Float ()))))))))

    ((type_name SumType) (type_vars ())
     (definition
      (Variant
       ((C (Anonymous ((App Bool ()) (App String ()))))
        (D (Anonymous ((App (Custom EnumType) ()))))
        (E (Labeled ((x (App Int ())) (y (App Bool ())))))))))

    ((type_name TypeWithLists) (type_vars ())
     (definition (Variant ((L (Anonymous ((List (Option (App Int ()))))))))))

    ((type_name RecordType) (type_vars ())
     (definition (Record ((x (App Int ())) (y (Option (App Float ())))))))

    ((type_name RecordTypeAlias) (type_vars ())
     (definition (Record ((x (App Int ())) (y (Option (App Float ())))))))

    ((type_name Polymorphic) (type_vars (A B))
     (definition (Record ((x (Var A)) (y (Var B))))))

    ((type_name Loc) (type_vars ())
     (definition
      (Alias (Tuple ((App Int ()) (App Int ()) (App Int ()) (App Int ()))))))

    ((type_name WithLoc) (type_vars (A))
     (definition (Record ((data (Var A)) (loc (App (Custom Loc) ()))))))

    ((type_name LocatedName) (type_vars ())
     (definition (Alias (App (Custom WithLoc) ((App String ())))))) |}]

let test ~use_dataclasses =
  let values = registered_python_values () in
  let types = registered_python_types () in
  let settings = Stubs.{use_dataclasses} in
  print_endline
    (Stubs.generate_py_stub ~settings ~generated:"core" ~lib_name:"mylib"
       ~values ~types )

let%expect_test "python stub without dataclasses" =
  test ~use_dataclasses:false ;
  [%expect
    {|
    # Autogenerated by python_libgen

    from ctypes import RTLD_LOCAL, PyDLL, c_char_p

    from importlib.resources import files, as_file

    DLL_NAME = "core.so"

    dll_resource = files("mylib.bin").joinpath(DLL_NAME)
    with as_file(dll_resource) as dll_file:
        dll = PyDLL(str(dll_file), RTLD_LOCAL)

    argv_t = c_char_p * 3
    argv = argv_t(DLL_NAME.encode("utf-8"), b"register", None)
    dll.caml_startup(argv)

    import _core_internals  # type: ignore


    from typing import Literal, TypeAlias, TypedDict, Generic, TypeVar

    A = TypeVar("A")

    B = TypeVar("B")

    EnumType: TypeAlias = tuple[Literal["A"], None] | tuple[Literal["B"], None]

    SimpleAlias: TypeAlias = tuple[int, tuple[str, float]]

    SumType: TypeAlias = tuple[Literal["C"], tuple[bool, str]] | tuple[Literal["D"], tuple["EnumType"]] | tuple[Literal["E"], tuple[int, bool]]

    TypeWithLists: TypeAlias = tuple[Literal["L"], tuple[list[int | None]]]

    class RecordType(TypedDict, total=True):
        x: int
        y: float | None

    class RecordTypeAlias(TypedDict, total=True):
        x: int
        y: float | None

    class Polymorphic(TypedDict, Generic[A, B], total=True):
        x: A
        y: B

    Loc: TypeAlias = tuple[int, int, int, int]

    class WithLoc(TypedDict, Generic[A], total=True):
        data: A
        loc: "Loc"

    LocatedName: TypeAlias = "WithLoc[str]"

    def f(x: int) -> int:
        return _core_internals.f(x)

    def fact(n: int) -> int:
        """
        Compute the factorial of an integer number.
        Return 1 on negative inputs.
        """
        return _core_internals.fact(n)

    def sum(l: list[int]) -> int:
        return _core_internals.sum(l)

    def make_record(x: int) -> RecordType:
        return _core_internals.make_record(x) |}]

let%expect_test "python stub with dataclasses" =
  test ~use_dataclasses:true ;
  [%expect
    {|
    # Autogenerated by python_libgen

    from ctypes import RTLD_LOCAL, PyDLL, c_char_p

    from importlib.resources import files, as_file

    DLL_NAME = "core.so"

    dll_resource = files("mylib.bin").joinpath(DLL_NAME)
    with as_file(dll_resource) as dll_file:
        dll = PyDLL(str(dll_file), RTLD_LOCAL)

    argv_t = c_char_p * 3
    argv = argv_t(DLL_NAME.encode("utf-8"), b"register", None)
    dll.caml_startup(argv)

    import _core_internals  # type: ignore


    from dataclasses import dataclass

    from enum import Enum

    from typing import TypeAlias, Generic, TypeVar

    A = TypeVar("A")

    B = TypeVar("B")

    class EnumType(Enum):
        A = "A"
        B = "B"

    SimpleAlias: TypeAlias = tuple[int, tuple[str, float]]

    @dataclass
    class C:
        args: tuple[bool, str]

    @dataclass
    class D:
        arg: "EnumType"

    @dataclass
    class E:
        x: int
        y: bool

    SumType: TypeAlias = C | D | E

    @dataclass
    class L:
        arg: list[int | None]

    TypeWithLists: TypeAlias = L

    @dataclass
    class RecordType:
        x: int
        y: float | None

    @dataclass
    class RecordTypeAlias:
        x: int
        y: float | None

    @dataclass
    class Polymorphic(Generic[A, B]):
        x: A
        y: B

    Loc: TypeAlias = tuple[int, int, int, int]

    @dataclass
    class WithLoc(Generic[A]):
        data: A
        loc: "Loc"

    LocatedName: TypeAlias = "WithLoc[str]"

    def f(x: int) -> int:
        return _core_internals.f(x)

    def fact(n: int) -> int:
        """
        Compute the factorial of an integer number.
        Return 1 on negative inputs.
        """
        return _core_internals.fact(n)

    def sum(l: list[int]) -> int:
        return _core_internals.sum(l)

    def make_record(x: int) -> RecordType:
        return _core_internals.make_record(x) |}]
