import code
import f_map
import litter
import data.nat.parity

open with_bot
open_locale cardinal

universe u

namespace con_nf
open params
variables [params.{u}] {α : Λ} [phase_1a.{u} α]

/-- The *local cardinal* of a litter is the set of all near-litters to that litter. -/
@[reducible] def local_cardinal (i : litter) : set near_litter :=
{s : near_litter | s.1 = i}

lemma local_cardinal_nonempty (i : litter) : (local_cardinal i).nonempty :=
⟨⟨i, litter_set _, is_near_litter_litter_set _⟩, by simp⟩

lemma local_cardinal_disjoint : pairwise (disjoint on local_cardinal) :=
begin
  rintros i j h ⟨k, s, hs₁⟩ ⟨hs₂, hs₃⟩,
  exfalso, dsimp at hs₂ hs₃, rw [← hs₂, ← hs₃] at h, exact h rfl
end

@[simp] lemma mk_local_cardinal (i : litter) : #(local_cardinal i) = #μ :=
begin
  suffices : # {x : near_litter // x.fst = i} = #{s // is_near_litter i s},
  { simp, rw this, simp },
  rw cardinal.eq,
  refine ⟨⟨_, _, _, _⟩⟩,
  { rintro ⟨x, hx⟩, subst hx, exact x.snd },
  { intro x, exact ⟨⟨i, x⟩, rfl⟩ },
  { rintro ⟨⟨j, S⟩, hx⟩, simp, subst hx, split; refl },
  { rintro ⟨j, S⟩, simp }
end

