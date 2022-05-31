import group_theory.group_action.basic
import group_theory.group_action.pi
import litter

/-!
# Draft for a tangled web

This is a slight adaptation of Mario Carneiro's draft for a tangled web of cardinals. It is part of
the porting process but should not be directly useful to the project.
-/

noncomputable theory
open cardinal equiv equiv.perm function set
open_locale cardinal classical pointwise

universes u v

namespace con_nf

open params

section normal_filter
variables (A : Type*) {X : Type*} [group X] [mul_action X A] (G : subgroup X)

-- TODO: Make this extend `pfilter (subgroup X)` once it has been refactored
structure normal_filter :=
(Γ : set (subgroup X))
(is_perm : ∀ (K ∈ Γ), K ≤ G)
(atoms : ∀ a : A, mul_action.stabilizer X a ∈ Γ)
(upward : ∀ H K, H ∈ Γ → H ≤ K → K ∈ Γ)
(inter : ∀ H K, H ∈ Γ → K ∈ Γ → H ⊓ K ∈ Γ)
(conj : ∀ (π ∈ G) (h ∈ Γ), (h:subgroup _).map (mul_aut.conj π).to_monoid_hom ∈ Γ)

variables {A G} (F : normal_filter A G)

def normal_filter.symm {α} [mul_action X α] (x : α) : Prop :=
mul_action.stabilizer X x ∈ F.Γ

