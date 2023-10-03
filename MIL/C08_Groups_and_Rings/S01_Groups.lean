-- BOTH:
import Mathlib.Algebra.Ring.Defs
import Mathlib.Data.Real.Basic
import Mathlib.GroupTheory.Sylow
import Mathlib.GroupTheory.Perm.Cycle.Concrete
import Mathlib.GroupTheory.Perm.Subgroup
import Mathlib.GroupTheory.PresentedGroup
import MIL.Common

/- TEXT:
.. _groups:

Monoids and Groups
------------------

.. index:: monoid
.. index:: group (algebraic structure)

Monoids and their morphisms
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Algebra courses often start the description of fundamental algebraic structures with groups and
then progress to rings, fields and vector spaces. This involves some contortions when discussing
multiplication on rings since this operation does not come from a group structure, and yet many
proofs from the group theory chapter carry over verbatim in this new setting. The most common fix
on paper is to leave those proofs as exercises. A less efficient but safer and
formalization-friendlier of proceeding is to discuss monoids. A monoid structure on a type `M`
is an internal composition law which is associative and has a neutral element.
The main use of this structure is to accommodate both groups and the multiplicative structure
rings. But there are also a number of natural examples, for instance natural numbers equipped with
addition form a monoid.

From a practical point of view, you can almost ignore monoids when using Mathlib. But you need
to know they exist when looking for a lemma by browsing Mathlib files. Indeed you may be looking
in group theory files for a statement which is actually located in a monoid file because it does not
require elements to be invertible.

The type of monoids structures on a type ``M`` with multiplicative notation is ``Monoid M``.
The function ``Monoid`` is a type class so it will almost always appear as an instance implicit
argument (ie. in square brackets). The additive notation version is ``AddMonoid``.
The commutative versions add the ``Comm`` prefix before ``Monoid``.
EXAMPLES: -/
-- QUOTE:

example {M : Type*} [Monoid M] (x : M) : x*1 = x := mul_one x

example {M : Type*} [AddCommMonoid M] (x y : M) : x + y = y + x := add_comm x y

-- QUOTE.
/- TEXT: Note in particular that ``AddMonoid`` exists, although it would be very confusing to use
additive notation in a non-commutative case on paper.

The type of morphisms between monoids ``M`` and ``N`` is called ``MonoidHom M N`` and denoted by
``M →* N``. Lean will automatically see such a morphism as a function from ``M`` to ``N`` when
users apply them to elements of ``M``. The additive version is called ``AddMonoidHom`` and denoted
by ``M →+ N``.
EXAMPLES: -/
-- QUOTE:

example {M N : Type*} [Monoid M] [Monoid N] (x y : M) (f : M →* N) : f (x * y) = f x * f y :=
f.map_mul x y

example {M N : Type*} [AddMonoid M] [AddMonoid N] (f : M →+ N) : f 0 = 0 :=
f.map_zero

-- QUOTE.
/- TEXT:
Those morphisms are bundled maps, ie package together a map and some properties of this map.
Section :numref:`section_hierarchies_morphisms` contain a lot more explanations about that.
Here we simply note the slightly unfortunate consequence that we cannot use ordinary function
composition. We need to use ``MonoidHom.comp`` and ``AddMonoidHom.comp``.

EXAMPLES: -/
-- QUOTE:

example {M N P : Type*} [AddMonoid M] [AddMonoid N] [AddMonoid P]
  (f : M →+ N) (g : N →+ P) : M →+ P := g.comp f
-- QUOTE.
/- TEXT:
Groups and their morphisms
^^^^^^^^^^^^^^^^^^^^^^^^^^

After this brief excursion through monoids, we want to spend a lot more time with groups.
Compared to monoids, groups have the extra property that every element has an inverse.

EXAMPLES: -/
-- QUOTE:

example {G : Type*} [Group G] (x : G) : x * x⁻¹ = 1 := mul_inv_self x

