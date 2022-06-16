import params

universe u

namespace con_nf
variables [params.{u}]

open params

structure recursion_stage (α : Λ) :=
(tangle : Type u)

def recursion_motor (α : Λ) := Π (β < α), recursion_stage β

def inductive_step (α : Λ) (motor : recursion_motor α) : recursion_stage α := sorry

noncomputable! def main_recursion : Π (α : Λ), recursion_motor α
| α := λ β hβ, inductive_step β (main_recursion β)
using_well_founded { dec_tac := `[exact hβ] }

end con_nf