def normal_filter.set (α) [mul_action X α] : Type* := {s : set α // F.symm s}

instance (α) [mul_action X α] : mul_action X (F.set α) :=
{ smul := λ x S, ⟨x • S.1, sorry⟩,
  one_smul := sorry,
  mul_smul := sorry }

end normal_filter

variables [params.{u}] {α β : Type u}

def atoms : Type* := xti × base_type

def local_cards (A : xti) : Type u := μ

instance : mul_action near_litter_perm near_litter :=
{ smul := λ π N, ⟨π.litter_perm N.1, π • N.2.1, sorry⟩, one_smul := λ _, by { ext, refl, sorry },
  mul_smul := λ _ _ _, by { ext, refl, sorry } }

def clans_perm := xti → near_litter_perm

instance : group clans_perm := pi.group

-- TODO: This gives a diamond for different `A`.
instance (A : xti) (α) [mul_action near_litter_perm α] : mul_action clans_perm α :=
{ smul := λ π a, π A • a,
  one_smul := λ a, one_smul _ a,
  mul_smul := λ π ρ c, mul_smul (π A) (ρ A) c }

instance (α β) [mul_action clans_perm α] [mul_action clans_perm β] :
  mul_action clans_perm (α ≃ β) :=
{ smul := λ π e, ⟨λ a, π • e (π⁻¹ • a), λ b, π⁻¹ • e.symm (π • b), sorry, sorry⟩,
  one_smul := sorry,
  mul_smul := sorry }

instance : mul_action clans_perm atoms :=
{ smul := λ π a, ⟨a.1, π a.1 • a.2⟩,
  one_smul := sorry,
  mul_smul := sorry }

def local_card {A} (N : near_litter) : local_cards A := N.1

def parent_set (A : xti) :=
(Σ' A' (h : A.drop = some A'), base_type) ⊕ Σ' a (h : insert a A < A), set (set base_type)

instance (A) : mul_action clans_perm (parent_set A) :=
{ smul := λ π x, match x with
  | sum.inl ⟨A', h, c⟩ := sum.inl ⟨A', h, π • c⟩
  | sum.inr ⟨a, h, s⟩ := sum.inr ⟨a, h, π • s⟩
  end,
  one_smul := sorry,
  mul_smul := sorry }

def support_el (Q : xti → Prop) := Σ A, Σ' _ : Q A, base_type ⊕ near_litter

def support_el.inl (Q : xti → Prop) {A} (h : Q A) (c : base_type) : support_el Q :=
⟨A, h, sum.inl c⟩

def support_el.inr (Q : xti → Prop) {A} (h : Q A) (N : near_litter) : support_el Q :=
⟨A, h, sum.inr N⟩

def support_el.below {Q A} (x : local_cards A) : support_el Q → Prop
| ⟨A, h, sum.inl c⟩ := μr c.1 x
| ⟨A, h, sum.inr N⟩ := N.is_litter ∧ μr N.1 x

instance {Q : xti → Prop} : mul_action clans_perm (support_el Q) :=
{ smul := λ π x, match x with
  | ⟨A, h, sum.inl c⟩ := support_el.inl _ h (π • c)
  | ⟨A, h, sum.inr N⟩ := support_el.inr _ h (π • N)
  end,
  one_smul := sorry,
  mul_smul := sorry }

structure support_order (Q : xti → Prop) :=
(S : set (support_el Q))
(small : small S)
(disj (A h M N) :
  @support_el.inr _ Q A h M ∈ S → support_el.inr _ h N ∈ S → M ≠ N → disjoint M.2.1 N.2.1)
(r : S → S → Prop)
(wo : is_well_order S r)

variables {P : xti → Prop} (PI : ∀ B, P B → local_cards B → parent_set B)

def allowable' : subgroup clans_perm :=
{ carrier := { π | ∀ B h x, PI B h (π • x) = π • PI B h x },
  one_mem' := sorry,
  mul_mem' := sorry,
  inv_mem' := sorry }

def supported' {Q} (S : support_order Q) : subgroup clans_perm :=
allowable' PI ⊓ ⨅ a ∈ S.S, mul_action.stabilizer _ a

def has_support' {Q} (S : support_order Q) {α} [mul_action clans_perm α] (x : α) : Prop :=
supported' PI S ≤ mul_action.stabilizer clans_perm x

def support_filter' (Q) : normal_filter atoms (allowable' PI) :=
{ Γ := {K | ∃ S : support_order Q, supported' PI S ≤ K},
  is_perm := sorry,
  atoms := sorry,
  upward := sorry,
  inter := sorry,
  conj := sorry }

def parent_set.symm' (Q) {A} : parent_set A → Prop
| (sum.inl ⟨A', _, c⟩) := (support_filter' PI Q).symm c
| (sum.inr ⟨a, _, x⟩) := (support_filter' PI Q).symm x ∧ ∀ s ∈ x, (support_filter' PI Q).symm s

def parent_range' (Q A) := {x : parent_set A | x.symm' PI Q}

theorem parent_range'_card (Q A) : #(parent_range' PI Q A) = #μ := sorry

structure good_bij' (Q : xti → Prop) {A} (f : local_cards A → parent_set A) : Prop :=
(inj : function.injective f)
(range : set.range f = parent_range' PI Q A)
(below (x : local_cards A) :
  ∃ S : support_order Q, has_support' PI S (f x) ∧
    ∀ c : support_el Q, c ∈ S.S → c.below x)

theorem exists_bij' (Q A) : ∃ f : local_cards A → parent_set A, good_bij' PI Q f := sorry

def the_bij (Q A) := classical.some (exists_bij' PI Q A)

noncomputable def parent_map : ∀ (A : xti), local_cards A → parent_set A
| A := @the_bij _ (λ B, B < A) (λ B hB, parent_map B) (λ B, B ≤ A) A
using_well_founded {dec_tac := `[assumption]}

def allowable : subgroup clans_perm := allowable' (λ B (_ : true), parent_map B)

def support_filter : normal_filter atoms allowable :=
support_filter' (λ B (_ : true), parent_map B) (λ _, true)

def parent_set.symm {A} (s : parent_set A) := s.symm' (λ B (_ : true), parent_map B) (λ _, true)
def parent_range := parent_range' (λ B (_ : true), parent_map B) (λ _, true)
theorem parent_range_card (A) : #(parent_range A) = #μ := parent_range'_card _ _ _

def symm {α} [mul_action clans_perm α] (x : α) := support_filter.symm x

def sset (α) [mul_action clans_perm α] := support_filter.set α
instance (α) [mul_action clans_perm α] : mul_action clans_perm (sset α) :=
by unfold sset; apply_instance

def sset_n : ℕ → ∀ (α) [mul_action clans_perm α], Type*
| 0 α h := α
| (n+1) α h := sset_n n (by exactI sset α)

noncomputable instance mul_action.sset_n :
  ∀ n α [mul_action clans_perm α], by exactI mul_action clans_perm (sset_n n α)
| 0 α h := h
| (n+1) α h := mul_action.sset_n n _

def xti_below := {A : xti // A < {δ}}
def τ (A : xti_below) := sset_n 2 (clan (insert δ A.1))
instance (A) : mul_action clans_perm (τ A) := by unfold τ; apply_instance

theorem τ_power (A A' : xti_below) (h : A.1.drop = some A'.1) :
  ∃ f : τ A ≃ sset (τ A'), symm f := sorry

def τ_elementary (A A' B B' : xti_below) (n)
  (hA : A.1.dropn n = some A'.1) (hB : B.1.dropn n = some B'.1)
  (H : A.1.1 \ A'.1.1 = B.1.1 \ B'.1.1) :
  sset_n (n+2) (τ A') ≃ sset_n (n+2) (τ B') := sorry

end con_nf