-- QUOTE.
/- TEXT: Similar to the `ring` tactic that we saw earlier, there is a ``group`` tactic that proves
every identity which follows from the group axioms with any extra assumption
(hence one can see it as a tactic proving identities that hold in free groups).
EXAMPLES: -/
-- QUOTE:

example {G : Type*} [Group G] (x y z : G) : x * (y * z) * (x*z)⁻¹ * (x * y * x⁻¹)⁻¹ = 1 := by
  group

-- QUOTE.
/- TEXT: And there is similar a tactic for identities in commutative additive groups called ``abel``.
EXAMPLES: -/
-- QUOTE:

example {G : Type*} [AddCommGroup G] (x y z : G) : z + x + (y - z - x) = y := by
  abel

-- QUOTE.
/- TEXT: We can now move to group morphism. Actually moving isn't the right word since a group
morphism is nothing but a monoid morphism between groups. So we can copy-paste one of our
earlier examples, replacing ``Monoid`` with ``Group``.
EXAMPLES: -/
-- QUOTE:

example {G H : Type*} [Group G] [Group H] (x y : G) (f : G →* H) : f (x * y) = f x * f y :=
f.map_mul x y

-- QUOTE.
/- TEXT: Of course we do get some new properties, such as
EXAMPLES: -/
-- QUOTE:

example {G H : Type*} [Group G] [Group H] (x : G) (f : G →* H) : f (x⁻¹) = (f x)⁻¹ :=
f.map_inv x

-- QUOTE.
/- TEXT: You may be worried that constructing group morphisms will involve unneeded work since
the definition of monoid morphism enforces that neutral elements are sent to neutral element
while this is automatic in the case of group morphisms. In practice the extra work is always
trivial but, just in case, there are functions building a group morphism from a function
between groups that is compatible with the composition laws.
EXAMPLES: -/
-- QUOTE:

example {G H : Type*} [Group G] [Group H] (f : G → H) (h : ∀ x y, f (x * y) = f x * f y) : G →* H :=
MonoidHom.mk' f h

-- QUOTE.
/- TEXT:
There is also a type ``MulEquiv`` of group (or monoid) isomorphisms denoted by ``≃*`` (and
``AddEquiv`` denoted by ``≃+`` in additive notation).
The inverse of ``f : G ≃* H`` is ``f.symm : H ≃* G``, composition is ``MulEquiv.trans`` and
the identity isomorphism of ``G`` is ``M̀ulEquiv.refl G``.
This type is automativally coerced to morphisms and functions.
EXAMPLES: -/
-- QUOTE:
example {G H : Type*} [Group G] [Group H] (f : G ≃* H) : f.trans f.symm = MulEquiv.refl G :=
f.self_trans_symm

-- QUOTE.
/- TEXT:
Subgroups
^^^^^^^^^

In the same way group morphisms are bundled, subgroups are also bundles made of a set in ``G``
and some stability properties.
EXAMPLES: -/
-- QUOTE:

example {G : Type*} [Group G] (H : Subgroup G) {x y : G} (hx : x ∈ H) (hy : y ∈ H) : x * y ∈ H :=
H.mul_mem hx hy

example {G : Type*} [Group G] (H : Subgroup G) {x : G} (hx : x ∈ H) : x⁻¹ ∈ H :=
H.inv_mem hx

-- QUOTE.
/- TEXT:
In the above example, it is important to understand that ``Subgroup G`` is the type of subgroups
of ``G``. It is endowed with a coercion to ``Set G`` and a membership predicate on ``G``.
See Section :numref:`section_hierarchies_subobjects` for explanations about why and how things are
set up like this.

If you want how to state and prove something like ``ℤ`` is an additive subgroup of ``ℚ`` then
the answer to constructor a term with type ``AddSubgroup ℚ`` whose projection to ``Set ℚ``
is ``ℤ``, or more precisely the image of ``ℤ`` in ``ℚ``.
EXAMPLES: -/
-- QUOTE:

