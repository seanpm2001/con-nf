import combinatorics.quiver.path
import phase0.params

open cardinal function quiver quiver.path set with_bot
open_locale cardinal

universe u

namespace con_nf
variables [params.{u}]

section Iio_Iic
variables {α β : Λ}

abbreviation Iio_index (α : Λ) := Iio (α : type_index)
abbreviation Iic_index (α : Λ) := Iic (α : type_index)

instance coe_Iio_Iic : has_coe_t (Iio α) (Iic α) := ⟨λ β, ⟨β.1, le_of_lt β.2⟩⟩

instance coe_Iio : has_coe_t (Iio α) (Iio_index α) := ⟨λ β, ⟨β.1, coe_lt_coe.2 β.2⟩⟩
instance coe_Iic : has_coe_t (Iic α) (Iic_index α) := ⟨λ β, ⟨β.1, coe_le_coe.2 β.2⟩⟩

abbreviation Iio_coe : Iio α → Iio_index α := coe
abbreviation Iic_coe : Iic α → Iic_index α := coe

@[simp] lemma Iio.coe_mk (β : Λ) (hβ : β < α) :
  ((⟨β, hβ⟩ : Iio α) : Iio_index α) = ⟨β, coe_lt_coe.2 hβ⟩ := rfl
@[simp] lemma Iic.coe_mk (β : Λ) (hβ : β ≤ α) :
  ((⟨β, hβ⟩ : Iic α) : Iic_index α) = ⟨β, coe_le_coe.2 hβ⟩ := rfl

lemma Iio.coe_injective : injective (coe : Iio α → Iio_index α) :=
begin
  rintro ⟨β, hβ⟩ ⟨γ, hγ⟩ h,
  simp only [Iio.coe_mk, subtype.mk_eq_mk] at h,
  have := with_bot.coe_injective h,
  subst this,
end
lemma Iic.coe_injective : injective (coe : Iic α → Iic_index α) :=
begin
  rintro ⟨β, hβ⟩ ⟨γ, hγ⟩ h,
  simp only [Iic.coe_mk, subtype.mk_eq_mk] at h,
  have := with_bot.coe_injective h,
  subst this,
end

@[simp] lemma Iio.coe_inj {β γ : Iio α} : Iio_coe β = γ ↔ β = γ :=
Iio.coe_injective.eq_iff
@[simp] lemma Iic.coe_inj {β γ : Iic α} : Iic_coe β = γ ↔ β = γ :=
Iic.coe_injective.eq_iff

section Iio_index
variables {hβ : (β : type_index) ∈ Iio_index α}

instance : has_bot (Iio_index α) := ⟨⟨⊥, bot_lt_coe _⟩⟩
instance : inhabited (Iio_index α) := ⟨⊥⟩

@[simp] lemma Iio_index.bot_ne_mk_coe : (⊥ : Iio_index α) ≠ ⟨β, hβ⟩ :=
ne_of_apply_ne subtype.val bot_ne_coe

@[simp] lemma Iio_index.mk_coe_ne_bot : (⟨β, hβ⟩ : Iio_index α) ≠ ⊥ :=
ne_of_apply_ne subtype.val coe_ne_bot

@[simp] lemma Iio_index.bot_ne_coe {β : Iio α} : ⊥ ≠ (β : Iio_index α) :=
ne_of_apply_ne subtype.val bot_ne_coe

@[simp] lemma Iio_index.coe_ne_bot {β : Iio α} : (β : Iio_index α) ≠ ⊥ :=
ne_of_apply_ne subtype.val coe_ne_bot

end Iio_index

section Iic_index
variables {hβ : (β : type_index) ∈ Iic_index α}

instance : has_bot (Iic_index α) := ⟨⟨⊥, bot_le⟩⟩
instance : inhabited (Iic_index α) := ⟨⊥⟩

@[simp] lemma Iic_index.bot_ne_mk_coe : (⊥ : Iic_index α) ≠ ⟨β, hβ⟩ :=
ne_of_apply_ne subtype.val bot_ne_coe

@[simp] lemma Iic_index.mk_coe_ne_bot : (⟨β, hβ⟩ : Iic_index α) ≠ ⊥ :=
ne_of_apply_ne subtype.val coe_ne_bot
end Iic_index

