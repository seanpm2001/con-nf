import code
import struct_perm
import A_map

/-!
# Allowable permutations
-/

universe u

namespace con_nf
variable [params.{u}]

open params with_bot

variables (α : Λ) [phase_1a.{u} α]

/-- Contains all the information needed for phase 1b of the recursion.
We use an explicit `→*` here instead of a `monoid_hom_class` so that we don't need to worry
about typeclass instances not firing under a `β < α` condition. -/
class phase_1b :=
(allowable : Π β < α, Type*) [allowable_group : Π β (h : β < α), group (allowable β h)]
(to_structural : Π β (h : β < α), allowable β h →* struct_perm α)
[allowable_action : Π β (h : β < α), mul_action (allowable β h) (tangle α β (coe_lt_coe.mpr h))]

export phase_1b (allowable allowable_group to_structural allowable_action)

variables [phase_1b.{u} α]

instance allowable_group_pi : group (Π β (h : β < α), allowable β h) := sorry

/-- A semiallowable permutation is a `-1`-allowable permutation of atoms (a near-litter permutation)
together with allowable permutations on all `γ < β`. This forms a group structure automatically. -/
def semiallowable_perm {β : Λ} (hβ : β ≤ α) :=
near_litter_perm × Π γ (h : γ < β), allowable γ (h.trans_le hβ)

instance semiallowable_perm_group {β : Λ} (hβ : β ≤ α) : group (semiallowable_perm α hβ) := sorry
-- Use prod.group and allowable_group

instance semiallowable_perm_scalar {β : Λ} (hβ : β ≤ α) :
has_scalar (semiallowable_perm α hβ) (code α β hβ) := sorry
/- ⟨λ π ⟨γ, hγ, G⟩, begin
  refine ⟨γ, hγ, _⟩,
  cases γ,
  { exact π.fst.atom_perm '' G },
  { rw with_bot.some_eq_coe at hγ, simp at hγ,
    haveI := allowable_action γ (hγ.trans h),
    simp_rw with_bot.some_eq_coe,
    exact (λ g, (π.snd γ (hγ.trans h)) • g) '' G }
end⟩ -/

-- TODO(zeramorphic)
instance semiallowable_perm_action {β : Λ} (hβ : β ≤ α) :
mul_action (semiallowable_perm α hβ) (code α β hβ) := sorry

def allowable_perm {β : Λ} (hβ : β ≤ α) :=
{π : semiallowable_perm α hβ // ∀ (X Y : code α β hβ), X ≡ Y ↔ π • X ≡ π • Y}

end con_nf
