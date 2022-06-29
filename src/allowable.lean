import A_map
import code
import mathlib.group
import mathlib.with_bot
import struct_perm

/-!
# Allowable permutations
-/

universe u

namespace con_nf
variable [params.{u}]

open params with_bot

variables (α : Λ) [phase_1a.{u} α]

/-- Contains all the information needed for phase 1b of the recursion. -/
class phase_1b :=
(allowable : Π β < α, Type*)
[allowable_group : Π β hβ, group (allowable β hβ)]
(to_structural : Π β hβ, allowable β hβ →* struct_perm α)
[allowable_action : Π β hβ, mul_action (allowable β hβ) (tangle α β $ coe_lt_coe.2 hβ)]

export phase_1b (allowable allowable_group to_structural allowable_action)

attribute [instance] allowable_group allowable_action

variables [phase_1b.{u} α] {β γ δ : Λ}

/-- A semi-allowable permutation is a `-1`-allowable permutation of atoms (a near-litter
permutation) together with allowable permutations on all `γ < β`. This forms a group structure
automatically. -/
@[derive group] def semiallowable_perm (hβ : β ≤ α) :=
near_litter_perm × Π γ (h : γ < β), allowable γ (h.trans_le hβ)

instance semiallowable_perm_scalar (hβ : β ≤ α) :
  has_scalar (semiallowable_perm α hβ) (code α β hβ) :=
⟨λ π X,
  ⟨X.extension, X.extension_lt,
    rec_bot_coe
    (λ none_lt elts, π.fst.atom_perm '' elts)
    (λ γ γ_lt elts, (•) (π.snd γ $ coe_lt_coe.mp γ_lt) '' elts)
    X.extension X.extension_lt X.elts⟩⟩

lemma semiallowable_perm_scalar_def (hβ : β ≤ α) (π : semiallowable_perm α hβ) (X : code α β hβ) :
  π • X =
    ⟨X.extension, X.extension_lt,
    rec_bot_coe
      (λ none_lt elts, π.fst.atom_perm '' elts)
    (λ γ γ_lt elts, (•) (π.snd γ $ coe_lt_coe.mp γ_lt) '' elts)
      X.extension X.extension_lt X.elts⟩ := rfl

instance semiallowable_perm_scalar_nonempty (hβ : β ≤ α) :
  has_scalar (semiallowable_perm α hβ) {c : code α β hβ // c.elts.nonempty} :=
⟨λ π X, ⟨π • X, begin
  obtain ⟨⟨γ, hγ, G⟩, hG⟩ := X,
  induction γ using with_bot.rec_bot_coe; exact hG.image _,
end⟩⟩

-- TODO(zeramorphic)
-- instance semiallowable_perm_action (hβ : β ≤ α) :
--   mul_action (semiallowable_perm α hβ) (code α β hβ) := sorry

/-- An allowable permutation is a semi-allowable permutation whose action on code preserves
equivalence. -/
def allowable_perm (hβ : β ≤ α) :=
{π : semiallowable_perm α hβ // ∀ X Y : code α β hβ, π • X ≡ π • Y ↔ X ≡ Y}

instance allowable_perm_scalar (hβ : β ≤ α) : has_scalar (allowable_perm α hβ) (code α β hβ) :=
⟨λ π X, π.val • X⟩

instance allowable_perm_scalar_nonempty (hβ : β ≤ α) :
  has_scalar (allowable_perm α hβ) {c : code α β hβ // c.elts.nonempty} := ⟨λ π X, π.val • X⟩

/-- The unpacked coherence condition for allowable permutations on proper type indices γ. -/
lemma allowable_perm_coherence {hβ : β ≤ α} (π : allowable_perm α hβ) (hγ : γ < β) (hδ : δ < β)
  (hγδ : γ ≠ δ) (g) :
  f_map γ δ (coe_lt_coe.mpr (hγ.trans_le hβ)) (hδ.trans_le hβ) (π.val.snd γ hγ • g) =
    π.val.fst • (f_map γ δ (coe_lt_coe.mpr (hγ.trans_le hβ)) (hδ.trans_le hβ) g) :=
begin
  classical,
  unfold has_scalar.smul,
  have equiv := singleton_equiv hβ hγ hδ hγδ g,
  rw ← π.property at equiv,
  unfold has_scalar.smul at equiv, simp at equiv,
  rw singleton_equiv_iff at equiv, cases equiv,
  { exfalso,
    have := congr_arg code.extension equiv, dsimp at this, rw coe_eq_coe at this,
    rw this at hγδ, exact hγδ rfl },
  obtain ⟨ε, hc, hε, hγε, hA⟩ := equiv,
  have hc' := coe_eq_coe.mp hc, subst hc', clear hc,
  dsimp at hA, have hA' := hA.symm, rw A_map_code_coe_eq_iff at hA',
  simp at hA', unfold A_map at hA', simp at hA', dsimp at hA',
  have : to_tangle δ (hε.trans_le hβ) ⟨f_map γ δ _ (hδ.trans_le hβ) (π.val.snd γ hγ • g), litter_set _, is_near_litter_litter_set _⟩
    ∈ to_tangle δ (hε.trans_le hβ) '' local_cardinal (f_map γ δ _ (hδ.trans_le hβ) (π.val.snd γ hγ • g))
    := set.mem_image_of_mem (to_tangle δ (hε.trans_le hβ)) (by simp),
  rw subtype.val_eq_coe at this,
  rw hA' at this,
  rw set.mem_smul_set at this,
  obtain ⟨t, ⟨N, hN₁, hN₂⟩, ht⟩ := this, dsimp at hN₁, rw ← hN₁, rw ← hN₂ at ht,
  sorry
end

lemma allowable_perm_commute {hβ : β ≤ α} (π : allowable_perm α hβ) (hδ : δ < β)
  (X : {c : code α β hβ // c.elts.nonempty}) (hX : X.val.extension ≠ δ) :
π • (A_map_code hβ hδ X hX) = A_map_code hβ hδ (π • X) hX := sorry

/-- Representative codes are mapped to representative codes under allowable permutations. -/
lemma code.is_representative.smul {hβ : β ≤ α} (π : allowable_perm α hβ) (hδ : δ < β)
  (X : code α β hβ) (hX : X.is_representative) :
  (π • X).is_representative := sorry

end con_nf