end Iio_Iic

/-!
We now intend to deal with the familiar tools from phase 1 along paths `A` from `α ⟶ β` down the
TTT type hierarchy, instead of linearly level-by-level. We will construct three main definitions:

* `le_index`: A type index `β`, together with a path down from `α` to level `β`.
* `lt_index`: A type index `β`, together with a path down from `α`, to some level `γ`, and then
    directly to level `β`. This enforces that the path obtained from composing `A` with this new
    `γ ⟶ β` morphism is nontrivial by construction.
* `proper_lt_index`: Like `lt_index` but the type index `β` is proper; that is, it lies in `Λ`.

Each of these types is progressively more stringent, and they have natural coercions upwards (i.e.
from `proper_lt_index` to `lt_index` to `le_index`, and the transitive coercion from
`proper_lt_index` to `le_index`). They also have coercions to their index types (`type_index` in the
first two cases, and `Λ` in the third).

We will then proceed to define new API for many phase 1 constructions (tangles, f-maps, ...)
that use these three types instead of `Λ`, `type_index`, and `Iio α`. All of the properties that
were proven in phase 1 of course still hold for the functions under these new names - their
functionality has not changed.

These constructions are helpful for stating and proving the freedom-of-action theorem, since it
allows for the possibility that the type of `β`-tangles (for instance) depends on the path downwards
from `α` to `β`. In our actual construction, this does hold, since phase 1 is conducted entirely
linearly, but this feature is not actually needed for defining and proving statements in most of
phase 2, so we use this alternate formalisation.
-/

section improper
variables {α : type_index}

/-- We define the type of paths from certain types to lower types as elements of this quiver. -/
instance quiver : quiver type_index := ⟨(>)⟩

/-- A (finite) path from the type α to the base type.
This can be seen as a way that we can perceive extensionality, iteratively descending to lower
types in the hierarchy until we reach the base type.
This plays the role of an extended type index in the paper. -/
def extended_index (α : type_index) := quiver.path α ⊥

/-- If there is a path between `α` and `β`, we must have `β ≤ α`.
The case `β = α` can occur with the nil path. -/
lemma le_of_path : Π {β : type_index}, path α β → β ≤ α
| β nil := le_rfl
| β (cons p f) := (le_of_lt f).trans $ le_of_path p

lemma path_eq_nil : ∀ p : path α α, p = nil
| nil := rfl
| (cons p f) := ((le_of_path p).not_lt f).elim

/-! The next few results won't be needed in the same way in Lean 4. -/

def path.Iic_rec' {α : Λ} {β : Iic_index α}
  (motive : Π (γ : type_index), path (β : type_index) γ → Sort*) :
  motive β nil → (Π (γ δ : type_index) (hγ : γ ≤ α) (hδ : δ ≤ α) (A : path (β : type_index) γ)
    (h : δ < γ), motive γ A → motive δ (A.cons h)) →
  Π (γ : Iic_index α) (A : path (β : type_index) γ),
  motive (⟨γ, (le_of_path A).trans β.prop⟩ : Iic_index α) A :=
λ hn hc γ, path.rec hn
  (λ γ δ A h, hc γ δ ((le_of_path A).trans β.prop) ((le_of_path (A.cons h)).trans β.prop) A h)

def motive_equiv {α : Λ} {β : Iic_index α}
  {motive : Π (γ : Iic_index α), path (β : type_index) γ → Sort*}
  {γ : Iic_index α} {A : path (β : type_index) γ} :
  motive (⟨γ, γ.prop⟩ : Iic_index α) A ≃ motive γ A :=
equiv.cast (by cases γ; refl)

/-- An induction principle for paths that allows us to use `Iic_index α` instead of needing to
define the motive for all `type_index`. -/
@[elab_as_eliminator]
def path.Iic_rec {α : Λ} {β : Iic_index α}
  {motive : Π (γ : Iic_index α), path (β : type_index) γ → Sort*} :
  motive β nil → (Π (γ δ : Iic_index α) (A : path (β : type_index) γ) (h : δ < γ),
    motive γ A → motive δ (A.cons h)) →
  Π (γ : Iic_index α) (A : path (β : type_index) γ), motive γ A :=
