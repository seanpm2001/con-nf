import combinatorics.quiver.path
import mathlib.well_founded
import mathlib.quiver
import params

open cardinal
open_locale cardinal

universe u

namespace con_nf
variables [params.{u}]

open params

/-- We define the type of paths from certain types to lower types
as elements of this quiver. -/
instance has_paths : quiver type_index := ⟨(>)⟩

/-- A (finite) path from the type α to the base type.
This can be seen as a way that we can perceive extensionality, iteratively descending to lower
types in the hierarchy until we reach the base type.
This plays the role of an extended type index in the paper. -/
def extended_index (α : Λ) := quiver.path (α : type_index) ⊥

/-- If there is a path between `α` and `β`, we must have `β ≤ α`.
The case `β = α` can occur with the nil path. -/
lemma le_of_path {α : Λ} : Π {β : type_index}, quiver.path (α : type_index) β → β ≤ (α : type_index)
| β (quiver.path.cons A B) := le_trans (le_of_lt B) (le_of_path A)
| β (quiver.path.nil) := le_rfl

/-- There are at most `Λ` `α`-extended type indices. -/
@[simp] lemma mk_extended_index (α : Λ) : #(extended_index α) ≤ #Λ :=
begin
  refine le_trans ((cardinal.le_def _ _).mpr ⟨quiver.path.to_list_embedding (α : type_index) ⊥⟩) _,
  convert mk_list_le_max _ using 1, simp, rw max_eq_right Λ_limit.aleph_0_le
end

/-- If `β < γ`, we have a path directly between the two types in the opposite order.
Note that the `⟶` symbol (long right arrow) is not the normal `→` (right arrow),
even though monospace fonts often display them similarly. -/
instance coe_lt_to_hom (β γ : Λ) : has_lift_t (β < γ) ((γ : type_index) ⟶ β) :=
⟨λ h, by { unfold quiver.hom, simp, exact h }⟩

/-- The direct path from the base type to `α`. -/
def extended_index.direct (α : Λ) : extended_index α :=
quiver.hom.to_path $ with_bot.bot_lt_coe α

instance extended_index_inhabited (α : Λ) : inhabited (extended_index α) :=
⟨extended_index.direct α⟩

end con_nf