example : AddSubgroup ℚ where
  carrier := Set.range ((↑) : ℤ → ℚ)
  add_mem' := by
    rintro _ _ ⟨n, rfl⟩ ⟨m, rfl⟩
    use n + m
    simp
  zero_mem' := by
    use 0
    simp
  neg_mem' := by
    rintro _ ⟨n, rfl⟩
    use -n
    simp

-- QUOTE.
/- TEXT:
Of course the type class instance system knows that a subgroup of a group inherits a group
structure.
EXAMPLES: -/
-- QUOTE:

example {G : Type*} [Group G] (H : Subgroup G) : Group H := inferInstance

-- QUOTE.
/- TEXT:
But note this is subtler than it looks. The object ``H`` is not a type, but Lean automatically
inserts a coercion to type using subtypes. So the above example can be restated more explicitly
as:
EXAMPLES: -/
-- QUOTE:

example {G : Type*} [Group G] (H : Subgroup G) : Group {x : G // x ∈ H} := inferInstance

-- QUOTE.
/- TEXT:
An important benefit of having a type ``Subgroup G`` instead of a predicate
``IsSubgroup : Set G → Prop`` is that one can easily endow it with additional structure.
Crucially this includes a complete lattice structure with respect to inclusion.
For instance, instead of having a lemma stating that an intersection of two subgroups of ``G``, we
have the lattice operation ``⊓`` and all lemmas about lattices are readily available.

Let us check that the set underlying the infimum of two subgroups is indeed, by definition,
their intersection.
EXAMPLES: -/
-- QUOTE:

example {G : Type*} [Group G] (H H' : Subgroup G) :
  ((H ⊓ H' : Subgroup G) : Set G) = (H : Set G) ∩ (H' : Set G) := rfl

-- QUOTE.
/- TEXT:
In the intersection case it may look strange to have a different notation, but this is somehow
an accident which does not carry over to the supremum operation since a union of subgroup
is not a subgroup. Instead one needs to use the subgroup generated by the union, which is done
using ``Subgroup.closure``.
EXAMPLES: -/
-- QUOTE:

example {G : Type*} [Group G] (H H' : Subgroup G) :
    ((H ⊔ H' : Subgroup G) : Set G) = Subgroup.closure ((H : Set G) ∪ (H' : Set G)) := by
  simp [Subgroup.closure_union, Subgroup.closure_eq]

-- QUOTE.
/- TEXT:
Tying the previous two topics together, one can push forward and pull back subgroups using
group morphisms. The naming convention in Mathlib is to call those operations ``map``
and ``comap``. Those names are slightly strange but much shorter that push-forward or direct-image.
EXAMPLES: -/
-- QUOTE:

example {G H : Type*} [Group G] [Group H] (G' : Subgroup G) (f : G →* H) : Subgroup H :=
Subgroup.map f G'

example {G H : Type*} [Group G] [Group H] (H' : Subgroup H) (f : G →* H) : Subgroup G :=
Subgroup.comap f H'

-- QUOTE.
/- TEXT: Lagrange theorem states the cardinal of a subgroup of a finite group divides the cardinal of the
group. Sylow's first theorem if a very famous partial converse to Lagrange's theorem.
EXAMPLES: -/
-- QUOTE:

attribute [local instance 10] setFintype Classical.propDecidable

open Fintype

example {G : Type*} [Group G] [Fintype G] (G' : Subgroup G) : card G' ∣ card G :=
  ⟨G'.index, mul_comm G'.index _ ▸ G'.index_mul_card.symm⟩

open Subgroup

example {G : Type*} [Group G] [Fintype G] (p : ℕ) {n : ℕ} [Fact p.Prime]
    (hdvd : p ^ n ∣ card G) : ∃ K : Subgroup G, card K = p ^ n :=
  Sylow.exists_subgroup_card_pow_prime p hdvd

-- QUOTE.
/- TEXT:
Concrete groups
^^^^^^^^^^^^^^^

One can also manipulate concrete groups in Mathlib, although this is typically more complicated than
abstract theory.
For instance, given any type ``X``, the group of permutations of ``X`` is ``Equiv.Perm X``.
In particular the symmetric group :math:`\mathfrak{S}_n` is ``Equiv.Perm (Fin n)``.
One can state abstract results about this group, for instance saying that ``Equiv.Perm X`` is
generated by cycles if ``X`` is finite.
EXAMPLES: -/
-- QUOTE:

open Equiv

example {X : Type*} [Finite X] : Subgroup.closure {σ : Perm X | Equiv.Perm.IsCycle σ} = ⊤ :=
Perm.closure_isCycle

-- QUOTE.
/- TEXT:
One can fully concrete and compute actual products of cycles. Below we use the ``#simp`` command
which calls the ``simp`` tactic on a given expression. The ``c[]`` notation is used to define a
cyclic premutation. In the example the result is a permutation of ``ℕ``. One could a type ascription
such as ``(1 : Fin 5)`` on the first number appearing to make it a computation in ``Perm (Fin 5)``.
EXAMPLES: -/
-- QUOTE:

#simp [mul_assoc] c[1, 2, 3]*c[2, 3, 4]

-- QUOTE.
/- TEXT:
Another way to work with concrete groups is to use free groups and group presentations.
The free group on a type ``α`` is ``FreeGroup α`` and the inclusion map is
``FreeGroup.of : α → FreeGroup α``. For instance let us define a type ``S`` with three elements denoted
by ``a``, ``b`` and ``c``,and the element ``ab⁻¹`` of the corresponding free group.
EXAMPLES: -/
-- QUOTE:

section FreeGroup
inductive S | a | b | c

open S

def myElement : FreeGroup S := (.of a) * (.of b)⁻¹


set_option linter.unreachableTactic false in
notation3 (prettyPrint := false) "C["(l", "* => foldr (h t => List.cons h t) List.nil)"]" =>
  Cycle.formPerm (Cycle.ofList l) (Iff.mpr Cycle.nodup_coe_iff (by decide))


-- QUOTE.
/- TEXT:
Note that we gave the expected type of the definition so Lean knows ``.of`` means ``FreeGroup.of``.

The universal property of free groups is embodied as the equivalence ``FreeGroup.lift``.
For instance let us define the group morphism from ``FreeGroup S`` to ``Perm (Fin 5)`` which
sends ``a`` to ``C[1, 2, 3]``, ``b`` to ``C[2, 3, 1]``, and ``c`` to ``C[2, 3]``,
EXAMPLES: -/
-- QUOTE:

def myMorphism : FreeGroup S →* Perm (Fin 5) :=
  FreeGroup.lift fun | .a => C[1, 2, 3]
                     | .b => C[2, 3, 1]
                     | .c => C[2, 3]

-- QUOTE.
/- TEXT:
As a last concrete example, let us see how to define a group generated by a single element whose
cube is one (so that group will be isomorphic to :math:`\mathbb{Z}/3`) and build a morphism
from that group to ``Perm (Fin 5)``.

As a type with exactly one element we will use ``Unit`` whose
only element is denoted by ``()``. The function ``PresentedGroup`` takes a set of relations,
ie. a set of elements of some free group and returns a group which is this free group quotiented
by the normal subgroups generated by relations (we will see how to handle more general quotients
later). Since we somehow hide this behind a definition, we use ``deriving Group`` to force creation
of a group instance on ``myGroup``.
EXAMPLES: -/
-- QUOTE:

def myGroup := PresentedGroup {.of () ^ 3} deriving Group

-- QUOTE.
/- TEXT:
The universal property of presented groups ensures that morphisms out of this group can be built
from function that send the relation to the neutral element of the target group.
So we need such a function and a proof that the condition holds. Then we can feed this proof
to ``PresentedGroup.toGroup`` to get the desired group morphism.
EXAMPLES: -/
-- QUOTE:

def myMap : Unit → Perm (Fin 5)
| () => C[1, 2, 3]

lemma compat_myMap : ∀ r ∈ ({.of () ^ 3} : Set (FreeGroup Unit)), FreeGroup.lift myMap r = 1 := by
  rintro _ rfl
  simp

def myNewMorphism : myGroup →* Perm (Fin 5) := PresentedGroup.toGroup compat_myMap

end FreeGroup

-- QUOTE.
/- TEXT:
Group actions
^^^^^^^^^^^^^

The main way group theory interacts with the rest of mathematics is through group actions.
An action of a group ``G`` on some type ``X`` is nothing but a morphism from ``G`` to
``Equiv.Perm X``. So in a sense they are already covered by the previous discussion.
But we don't want to carry around this morphism everywhere, we want it to be automatically inferred
by Lean as much as possible. So we have a type class for this, which is ``MulAction G X``.
In particular it allows to use ``g • x`` to denote the action of a group element ``g`` on a point
``x``.

EXAMPLES: -/
-- QUOTE:
noncomputable section GroupActions

example {G X : Type*} [Group G] [MulAction G X] (g g': G) (x : X) : g • (g' • x) = (g * g') • x :=
(mul_smul g g' x).symm

-- QUOTE.
/- TEXT:
There is also a version for additive group called ``AddAction``, where the action is denoted by
``+ᵥ``. This is used for instance in the definition of affine spaces.
EXAMPLES: -/
-- QUOTE:
example {G X : Type*} [AddGroup G] [AddAction G X] (g : G) (x : X) : X := g +ᵥ x
-- QUOTE.
/- TEXT:
Also none that nothing so far requires having a group rather than a monoid (or any type endowed
with a multiplication operation really).
The group condition will really enter the picture when we will want to partition ``X`` into orbits.


The downside is that having multiple actions of the same group on the same type requires some
contorsions,such as defining type synonyms carrying different instances.
The underlying group morphism is called ``MulAction.toPermHom``.
EXAMPLES: -/
-- QUOTE:

open MulAction

example {G X : Type*} [Group G] [MulAction G X] : G →* Equiv.Perm X :=
toPermHom G X

-- QUOTE.
/- TEXT:
As an illustration let us see how to define the Cayley isomorphism embedding any group ``G`` into
a permutation group, namely ``Perm G``.
EXAMPLES: -/
-- QUOTE:

def CayleyIsoMorphism (G : Type*) [Group G] : G ≃* (toPermHom G G).range :=
Equiv.Perm.subgroupOfMulAction G G

-- QUOTE.
/- TEXT:
Note also that the corresponding equivalence relation on ``X`` is not declared as a global instance.
It is called ``MulAction.orbitRel``.
EXAMPLES: -/
-- QUOTE:


example {G X : Type*} [Group G] [MulAction G X] : Setoid X := orbitRel G X

-- QUOTE.
/- TEXT:
Using this we can state that ``X`` is partitioned into orbits under the action of ``G``.
More precisely, we get a bijection between ``X`` and the dependent product
``(ω : orbitRel.Quotient G X) × (orbit G (Quotient.out' ω))``
where ``Quotient.out'`` simply choose and element projecting to ``ω``.
Recall that elements of this dependent product are pairs ``⟨ω, x⟩`` where the type
``orbit G (Quotient.out' ω)`` of ``x`` depends on ``ω``.
EXAMPLES: -/
-- QUOTE:

example {G X : Type*} [Group G] [MulAction G X] :
    X ≃ (ω : orbitRel.Quotient G X) × (orbit G (Quotient.out' ω)) :=
  MulAction.selfEquivSigmaOrbits G X

-- QUOTE.
/- TEXT:
In praticular, when X is finite, this can be combined with ``Fintype.card_congr`` and
``Fintype.card_sigma`` to deduce that the cardinal of ``X`` is the sum of the cardinals
of orbits.
Furthermore, orbits are in bijection with the quotient of ``G`` under the action of the
stabilizers by left translation.
This action of a subgroup by left-translation to define quotients of a group by a subgroup
with notation `/` so we can the following concise statement.
EXAMPLES: -/
-- QUOTE:

example {G X : Type*} [Group G] [MulAction G X] (x : X) :
    orbit G x ≃ G ⧸ stabilizer G x :=
  MulAction.orbitEquivQuotientStabilizer G x

-- QUOTE.
/- TEXT:
An important special case of combining the above two results is when ``X`` is a group ``G``
equipped with the action of a subgroup ``H`` by translation.
In this case all stabilizers are trivial so every orbit is in bijection with ``H`` and we get
EXAMPLES: -/
-- QUOTE:

example {G : Type*} [Group G] (H : Subgroup G) : G ≃ (G ⧸ H) × H :=
  groupEquivQuotientProdSubgroup
-- QUOTE.
/- TEXT:
which is the conceptual version of Lagrange theorem that we saw above.
Note this version makes no finiteness assumption.
EXAMPLES: -/
-- QUOTE:
end GroupActions


-- QUOTE.
/- TEXT:
Quotient groups
^^^^^^^^^^^^^^^

In the above discussion of subgroups acting on groups, we saw the quotient ``G⧸H`` appear.
In general this is only a type. It can be endowed with a group structure such that the quotient
map is a group morphism if and only if ``H`` is a normal subgroup (and this group structure is
then unique).

The normality assumption is a type class ``Subgroup.Normal`` so that type class inference can use to
derive the group structure on the quotient.
EXAMPLES: -/
-- QUOTE:
noncomputable section QuotientGroup

example {G : Type*} [Group G] (H : Subgroup G) [H.Normal] : Group (G ⧸ H) := inferInstance


example {G : Type*} [Group G] (H : Subgroup G) [H.Normal] : G →* G ⧸ H :=
QuotientGroup.mk' H

-- QUOTE.
/- TEXT:
The universal property of quotient groups is accessed through ``QuotientGroup.lift``:
a group morphism ``φ`` descends to ``G ⧸ N`` as soon as its kernel contains ``N``.
EXAMPLES: -/
-- QUOTE:

example {G : Type*} [Group G] (N : Subgroup G) [N.Normal] {M : Type*}
  [Group M] (φ : G →* M) (h : N ≤ MonoidHom.ker φ) : G ⧸ N →* M :=
QuotientGroup.lift N φ h

-- QUOTE.
/- TEXT:
The fact that the target group is called ``M`` is the above snippet is a clue that having a
monoid structure on ``M`` would be enough.

An important special case is when ``N = ker φ`` In that case the descended morphism is
injective and we get a group isomorphism onto its image. This result is often called
the first isomorphism theorem.
EXAMPLES: -/
-- QUOTE:
example {G : Type*} [Group G] {M : Type*} [Group M] (φ : G →* M) :
    G ⧸ MonoidHom.ker φ →* MonoidHom.range φ :=
  QuotientGroup.quotientKerEquivRange φ

-- QUOTE.
/- TEXT:
Applying the universal property to a composition of a morphism ``φ : G →* G'``
with a quotient group projection ``Quotient.mk' N'``,
we can also aim for a morphism from ``G ⧸ N`` to ``G' ⧸ N'``.
The condition required on ``φ`` is usually formulated as "``φ`` should send ``N`` inside
``N'``". But this is equivalent to asking that ``φ`` should pull ``N'`` back inside
``N``, and the later condition is nicer to work with since the definition of pull-back does not
involve an existential quantifier.
EXAMPLES: -/
-- QUOTE:

example {G G': Type*} [Group G] [Group G']
    {N : Subgroup G} [N.Normal] {N' : Subgroup G'} [N'.Normal]
    {φ : G →* G'} (h : N ≤ Subgroup.comap φ N') : G ⧸ N →* G'⧸ N':=
  QuotientGroup.map N N' φ h

end QuotientGroup

-- QUOTE.
/- **TODO:**

rings, mph, subring
ideals, quotients
Restes chinois
polynomials?
-/