λ hn hc γ A, motive_equiv (motive_equiv (show _, from
  path.Iic_rec' (λ γ A, motive ⟨γ, (le_of_path A).trans β.prop⟩ A)
  (motive_equiv.symm hn)
  (λ γ δ hγ hδ A h, hc ⟨γ, (le_of_path A).trans β.prop⟩
    ⟨δ, (le_of_path (A.cons h)).trans β.prop⟩ A h)
  γ A))

@[simp] lemma path.Iic_rec_nil {α : Λ} {β : Iic_index α}
  {motive : Π (γ : Iic_index α), path (β : type_index) γ → Sort*} {hn : motive β nil} {hc} :
  @path.Iic_rec _ _ _ motive hn hc β nil = hn :=
begin
  rw [path.Iic_rec, path.Iic_rec'],
  simp only [subtype.coe_mk, motive_equiv, equiv.cast_symm, equiv.cast_apply, cast_cast, cast_eq],
end

@[simp] lemma path.Iic_rec_cons {α : Λ} {β : Iic_index α}
  {motive : Π (γ : Iic_index α), path (β : type_index) γ → Sort*}
  {hn : motive β nil} {hc} (γ δ : Iic_index α) (A : path (β : type_index) γ) (h : δ < γ) :
  @path.Iic_rec _ _ _ motive hn hc δ (A.cons h) = hc γ δ A h (path.Iic_rec hn hc γ A) :=
begin
  rw [path.Iic_rec, path.Iic_rec'],
  dsimp only [subtype.coe_mk, motive_equiv],
  simp only [equiv.cast_refl, equiv.cast_symm, equiv.cast_apply, equiv.coe_refl, id.def],
  rw cast_eq_iff_heq,
  congr,
  rw subtype.coe_eta,
  rw subtype.coe_eta,
  exact (cast_heq _ _).symm,
end

/-- There are at most `Λ` `α`-extended type indices. -/
@[simp] lemma mk_extended_index (α : type_index) : #(extended_index α) ≤ #Λ :=
begin
  refine le_trans ((cardinal.le_def _ _).2 ⟨⟨to_list, to_list_injective (α : type_index) ⊥⟩⟩) _,
  convert mk_list_le_max _ using 1, simp only [mk_type_index, max_eq_right, aleph_0_le_mk],
end

/-- If `β < γ`, we have a path directly between the two types in the opposite order.
Note that the `⟶` symbol (long right arrow) is not the normal `→` (right arrow),
even though monospace fonts often display them similarly. -/
instance lt_to_hom (β γ : Λ) : has_lift_t (β < γ) ((γ : type_index) ⟶ β) := ⟨coe_lt_coe.2⟩

/-- The direct path from the base type to `α`. -/
def type_index.extend : Π α : type_index, extended_index α
| ⊥ := nil
| (α : Λ) := hom.to_path $ with_bot.bot_lt_coe α

instance (α : type_index) : inhabited (extended_index α) := ⟨α.extend⟩

/-- There exists an `α`-extended type index. --/
lemma mk_extended_index_ne_zero (α : type_index) : #(extended_index α) ≠ 0 := cardinal.mk_ne_zero _

/-- A type index `β`, together with a path down from `α` to level `β`. Hence, `β ≤ α`.
This type is intended to be used in place of `β : type_index, β ≤ α` in phase 2. -/
@[ext, protect_proj] structure le_index (α : type_index) :=
(index : type_index)
(path : path α index)

namespace le_index

instance : inhabited (le_index α) := ⟨⟨⊥, α.extend⟩⟩

/-- By forgetting the path that we took from `α` to the lower index `β`, we can recover the type
index `β` that this `le_index` wraps. -/
instance has_coe_type_index : has_coe (le_index α) type_index := ⟨le_index.index⟩

@[simp] lemma coe_mk (index : type_index) (path : path (α : type_index) index) :
  ((⟨index, path⟩ : le_index α) : type_index) = index := rfl

/-- Add an index to a `le_index`. -/
def cons (A : le_index α) {γ : type_index} (hγ : γ < A.index) : le_index α :=
⟨γ, A.path.cons hγ⟩

end le_index

/-- A type index `β`, together with a path `A` down from `α` to level `γ` and then to level `β`.
This enforces that the path obtained from composing `A` with this new `γ ⟶ β` morphism is
nontrivial by construction. This type is intended to be used in place of `β : type_index, β < α`
and `β : Iio_index α` in phase 2. -/
@[ext] structure lt_index (α : type_index) :=
(index : type_index)
(higher : type_index)
(index_lt_higher : index < higher)
(path' : path α higher)

namespace lt_index

/-- A constructor for `lt_index` with less explicit arguments. -/
def mk' {index higher : type_index} (index_lt : index < higher)
  (path' : path (α : type_index) higher) : lt_index α :=
⟨index, higher, index_lt, path'⟩

instance {α : Λ} : inhabited (lt_index α) := ⟨mk' (bot_lt_coe _) path.nil⟩

/-- A path compatible with the one from `le_index`, formed by composing the inner `path'` field
with the morphism `higher ⟶ index`. By construction, this path is always nontrivial. -/
def path (A : lt_index α) : path (α : type_index) A.index := A.path'.cons A.index_lt_higher

/-- An `lt_index` is not equal to its source `α`. This is the lemma that justifies the name
`lt_index` as compared to `le_index`, which permits the trivial path `α ⟶ α`. -/
lemma index_lt (A : lt_index α) : A.index < α := A.index_lt_higher.trans_le $ le_of_path A.path'

/-- The natural coercion from `lt_index` to `le_index`. An analogous concept to `le_of_lt`. -/
def to_le_index (A : lt_index α) : le_index α := ⟨A.index, A.path⟩

instance has_coe_le_index : has_coe (lt_index α) (le_index α) := ⟨to_le_index⟩

/-- By forgetting the path that we took from `α` to the lower index `β`, we can recover the type
index `β` that this `lt_index` wraps. -/
instance has_coe_type_index : has_coe (lt_index α) type_index := ⟨index⟩

end lt_index
end improper

/-- A proper type index `β`, together with a path `A` down from `α` to level `γ` and then to level
`β`. This enforces that the path obtained from composing `A` with this new `γ ⟶ β` morphism is
nontrivial by construction. This type is intended to be used in phase of `β : Λ, β < α` and
`β : Iio α` in phase 2. -/
@[ext, nolint has_nonempty_instance] structure proper_lt_index (α : Λ) :=
(index higher : Λ)
(index_lt_higher : index < higher)
(path' : path (α : type_index) higher)

namespace proper_lt_index
variables {α : Λ}

/-- A constructor for `proper_lt_index` with less explicit arguments. -/
def mk' {α index higher : Λ} (index_lt : index < higher) (path' : path (α : type_index) higher) :
  proper_lt_index α :=
⟨index, higher, index_lt, path'⟩

/-- A path compatible with the one from `le_index`, formed by composing the inner `path'` field
with the morphism `higher ⟶ index`. By construction, this path is always nontrivial. -/
def path (A : proper_lt_index α) : path (α : type_index) A.index :=
A.path'.cons $ coe_lt_coe.2 A.index_lt_higher

/-- A `proper_lt_index` is not equal to its source `α`. See also `lt_index.ne`. -/
lemma index_lt (A : proper_lt_index α) : A.index < α :=
A.index_lt_higher.trans_le $ coe_le_coe.1 $ le_of_path A.path'

/-- The natural coercion from `proper_lt_index` to `le_index`.
An analogous concept to `le_of_lt`, also converting `index: Λ` into a `type_index`. -/
def to_le_index (A : proper_lt_index α) : le_index α :=
⟨A.index, A.path⟩

/-- The natural coercion from `proper_lt_index` to `to_lt_index`, by converting `index : Λ` into a
`type_index`. -/
def to_lt_index (A : proper_lt_index α) : lt_index α :=
⟨A.index, A.higher, coe_lt_coe.2 A.index_lt_higher, A.path'⟩

instance has_coe_lt_index : has_coe (proper_lt_index α) (lt_index α) := ⟨to_lt_index⟩

/-- By forgetting the path that we took from `α` to the lower index `β`, we can recover the proper
type index `β` that this `proper_lt_index` wraps. -/
instance has_coe_Λ : has_coe (proper_lt_index α) Λ := ⟨index⟩

end proper_lt_index
end con_nf
