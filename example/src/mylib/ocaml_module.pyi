# Autogenerated by python-libgen

from typing import Callable, Literal, TypeAlias, TypeVar, TypedDict, Union

A = TypeVar("A")

Expr: TypeAlias = Union[
    tuple[Literal["Constant"], tuple[int]],
    tuple[Literal["Var"], tuple[str]],
    tuple[Literal["Add"], tuple["Expr", "Expr"]],
]

Result: TypeAlias = Union[
    tuple[Literal["Answer"], tuple[A]], tuple[Literal["Error"], tuple[str]]
]

class CustommerData(TypedDict, total=True):
    age: int
    gender: str

def eval(valuation: list[tuple[str, int]], expr: Expr) -> int | None:
    """
    Evaluate an expression given a valuation that maps variables
    to values. Return None if a variable does not appear in the valuation.
    """
    ...

example_expr: Expr = ...

def rename_expr(renaming: Callable[[str], str], expr: Expr) -> Expr: ...
def fact(n: int) -> int: ...
def custommer_data(name: str) -> Result[CustommerData]: ...
def log(x: float, *, base: float | None = None) -> float: ...