/-- The *alternative extension* map. For a non-empty set of tangles `G`, consider the code
`(α, γ, G)`. We then construct the non-empty set `D` such that `(α, δ, D)` is an alternative
extension of the same object in TTT. -/
def A_map {γ : type_index} {δ : Λ} (hγ : γ < α) (hδ : δ < α) (hγδ : γ ≠ δ)
(c : {s : set (tangle α γ hγ) // s.nonempty}) :
{t : set (tangle α δ (coe_lt_coe.2 hδ)) // t.nonempty} :=
⟨⋃ b ∈ c.val, to_tangle δ hδ '' local_cardinal (f_map γ δ hγ hδ b), begin
  simp,
  cases c.property with t ht,
  exact ⟨t, ht, ⟨f_map γ δ hγ hδ t, litter_set _, is_near_litter_litter_set _⟩, ⟨_⟩⟩,
end⟩

lemma subset_A_map {γ : type_index} {δ : Λ} (hγ : γ < α) (hδ : δ < α) (hγδ : γ ≠ δ)
(c : {s : set (tangle α γ hγ) // s.nonempty}) :
to_tangle δ hδ '' local_cardinal (f_map γ δ hγ hδ c.property.some) ⊆ (A_map hγ hδ hγδ c).val :=
begin
  unfold A_map,
  convert set.subset_Union₂ c.property.some _,
  refl, exact c.property.some_spec
end

@[simp] lemma mk_A_map {γ : type_index} {δ : Λ} (hγ : γ < α) (hδ : δ < α) (hγδ : γ ≠ δ)
(c : {s : set (tangle α γ hγ) // s.nonempty}) :
#μ ≤ #(A_map hγ hδ hγδ c : set (tangle α δ (coe_lt_coe.mpr hδ))) :=
begin
  suffices : #μ = #(to_tangle δ hδ '' local_cardinal (f_map γ δ hγ hδ c.property.some)),
  from le_of_eq_of_le this (cardinal.mk_le_mk_of_subset $ subset_A_map _ _ hγδ _),
  rw cardinal.mk_image_eq _,
  rw mk_local_cardinal,
  exact (to_tangle δ hδ).inj'
end

lemma exists_inter_of_Union_eq_Union {α β : Type*} {S T : set α} {f : α → set β}
(h : (⋃ b ∈ S, f b) = ⋃ c ∈ T, f c) : ∀ b ∈ S, (f b).nonempty → ∃ c ∈ T, (f b ∩ f c).nonempty :=
begin
  rintros b hb ⟨x, hx⟩,
  have : f b ⊆ ⋃ b ∈ S, f b := set.subset_Union₂ b hb, rw h at this,
  have := set.mem_of_mem_of_subset hx this, simp at this,
  obtain ⟨c, hc₁, hc₂⟩ := this, exact ⟨c, hc₁, x, hx, hc₂⟩
end

lemma A_map_injective_inner {γ : type_index} {δ : Λ} (hγ : γ < α) (hδ : δ < α) (hγδ : γ ≠ δ)
(s t : {s : set (tangle α γ hγ) // s.nonempty}) (h : A_map hγ hδ hγδ s = A_map hγ hδ hγδ t) :
∀ x ∈ s.val, x ∈ t.val :=
begin
  cases s with G₁ hG₁, cases t with G₂ hG₂,
  intros g hg,
  unfold A_map at h,
  have := subtype.ext_iff_val.mp h, dsimp at this,
  obtain ⟨x, hx, y, hy₁, hy₂⟩ := exists_inter_of_Union_eq_Union this g hg
    ⟨to_tangle δ hδ $ ⟨f_map γ δ hγ hδ g, litter_set _, is_near_litter_litter_set _⟩,
      by simp ⟩,
  rw set.mem_image at hy₁ hy₂,
  obtain ⟨s, hs₁, hs₂⟩ := hy₁, obtain ⟨t, ht₁, ht₂⟩ := hy₂,
  rw ← ht₂ at hs₂, have s_eq_t := (to_tangle δ hδ).inj' hs₂, rw s_eq_t at hs₁,
  suffices : g = x, by { rw ← this at hx, exact hx },
  by_contradiction,
  have := local_cardinal_disjoint (f_map γ δ hγ hδ g) (f_map γ δ hγ hδ x)
    ((f_map_injective γ δ hγ hδ).ne h),
  exact this ⟨hs₁, ht₁⟩
end

lemma A_map_injective {γ : type_index} {δ : Λ} (hγ : γ < α) (hδ : δ < α) (hγδ : γ ≠ δ) :
function.injective (A_map hγ hδ hγδ) :=
begin
  rintros s t h,
  ext, dsimp, split,
  exact A_map_injective_inner hγ hδ hγδ s t h x,
  exact A_map_injective_inner hγ hδ hγδ t s h.symm x
end

/-!
We don't need to prove that the ranges of the `A_δ` are disjoint for different `δ`, since this holds
at the type level.

We now show that there are only finitely many iterated images under any inverse A-map.
-/

lemma well_founded_of_tangle {β : type_index} (h : β < α) :
  well_founded (λ a b, of_tangle α h a < of_tangle α h b) :=
inv_image.wf _ is_well_order.wf

noncomputable def min_tangle {γ : type_index} (hγ : γ < α)
  (c : {s : set (tangle α γ hγ) // s.nonempty}) : tangle α γ hγ :=
(well_founded_of_tangle hγ).min c.val c.property

lemma min_tangle_mem {γ : type_index} (hγ : γ < α) (c : {s : set (tangle α γ hγ) // s.nonempty}) :
  min_tangle hγ c ∈ c.val :=
well_founded.min_mem _ c.val c.property

lemma min_tangle_le {γ : type_index} (hγ : γ < α) (c : {s : set (tangle α γ hγ) // s.nonempty}) :
  ∀ x ∈ c.val, ¬ of_tangle α hγ x < (of_tangle α hγ $ min_tangle hγ c) :=
λ x hx, (well_founded_of_tangle hγ).not_lt_min c.val c.property hx

lemma A_map_order {γ : type_index} {δ : Λ} (hγ : γ < α) (hδ : δ < α) (hγδ : γ ≠ δ)
  (c : {s : set (tangle α γ hγ) // s.nonempty}) :
  of_tangle α hγ (min_tangle hγ c) <
    of_tangle α (coe_lt_coe.mpr hδ) (min_tangle (coe_lt_coe.mpr hδ) (A_map hγ hδ hγδ c)) :=
begin
  obtain ⟨s, ⟨t, ht⟩, hs⟩ := min_tangle_mem (coe_lt_coe.mpr hδ) (A_map hγ hδ hγδ c),
  rw ← ht at hs,
  clear ht,
  rw set.mem_Union at hs,
  obtain ⟨ht, hs⟩ := hs,
  rw set.mem_image at hs,
  obtain ⟨N, hN₁, hN₂⟩ := hs,
  rw ← hN₂, clear hN₂,
  have : is_near_litter (f_map γ δ hγ hδ t) N.snd.val,
  { convert N.snd.property, exact hN₁.symm },
  convert lt_of_le_of_lt _ (f_map_position_raising γ δ hγ hδ t N.snd.val this),
  { cases N, cases N_snd, unfold local_cardinal at hN₁,
    have := set.mem_set_of.mp hN₁, dsimp at this, subst this_1 },
  { have := min_tangle_le hγ c t ht, push_neg at this, exact this }
end

/-- Tool that lets us use well-founded recursion on codes via `μ`. -/
noncomputable def code_min_map {β : Λ} (hβ : β ≤ α)
(c : {c : code α β hβ // c.elts.nonempty}) : μ :=
of_tangle α (c.val.extension_lt.trans_le $ coe_le_coe.mpr hβ) $
  min_tangle (c.val.extension_lt.trans_le $ coe_le_coe.mpr hβ) ⟨c.val.elts, c.property⟩

/-- The pullback `<` relation on codes is well-founded. -/
lemma code_wf {β : Λ} (hβ : β ≤ α) : well_founded (inv_image μr (code_min_map hβ)) :=
inv_image.wf (code_min_map hβ) μwf.wf

/-- The A-map, phrased as a function on non-empty `α`-codes. -/
def A_map_code {β : Λ} (hβ : β ≤ α) {δ : Λ} (hδ : δ < β) (c : {c : code α β hβ // c.elts.nonempty})
(hne : c.val.extension ≠ δ) : {c : code α β hβ // c.elts.nonempty} :=
⟨⟨δ, coe_lt_coe.mpr hδ,
  A_map (c.val.extension_lt.trans_le $ coe_le_coe.mpr hβ) (hδ.trans_le hβ)
  hne ⟨c.val.elts, c.property⟩⟩, begin
  obtain ⟨x, hx⟩ := c.property,
  dsimp,
  unfold A_map,
  simp,
  exact ⟨x, hx, local_cardinal_nonempty _⟩
end⟩

@[simp] lemma A_map_code_extension {β : Λ} (hβ : β ≤ α) {δ : Λ} (hδ : δ < β)
(c : {c : code α β hβ // c.elts.nonempty}) (hne : c.val.extension ≠ δ) :
(↑(A_map_code hβ hδ c hne) : code α β hβ).extension = δ := rfl

@[simp] lemma A_map_code_elts {β : Λ} (hβ : β ≤ α) {δ : Λ} (hδ : δ < β)
(c : {c : code α β hβ // c.elts.nonempty}) (hne : c.val.extension ≠ δ) :
(↑(A_map_code hβ hδ c hne) : code α β hβ).elts =
  (A_map (c.val.extension_lt.trans_le $ coe_le_coe.mpr hβ) (hδ.trans_le hβ)
    hne ⟨c.val.elts, c.property⟩).val := rfl

lemma A_map_code_eq_iff {β : Λ} (hβ : β ≤ α) {δ : Λ} (hδ : δ < β)
(c : {c : code α β hβ // c.elts.nonempty}) (hne : c.val.extension ≠ δ)
(D : set (tangle α δ (coe_lt_coe.mpr (hδ.trans_le hβ)))) (hD : D.nonempty) :
A_map_code hβ hδ c hne = ⟨⟨δ, coe_lt_coe.mpr hδ, D⟩, hD⟩
  ↔ (↑(A_map_code hβ hδ c hne) : code α β hβ).elts = D :=
by { split; { intro h, cases h, refl } }

lemma A_map_code_coe_eq_iff {β : Λ} (hβ : β ≤ α) {δ : Λ} (hδ : δ < β)
(c : {c : code α β hβ // c.elts.nonempty}) (hne : c.val.extension ≠ δ)
(D : set (tangle α δ (coe_lt_coe.mpr (hδ.trans_le hβ)))) :
(A_map_code hβ hδ c hne : code α β hβ) = ⟨δ, coe_lt_coe.mpr hδ, D⟩
  ↔ (↑(A_map_code hβ hδ c hne) : code α β hβ).elts = D :=
by { split; { intro h, cases h, refl } }

lemma A_map_code_order {β : Λ} (hβ : β ≤ α) {δ : Λ} (hδ : δ < β)
(c : {c : code α β hβ // c.elts.nonempty}) (hne : c.val.extension ≠ δ) :
(code_min_map _) c < (code_min_map _) (A_map_code hβ hδ c hne) :=
A_map_order (c.val.extension_lt.trans_le $ coe_le_coe.mpr hβ) (hδ.trans_le hβ) hne ⟨c.val.elts, c.property⟩

/-- This relation on `α`-codes allows us to state that there are only finitely many iterated images
under the inverse A-map. -/
def A_map_relation {β : Λ} (hβ : β ≤ α) (c d : {c : code α β hβ // c.elts.nonempty}) : Prop :=
begin
  obtain ⟨⟨δ, hδ, D⟩, hD⟩ := d,
  cases δ,
  { exact false },
  { by_cases c.val.extension = δ,
    { exact false },
    { exact D = (A_map_code hβ (coe_lt_coe.mp hδ) c h).val.elts } }
end

lemma A_map_subrelation {β : Λ} (hβ : β ≤ α) :
subrelation (A_map_relation hβ) (inv_image μr (code_min_map hβ)) :=
begin
  rintro c ⟨⟨δ, hδ, D⟩, hD⟩ h,
  cases δ,
  { cases h },
  unfold A_map_relation at h,
  split_ifs at h, { exfalso, exact h },
  simp_rw h,
  exact A_map_code_order _ _ _ ‹_›
end

/-- There are only finitely many iterated images under any inverse A-map. -/
lemma A_map_relation_well_founded {β : Λ} (hβ : β ≤ α) : well_founded (A_map_relation hβ) :=
(A_map_subrelation hβ).wf (code_wf hβ)

lemma A_map_ranges_disjoint {γ : Λ} (hγ : γ < α) {δ ε : type_index} (hδ : δ < α) (hε : ε < α)
(hγδ : δ ≠ γ) (hγε : ε ≠ γ)
(c : {c : set (tangle α δ _) // c.nonempty}) (d : {d : set (tangle α ε _) // d.nonempty})
(h : A_map hδ hγ hγδ c = A_map hε hγ hγε d) : δ = ε :=
begin
  unfold A_map at h, rw subtype.ext_iff_val at h, dsimp at h,
  obtain ⟨b, hb⟩ := c.property,
  have mem : (to_tangle γ hγ '' local_cardinal (f_map δ γ hδ hγ b))
    ⊆ ⋃ b ∈ (c : set (tangle α δ _)), to_tangle γ hγ '' local_cardinal (f_map δ γ hδ hγ b)
    := set.subset_Union₂ b hb,
  rw h at mem,
  have mem2 : (to_tangle γ hγ) ⟨f_map δ γ hδ hγ b, litter_set _, is_near_litter_litter_set _⟩
    ∈ to_tangle γ hγ '' local_cardinal (f_map δ γ hδ hγ b),
  { refine set.mem_image_of_mem _ _, split, },
  have := set.mem_of_subset_of_mem mem mem2, simp at this,
  obtain ⟨i, hi₁, hi₂⟩ := this,
  exact f_map_range_eq hi₂
end

/-- There is at most one inverse under an A-map. This corresponds to the fact that there is only one
code which is related (on the left) to any given code under the A-map relation. -/
lemma A_map_predecessor_subsingleton {β : Λ} (hβ : β ≤ α) (c : {c : code α β hβ // c.elts.nonempty}) :
{d | A_map_relation hβ d c}.subsingleton :=
begin
  obtain ⟨⟨γ, hγ, G⟩, hG⟩ := c,
  intros x hx y hy,
  dsimp at hx hy,
  unfold A_map_relation at hx hy,
  simp at hx hy,
  cases γ,
  { exfalso, dsimp at hx, exact hx },
  dsimp at hx hy,
  split_ifs at hx hy; try { exfalso, assumption },
  rw [hy, subtype.coe_inj] at hx,
  obtain ⟨⟨δ, hδ, D⟩, hD⟩ := x,
  obtain ⟨⟨ε, hε, E⟩, hE⟩ := y,
  have : δ = ε := A_map_ranges_disjoint _ _ _ _ _ _ _ hx.symm,
  subst this,
  have := A_map_injective _ _ _ hx,
  dsimp at this, cases this, refl
end

/-- The height of a code is the amount of iterated images under an inverse alternative extension map
that it admits. This is uniquely defined since any code has at most one inverse image under the
A-map, and we can just repeat this process until no inverse image exists. -/
noncomputable def height {β : Λ} (hβ : β ≤ α) : {c : code α β hβ // c.elts.nonempty} → ℕ
| c := @dite _ (∃ d, A_map_relation hβ d c) (classical.dec _) (λ h, height h.some) (λ _, 0)
using_well_founded
{ rel_tac := λ _ _, `[exact ⟨A_map_relation hβ, A_map_relation_well_founded hβ⟩],
  dec_tac := `[exact h.some_spec] }

lemma height_zero_of_no_inverse {β : Λ} (hβ : β ≤ α) (c : {c : code α β hβ // c.elts.nonempty})
(hempty : ∀ d, ¬ A_map_relation hβ d c) : height hβ c = 0 :=
by { rw height, split_ifs, { rw ← not_forall_not at h, contradiction }, { refl } }

lemma exists_inverse_of_height_pos {β : Λ} (hβ : β ≤ α) (c : {c : code α β hβ // c.elts.nonempty})
(hpos : 0 < height hβ c) : {d | A_map_relation hβ d c}.nonempty :=
begin
  contrapose hpos,
  simp at ⊢,
  rw [set.not_nonempty_iff_eq_empty, set.eq_empty_iff_forall_not_mem] at hpos,
  exact height_zero_of_no_inverse hβ c hpos
end

noncomputable def A_inverse {β : Λ} (hβ : β ≤ α)
(c : {c : code α β hβ // c.elts.nonempty}) (hpos : 0 < height hβ c) :
{c : code α β hβ // c.elts.nonempty} :=
(exists_inverse_of_height_pos hβ c hpos).some

lemma A_inverse_spec {β : Λ} (hβ : β ≤ α)
(c : {c : code α β hβ // c.elts.nonempty}) (hpos : 0 < height hβ c) :
A_map_relation hβ (A_inverse hβ c hpos) c :=
(exists_inverse_of_height_pos hβ c hpos).some_spec

noncomputable def A_inverse_of_odd {β : Λ} (hβ : β ≤ α) (c : {c : code α β hβ // c.elts.nonempty})
(hodd : odd $ height hβ c) : {c : code α β hβ // c.elts.nonempty} :=
A_inverse hβ c (nat.odd_gt_zero hodd)

def code_equiv {β : Λ} (hβ : β ≤ α) (c d : code α β hβ) : Prop :=
@dite _ (c.elts.nonempty) (classical.dec _)
(λ hnonempty, dite (odd $ height hβ ⟨c, hnonempty⟩)
  (λ hodd, c = d ∨ let e := A_inverse_of_odd hβ ⟨c, hnonempty⟩ hodd in
    dite (d.extension = e.val.extension)
    (λ heq, (cast (by simp_rw heq) e.val.elts) = d.elts)
    (λ hne, @option.rec_on _
      (λ (δ : type_index), Π (extension_lt : δ < β) (hne : e.val.extension ≠ δ), Prop) d.extension
      (λ extension_lt hne, false)
      (λ δ extension_lt hne, (A_map_code hβ (coe_lt_coe.mp extension_lt) e hne).val = d)
      d.extension_lt (ne.symm hne)))
  (λ heven, dite (c.extension = d.extension)
    (λ heq, (cast (by simp_rw heq) c.elts) = d.elts)
    (λ hne, @option.rec_on _
      (λ (δ : type_index), Π (extension_lt : δ < β) (hne : c.extension ≠ δ), Prop) d.extension
      (λ extension_lt hne, false)
      (λ δ extension_lt hne, (A_map_code hβ (coe_lt_coe.mp extension_lt) ⟨c, hnonempty⟩ hne).val = d)
      d.extension_lt hne)))
(λ h, d.elts = ∅ )

/-! We declare new notation for code equivalence. -/
infix `≡`:50 := code_equiv ‹_ ≤ _›

lemma code_equiv_reflexive {β : Λ} (hβ : β ≤ α) : reflexive (≡) :=
begin
  intro c,
  unfold code_equiv,
  split_ifs at *;
  try { simp },
  { rw set.not_nonempty_iff_eq_empty at h,
    exact h },
end

lemma code_equiv_nonempty_iff_nonempty {β : Λ} (hβ : β ≤ α) (c d : code α β hβ) (e : c ≡ d) :
  c.elts.nonempty ↔ d.elts.nonempty :=
begin
  classical,
  cases c with γ hγ G,
  cases d with δ hδ D,
  dsimp,
  split,
  { unfold code_equiv at e,
    dsimp at e,
    intro c1,
    rw dif_pos c1 at e,
    by_cases odd (height hβ ⟨⟨γ, hγ, G⟩, c1⟩),
    { rw dif_pos h at e,
      cases e,
      { cases e, exact c1 },
      { split_ifs at e,
        { subst h_1, rw ← e, simp, exact (A_inverse_of_odd _ _ _).property },
        { cases δ,
          { exfalso, exact e, },
          { have := (A_map_code_coe_eq_iff _ _ _ _ _).mp e,
            rw ← this,
            exact (A_map_code _ _ _ _).property } } } },
    { rw dif_neg h at e,
      by_cases γ = δ,
      { rw dif_pos h at e, convert c1, { exact h.symm }, { rw ← e, simp } },
      { rw dif_neg h at e,
        cases δ,
        { exfalso, exact e, },
        { dsimp at e, rw subtype.coe_eq_iff at e, obtain ⟨h1, -⟩ := e, exact h1 } } } },
  { unfold code_equiv at e, contrapose, intro c1,
    rw dif_neg c1 at e, rw set.not_nonempty_iff_eq_empty, exact e }
end

lemma code_equiv_equal_if_ext_equal {β : Λ}(hβ : β ≤ α)(c d : code α β hβ)(e : c ≡ d)
    (r : c.extension = d.extension) : c = d :=
    begin
      cases c with γ hγ G,
      cases d with δ hδ D,
      unfold code_equiv at e,
      simp at r e ⊢,
      split_ifs at e; subst r; simp at e ⊢,
      { exact e, },
      { cases e,
        { exact e, },
        { --h2 should be contradictory,
          sorry, },
      },
      { cases e,
        { exact e, },
        { --proof looks nontrivial

          sorry, },
      },
      { dsimp at h,
        rw set.not_nonempty_iff_eq_empty at h,
        rw e,
        exact h,
      },

    end
    -- I think this is true (although we only need c.elts == d.elts) (Alex)

lemma code_equiv_symmetric {β : Λ} (hβ : β ≤ α) : symmetric (≡) :=
begin
  classical,
  dsimp,
  -- We split codes into constituent parts after excluding trivial cases
  intros c d e,
  by_cases c.elts.nonempty,
  {
    --Nontrivial case; codes c and d are non-empty
    have h' := h,
    rw (code_equiv_nonempty_iff_nonempty hβ c d e) at h,
    cases c with γ hγ G,
    cases d with δ hδ D,
    dsimp at h,
    unfold code_equiv at e ⊢,
    dsimp at e h' ⊢,
    rw dif_pos h' at e,
    rw dif_pos h,
    simp at e ⊢,
    -- I want a 'δ=γ → D==G' lemma (or something stronger)
    -- The nested structure of dite blocks means we need by-cases on parity of number of preimages,
    -- then care if δ=γ. Logically, I want the opposite (Alex)

    by_cases o1 : even (height hβ ⟨{extension := γ, extension_lt := hγ, elts := G}, h'⟩);
    by_cases o2 : even (height hβ ⟨{extension := δ, extension_lt := hδ, elts := D}, h⟩),
    { rw dif_pos o2,
      rw dif_pos o1 at e,
      by_cases eq: γ = δ,
      { rw dif_pos eq.symm, rw dif_pos eq at e,
        rw ← e, simp, },
      { rw dif_neg eq at e,
        rw dif_neg (ne.symm eq),
        sorry, },
    },
    { rw dif_neg o2,
      rw dif_pos o1 at e,
      by_cases eq: γ = δ,
      { rw dif_pos eq at e,
        left,
        refine ⟨eq.symm, _⟩, rw ← e, simp, },
      { rw dif_neg eq at e,
        right,
        --ugly dite block.
        sorry, }
    },
    { rw dif_pos o2,
      rw dif_neg o1 at e,
      by_cases eq: γ = δ,
      { rw dif_pos eq.symm,
        -- converse of above two cases
        sorry, },
      { rw dif_neg (ne.symm eq),
        -- use eq to take RHS of e.
        sorry, },
    },
    { rw dif_neg o2,
      rw dif_neg o1 at e,
      by_cases eq: γ = δ,
      { --if D==G, done. If not, need unpick another dite (or exfalso it)
        sorry, },
      { right,
        -- use eq to take RHS of e.
        -- codes have different height parity, and are different; nontrivial case.
        sorry, },



    },
  },
sorry  {
      --Trivial case; codes c and d are empty (can definitely be golfed)
      have h' := h,
      rw (code_equiv_nonempty_iff_nonempty hβ c d e) at h,
      unfold code_equiv,
      split_ifs,
      { exfalso,
        exact h h_1, },
      { exfalso,
        exact h h_1, },
      { exfalso,
        exact h h_1, },
      { exfalso,
        exact h h_1, },
      { rw set.not_nonempty_iff_eq_empty at h',
        exact h', },
  },
end

lemma code_equiv_transitive {β : Λ} (hβ : β ≤ α) : transitive (≡) := sorry

lemma code_equiv_equivalence {β : Λ} (hβ : β ≤ α) : equivalence (≡) :=
⟨code_equiv_reflexive hβ, code_equiv_symmetric hβ, code_equiv_transitive hβ⟩

def code.is_representative {β : Λ} {hβ : β ≤ α} (c : code α β hβ) : Prop :=
@dite _ (c.elts.nonempty) (classical.dec _)
(λ hnonempty, even $ height hβ ⟨c, hnonempty⟩)
(λ h, c.extension = ⊥)

@[simp] lemma height_zero_of_singleton {β : Λ} (hβ : β ≤ α)
{γ : type_index} (hγ : γ < β) (g : tangle α γ _) :
height hβ ⟨⟨γ, hγ, {g}⟩, set.singleton_nonempty g⟩ = 0 :=
begin
  refine height_zero_of_no_inverse _ _ _,
  intros d hd,
  unfold A_map_relation at hd,
  cases γ,
  { dsimp at hd, exact hd },
  { dsimp at hd, split_ifs at hd,
    { exact hd },
    { have mk := cardinal.mk_singleton g, rw hd at mk,
      suffices : ¬ #μ ≤ 1,
      { rw ← mk at this, exact this (mk_A_map _ _ h ⟨(d : code α β hβ).elts, _⟩) },
      push_neg,
      transitivity ℵ₀,
      exact cardinal.one_lt_aleph_0,
      exact lt_of_le_of_lt κ_regular.aleph_0_le κ_lt_μ } }
end

lemma singleton_equiv {β : Λ} (hβ : β ≤ α) {γ : Λ} (hγ : γ < β) {δ : Λ} (hδ : δ < β) (hγδ : γ ≠ δ)
(g : tangle _ _ _) :
⟨γ, coe_lt_coe.mpr hγ, {g}⟩ ≡
  ⟨δ, coe_lt_coe.mpr hδ, to_tangle δ (hδ.trans_le hβ) ''
    local_cardinal (f_map γ δ (coe_lt_coe.mpr (hγ.trans_le hβ)) (hδ.trans_le hβ) g)⟩ :=
begin
  classical,
  unfold code_equiv, dsimp, rw dif_pos (set.singleton_nonempty g),
  have : even (height hβ ⟨⟨γ, coe_lt_coe.mpr hγ, {g}⟩, set.singleton_nonempty g⟩),
  { convert even_zero, simp },
  rw [dif_neg (nat.even_iff_not_odd.mp this), dif_neg (hγδ ∘ coe_eq_coe.mp)],
  simp_rw option.coe_def, unfold A_map_code, simp, unfold A_map, simp
end

lemma singleton_equiv_iff {β : Λ} (hβ : β ≤ α) {γ : Λ} {hγ : γ < β}
{g : tangle _ _ _} {c : code α β hβ} :
⟨γ, coe_lt_coe.mpr hγ, {g}⟩ ≡ c ↔
c = ⟨γ, coe_lt_coe.mpr hγ, {g}⟩ ∨
∃ δ (hc : c.extension = some δ) (hδ : δ < β) (hγδ : γ ≠ δ),
  c = (A_map_code hβ hδ
    ⟨⟨γ, coe_lt_coe.mpr hγ, {g}⟩, set.singleton_nonempty g⟩ (hγδ ∘ coe_eq_coe.mp)) :=
begin
  classical,
  split,
  { intro h, unfold code_equiv at h, dsimp at h, rw dif_pos (set.singleton_nonempty g) at h,
    have : even (height hβ ⟨⟨γ, coe_lt_coe.mpr hγ, {g}⟩, set.singleton_nonempty g⟩),
    { convert even_zero, simp },
    rw dif_neg (nat.even_iff_not_odd.mp this) at h,
    cases c with δ hδ D,
    split_ifs at h,
    { left, dsimp at h_1, subst h_1, simp at h, rw h },
    { right, cases δ; dsimp at h,
      { exfalso, exact h },
      { rw ← h, exact ⟨δ, by { simp, refl }, coe_lt_coe.mp hδ, h_1 ∘ coe_eq_coe.mpr, rfl⟩ } } },
  { intro h, cases h,
    { rw h, exact code_equiv_reflexive hβ _ },
    { obtain ⟨δ, hc, hδ, hγδ, hA⟩ := h, rw hA,
      convert singleton_equiv hβ hγ hδ hγδ g,
      unfold A_map_code, unfold A_map, simp } }
end

@[simp] lemma singleton_ne_A_map_code {β : Λ} (hβ : β ≤ α) {δ : Λ} {hδ : δ < β}
{g : tangle α δ (coe_lt_coe.mpr (hδ.trans_le hβ))} {c : {c : code α β hβ // c.elts.nonempty}}
{hγδ : c.val.extension ≠ δ}
(h : (⟨δ, coe_lt_coe.mpr hδ, {g}⟩ : code α β hβ) = A_map_code hβ hδ c hγδ) : false :=
begin
  unfold A_map_code at h, simp at h,
  have := cardinal.mk_singleton g,
  rw h at this,
  have : #μ ≤ 1,
  { rw ← this, simp },
  contrapose this, push_neg, transitivity ℵ₀,
  exact cardinal.one_lt_aleph_0, exact lt_of_le_of_lt κ_regular.aleph_0_le κ_lt_μ
end

lemma extension_eq_of_singleton_equiv_singleton {β : Λ} (hβ : β ≤ α)
{γ δ : Λ} (hγ : γ < β) (hδ : δ < β)
(a b : tangle _ _ _) (h : ⟨γ, coe_lt_coe.mpr hγ, {a}⟩ ≡ ⟨δ, coe_lt_coe.mpr hδ, {b}⟩) :
γ = δ :=
begin
  cases (singleton_equiv_iff hβ).mp h,
  { simp at h_1, exact coe_eq_coe.mp h_1.left.symm },
  { exfalso, obtain ⟨ε, hc, hε, hγε, hA⟩ := h_1,
    have := congr_arg code.extension hA, simp at this, rw coe_eq_coe at this, subst this,
    simp at hA, exact hA }
end

lemma eq_of_singleton_equiv_singleton {β : Λ} (hβ : β ≤ α)
{γ δ : Λ} (hγ : γ < β) (hδ : δ < β)
(a b : tangle _ _ _) (h : ⟨γ, coe_lt_coe.mpr hγ, {a}⟩ ≡ ⟨δ, coe_lt_coe.mpr hδ, {b}⟩) :
a = cast (by simp_rw extension_eq_of_singleton_equiv_singleton _ _ _ _ _ h) b :=
begin
  cases (singleton_equiv_iff hβ).mp h,
  { simp at h_1, have := coe_eq_coe.mp h_1.left, subst this, simp at h_1 ⊢, exact h_1.symm },
  { exfalso, obtain ⟨ε, hc, hε, hγε, hA⟩ := h_1,
    have := congr_arg code.extension hA, simp at this, rw coe_eq_coe at this, subst this,
    simp at hA, exact hA }
end

/-!
Note for whoever is formalising this: feel free to reorder these definitions if it turns out
to be useful to use some lemmas in the proofs of others.
-/

lemma height_plus_one {β δ : Λ} {hβ : β ≤ α} {hδ : δ < β} (c : code α β hβ) (h : c.elts.nonempty) {hcδ : c.extension ≠ δ} : height hβ (A_map_code hβ hδ ⟨c, h⟩ hcδ) = (height hβ ⟨c, h⟩).succ := sorry

lemma representative_code_unique {β : Λ} {hβ : β ≤ α} (c : code α β hβ) (d : code α β hβ) (hc : c.is_representative) (hd : d.is_representative) (hequiv : d ≡ c) : d = c :=
begin
  classical,
  by_cases c.elts.nonempty,
  { have := (code_equiv_nonempty_iff_nonempty hβ d c hequiv).2 h,
    unfold code.is_representative at hc hd,
    unfold code_equiv at hequiv,
    rw dif_pos h at hc,
    rw dif_pos this at hd hequiv,
    rw dif_neg (nat.even_iff_not_odd.1 hd) at hequiv,
    split_ifs at hequiv,
    { ext1, exact h_1,
      refine heq_of_cast_eq _ hequiv, },
    { cases c with γ hγ G, dsimp at h h_1 hequiv,
      cases γ; dsimp at hequiv, cases hequiv,
      suffices : ¬even (height hβ ⟨d, this⟩), cases this hd,
      rw [← nat.even_succ, ← height_plus_one],
      simp_rw ← hequiv at hc, exact hc, }},
  { have := h, rw ← code_equiv_nonempty_iff_nonempty hβ d c hequiv at this,
    unfold code.is_representative at hc hd,
    unfold code_equiv at hequiv,
    rw dif_neg h at hc,
    rw dif_neg this at hd hequiv,
    ext1, rw [hc, hd],
    rw set.not_nonempty_iff_eq_empty at h this,
    rw ← hd at hc,
    cases c with γ hγ G, cases d with δ hδ D,
    dsimp at hc h this, subst hc,
    dsimp, rw [h, this], }
end

lemma representative_code_exists_unique {β : Λ} {hβ : β ≤ α} (c : code α β hβ) :
∃! d ≡ c, d.is_representative := sorry

lemma equiv_code_exists_unique {β : Λ} {hβ : β ≤ α} (γ : Λ) (c : code α β hβ) :
∃! d ≡ c, d.extension = γ := sorry

lemma equiv_bot_code_subsingleton {β : Λ} {hβ : β ≤ α} (c : code α β hβ) :
∀ d ≡ c, ∀ e ≡ c, d.extension = ⊥ → e.extension = ⊥ → d = e := sorry

end con_nf
