(** %\chapter{Functional Programming in Coq}% *)

(** 

We start our short journey with observing the capabilities of Coq as
a programming language. 

Coq is often described as a functional programming language, since its
programs are always pure, possibly higher-order functions, which means
that they might take other functions as parameters and return
functions as results. Similarly to other functional programming
languages, such as Haskell, OCaml or Scala, Coq makes heavy use of
algebraic datatypes, represented by a number of possibly recursive
constructors. 

Very soon, we will see how _programming_ with inductive algebraic
datatypes incorporates _reasoning_ about them, but for now let us take
a short tour of Coq's syntax and define a couple of simple programs.

*)

(** * Enumeration datatypes *)

(** 

The simplest datatype once can imagine is [unit], a type
inhabited by exactly one element. In Coq, one can define such a type
in the following manner: 

*)

Inductive unit : Set := tt.

(** 
 
The definition above postulates the type [unit] that has _exactly_ one
constructor, namely, [tt]. In the type theory jargon, which we will
adopt, it is said that the expression [tt] _inhabits_ the [unit]
type. Naturally, it is the only inhabitant of the set, corresponding
to the [unit] type. We can now check the [tt]'s affiliation via the
[Check] command:

*)

Check tt.

(**
Moreover, we can make sure that the [unit] datatype itself defines a set:
*)

Check unit.

(**

In fact, since Coq makes the analogy between sets and types so
transparent, it is not difficult to define a type, describing the
_empty_ set:

*)

Inductive empty : Set := .

(**

That is the empty set is precisely described by the type, values of
which we simply _cannot construct_, as the type itself does _not_
provide any constructors! 
In fact, this observation about inhabitance of types/sets and the
definition of an empty type will come in quite handy very soon when we
will be talking about the truth and falsehood in the setting of
Curry-Howard correspondence.
Unfortunately, at this moment there is not so much we can do with such simple types as [unit] or
[empty], so we proceed by defining some more interesting datatypes.

The type [bool] is familiar to every programmer. In Coq, it is
unsurprisingly defined by providing exactly two constructors: [true]
and [false]. Since [bool] is already provided by the standard
Coq/SSReflect library, we do not need to define it ourselves. Instead,
we include the following modules into our file using the [Require
Import] keywords:

*)

Require Import ssreflect ssrbool.

(** Now, we can inspect the definition of the [bool] type by simply
printing it: *)

Print bool.
(** [Inductive bool : Set :=  true : bool | false : bool] *)

(** 

Let us now try to define some functions that operate with the bool
datatype ignoring for a moment the fact that most of them, if not all,
are already defined in the standard Coq/SSReflect library.  Our first
function will simply negate the boolean value and return its opposite:

*)

Definition negate b := 
  match b with 
  | true  => false
  | false => true
  end.

(**

The syntax of Coq as programming language is very similar to Standard
ML. The keyword [Definition] us used to define non-recursive values,
including functions. In the example above, we defined a function with
one argument [b], which is being scrutinized agains two possibles
value patterns ([true] and [false]), respectively, and the results are
returned. Notice that thanks to its very powerful type inference
algorithm, Coq didn't require us to annotate neither the argument [b]
with its type, nor the function itself with its result type: these
types were soundly inferred, which might be confirmed by checking the
overall type of [negate], which states that it is a function from
[bool] to [bool]:

*)

Check negate.
(**
[negate : bool -> bool
]

* Simple recursive datatypes and programs

At this point we have seen only very simple forms of inductive types,
such that all their inhabitants are explicitly enumerated (e.g.,
[unit] and [bool]). The next type used ubiquitously in the
computations and mathematical reasoning are natural numbers, the first
_truly_ inductive datatype. Following the Peano axioms the type [nat]
natural numbers are defined by induction, i.e., via the following two
constructors: *)

Print nat.

(**
[Inductive nat : Set :=  O : nat | S : nat -> nat]

The definition of the type [nat] is _recursive_.  It postulates that
[O] is a natural number (hence, the first constructor), and, if [n] is
a natural number then [S n] is a natural number as well (hence, the
name [S], which is a shortcut for _successor_). At this point, the
reader can recall the notion of _mathematical induction_, usually
introduced in school and postulating that if a statement [P] has to be
proven to hold over all natural numbers, it should be proven to hold
on zero _and_ if it holds for [n], then it should hold for [n +
1]. The very same principle is put into the definition of the natural
numbers themselves. In the future, we will see many other interesting
data structures going far beyond natural numbers and each equipped
with its own _induction principle_.  Moreover, quite soon we will see
that in Coq recursive definitions/computations and inductive proofs
are in fact two sides of the same coin.

For now, let us write some functions dealing with natural numbers.  In
order to work conveniently with naturals, we will import yet another
SSReflect library: *)

Require Import ssrnat.

(** 

Probably, the most basic function working on natural numbers is their
addition. Even though such function is already implemented in the vast
majority of the programming languages (including Coq), let us do it
from scratch using the definition of [nat] from above. Since [nat] is a
recursive type, the addition of two natural numbers [n] and [m] should
be defined recursively as well. In Coq, recursive functions are
defined via the keyword [Fixpoint]. In the following definition of the
[my_plus] function, we will make use of SSReflect's infix notation
[.+1] (with no spaces between the characters) as an alternative to the
standard [nat]'s recursive constructor [S].  Also, Coq provides a
convenient notation [0] to the _zero_ constructor [O].

*)

Fixpoint my_plus n m := 
 match n with 
 | 0     => m   
 | n'.+1 => let: tmp := my_plus n' m in tmp.+1
 end.

(** 

Here, we deliberately used less concise notation in order to
demonstrate the syntax [let: x := e1 in e2] construct, which,
similarly to Haskell and OCaml allows, one to bind intermediate
computations within expressions.%\footnote{The same example also
demonstrates the use of SSReflect alternative to Coq's standard
\texttt{let} command, not trailed with a colon. We will be making use
of SSReflect's \texttt{let:} consistently, as it provides additional
benefits with respect to in-place pattern matchin, which we will show
further.}% The function [my_plus] is recursive on its _first_
argument, which is being decreased in the body, so [n'] is a
predecessor of [n] is passed to the recursive call. We can now check
the result of evaluation of [my_plus] via Coq's [Eval compute in]
command:%\footnote{The command in evaluation might look a bit verbose
in this form, but it is only because of its great flexibility, as it
allows for different evaluation strategies. In this case we employed
\texttt{compute}, as it performs all possible reductions.}%

*)

Eval compute in my_plus 5 7. 
(** 
[ = 12 : nat] 

The same function could be written quite a bit shorter via SSReflect's
pattern-matching [if-is]-notation, which is a convenient alternative
to pattern matching with only two alternatives:

*)

Fixpoint my_plus' n m := if n is n'.+1 then (my_plus n' m).+1 else m.

(**

At this point, the reader might have an impression that the
computational language of Coq is the same as of OCaml and Haskell, so
all usual tricks from the functional programming might be directly
applicable. Unfortunately, it is not so, and the main difference
between Coq and other general-purpose programming languages stems from
the way it treats recursion. For instance, let us try to define the
following "buggy" addition function, which goes into an infinite
recursion instead of producing the value, due to the fact that the
recursion argument is not decreasing and remains to be [n]:

[Fixpoint my_plus_buggy n m := if n is n'.+1 then (my_plus_buggy n m).+1 else m.]

we immediately get the following error out of the Coq interpreter:

[Error: Cannot guess decreasing argument of fix.]

This is due to the fact that the recursion in [my_plus_buggy] is not
_primitive_: that is there is a recursive call, whose argument is not
"smaller" comparing to the initial function's argument, which makes
this procedure to fall into a larger class of _generally recursive_
programs. Unlike primitively-recursive programs, generally-recursive
programs may not terminate or terminate only on a subset of their
inputs, and checking termination statically in general is an
undecidable problem (that is, such checking will not terminate by
itself, which is known under the name of Turing's _halting
problem_).%\footnote{The computability properties of primitively and
generally recursive functions is a large topic, which is essentially
orthogonal to our development, so we omit a detailed discussion on the
theory of recursion and address an interested reader to the literature~\cite{???}}%

The check for primitive recursion, which implies termination, is
performed by Coq _syntactically_, and the system makes sure that there
is least one argument of an inductively-defined datatype, which is
being consistently decreased at each function call. This criteria is
sufficient to insure the termination of all functions in Coq. Of
course, such termination check is a severe restriction to the
computation power of Coq, which therefore is not Turing-complete as a
programming language (as it supports only primitive recursion).

Although Coq is equipped with a number of machinery to _reason_ about
potentially non-terminating programs and prove some useful facts about
them%\footnote{Typically, this is done by supplying a user-specific
termination argument, which "strictly reduces" at each function call,
or defining a function, so it would take a \emph{co-inductive}
datatype as its argument.}% (for example, Chapter 7 of Adam Chlipala's
book%~\cite{Chlipala:BOOK}% provides a broad overview of methods to
encode potentially non-terminating programs in Coq and reason about
them), it usually requires some ingenuity to execute
generally-recursive computations withit Coq. Fortunately, even
without the possibility to _execute_ any possible program in the
system, Coq provides a reach tool-set to _encode_ such programs, so a
number of statements could be proved about them, and the encoded
programs themselves could be later _extracted_ into a general-purpose
language, such as Haskell or OCaml in order to be executed
(see%~\cite[Chapter 10]{Bertot-Casteran:BOOK}% for detailed
description of the extraction).

So, why ensuring termination in Coq is so important? The reason for
this will be better understood once we introduce the way Coq works
with logical statements and propositions. For now, it should be enough
to accept the fact that in order to ensure the logical calculus
underlying Coq sound, all values in it (even possibly infinite,
e.g., streams defined co-inductively) should be computable in a
finite number of steps. A bit further we will see that the proofs of
propositions in Coq are just ordinary values in its computational
language, and the construction of the proofs naturally should
terminate, hence computation of _any_ value in Coq should terminate,
since each value can be involved into a proof of some statement.

Postponing the discussion on the nature of propositions and proofs in
Coq, we will continue our overview of programming principles in Coq.

With the example of the addition function, we have already seen how
the recursive functions are defined. However, using the [Fixpoint]
command is not the only way to provide definitions to functions
similar to [my_plus]. When defining the types [unit] or [empty], we
could have noticed the following output produced by the interactive
interpreter:
[[
unit is defined
unit_rect is defined
unit_ind is defined
unit_rec is defined
]]
These three lines indicate that along with the new datatype ([unit] in
this case) three additional entities have been generated by the
system. These are the companion _induction_ and _recursion_
principles, which are named using the simple convention basing on the
name of the datatype. For example, the [nat] datatype comes
accompanied by [nat_rect], [nat_ind] and [nat_rec], correspondingly.

Continuing playing with natural numbers and leaving the [nat_rect] and
[nat_ind] aside for a moment, we focus on the recursion primitive
[nat_rec], which is a _higher-order_ function with the following type:

*)

Check nat_rec.
(** 
[[
nat_rec : forall P : nat -> Set,
          P 0 -> (forall n : nat, P n -> P n.+1) -> forall n : nat, P n
]]

The type of [nat_rec] requires a bit of explanation. It is a
polymorphic in the sense of Haskell and OCaml (i.e., it is parametrize
over another type). More precisely, its first parameter, bound by the
[forall] quantifier is a function, which maps natural numbers to types
(hence the typo if this parameter is [nat -> Set]). The second
parameter is a result of type described by application of the function
[P] to zero. The third parameter is a _family_ of functions, indexed
by a natural number [n]. Each function from such a family takes an
argument of type [P n] and returns a result of type [P n.+1]. The
default recursion principle for natural numbers is therefore a
higher-order function (i.e., a combinator). If the three discussed
arguments are provided, the result of [nat_rec] will be a function,
mapping a natural number [n] to a value of type [P n].

To see how [nat_rec] is implemented, let us explore its generalized
version, [nat_rect]:

*)

Print nat_rect.
(** 
[[
nat_rect = 
fun (P : nat -> Type) (f : P 0) (f0 : forall n : nat, P n -> P n.+1) =>
fix F (n : nat) : P n :=
  match n as n0 return (P n0) with
  | 0 => f
  | n0.+1 => f0 n0 (F n0)
  end
     : forall P : nat -> Type,
       P 0 -> (forall n : nat, P n -> P n.+1) -> forall n : nat, P n
]]

Abstracting away from the details, we can see that [nat_rect] is
indeed a function with three parameters (the keyword [fun] is similar
the lambda notation and is common in the family of ML-like languages).
The body of [nat_rect] is implemented as a recursive function (defined
via the keyword [fix]) taking an argument [n] of type
[nat]. Internally, it proceeds similarly to our implementation of
[my_plus]: if the argument [n] is zero, then the "default" value [f] of
type [P 0] is returned. Otherwise, the function proceeds recursively
with a smaller argument [n0] by applying the "step" function [f0] to
the [n0] and the result of recursive call [F n0].

Therefore, the summing function can be implemented via the [nat]'s
recursion combinator as follows:
*)

Definition my_plus1 n m := nat_rec (fun _ => nat) m (fun n' m' => m'.+1) n.

Eval compute in my_plus1 16 12.

(** 
[  = 28 : (fun _ : nat => nat) 16]

The result of invoking [my_plus1] is expectable. Notice, however, that
when defining it we didn't have to use the keyword [Fixpoint] (or,
equivalently, [fix]), since all recursion has been "sealed" within the
definition of the combinator [nat_rect].

** Dependent function types and pattern matching

An important thing to notice is the fact that the type of [P] in the
definition of [nat_rec] is a function that maps _values_ of type [nat]
into arbitrary types. This gives us a possibility to define
_dependently-typed_ functions, whose return type depends on their
input argument value. A simple example of such a function is below:

*)

Definition three_to_unit n := 
 let: P := (fun n => if n is 3 then unit else nat) in
 nat_rec P 0 (fun n' _ => match n' return P n'.+1 with
               | 2 => tt
               | _ => n'.+1
               end) n.

Eval compute in three_to_unit 0.
(** [  = 0 : nat] *)
Eval compute in three_to_unit 5.
(** [  = 5 : nat] *)
Eval compute in three_to_unit 3.
(** [  = tt : unit] *)

(** 

The toy function [three_to_unit] maps every natural number to itself
except for [3], which is being mapped into the value [tt] of type
[unit]. We define it via the [nat_rec] combinator by providing it a
function [P], which defines the type contract described just above.
Importantly, as the first parameter.  The "step" function, which is a
third parameter, of this [nat_rec] call, makes use of the _dependent_
pattern matching, which now specifies explicit return type [P (n'.+1)]
of the whole [match e with ps end] expression. This small addition
allows the Coq type checker to relate the expected type of the final
result [P n] to the result of the pattern matching expression. Without
the explicit [return] in the pattern matching, in some cases when its
result type depends on the value of the scrutinee, the Coq type
checking engine will fail to unify the type of the branch and the
overall type.%\footnote{However, in this example Coq 8.4 does just
fine even without the explicit \texttt{return} annotation in the
[match]-expression, we nevertheless presented it to outline the
possible problem.}%

In general, dependent pattern matching is quite powerful tool, which,
however, should be used with a great caution, as it makes assisting
Coq type checker to be a rather non-trivial task. In the was majority
of the cases dependent pattern matching can be avoided. We address the
curious reader to the Chapter 8 of Adam Chlipala's book for more
examples on the subject%~\cite{Chlipala:BOOK}%.

Dependent function types, akin to those of [nat_rec] and our
[three_to_unit], which allow the type of the result to vary depending
on the value of a function's argument are a powerful way to specify
the behaviour of functions, and therefore, are often used to "certify"
the dependently-typed programs. In Coq, dependent function types are
omnipresent, and are syntactically specified using the
[forall]-binder, similarly to the way _parametric_ types are specified
in Haskell or type calculi like polymorphic lambda calculus (also
known as System F%~\cite{Reynolds:SP74,Girard:PhD}%). The crucial
difference beween Coq's core calculus and System F is that in Coq the
types can be parametrised not just by _types_ but also by
_values_. While the utility of this language "feature" can be already
demonstrated for constructing and type-checking _programs_ (for
example, [three_to_unit]), its true strength is best demonstrated when
using Coq as a system to construct _proofs_, which is the topic of the
subsequents chapters.

** Recursion principle and non-inhabited types

Automatically-generated recursion principles for inductively-defined
datatypes provide a generic (although not universal) scheme to define
recursive functions for the corresponding values. But what if a type
is not inhabited, i.e., there are no values in it. We have already
seen such a type---it's [empty], which defined the empty set. As any
inductive datatype in Coq, it comes with an automatically generated
generalized recursion principle, so let us check its type: *)

Check empty_rect.

(** 
[[
empty_rect
     : forall (P : empty -> Type) (e : empty), P e
]]

Very curiously, the type signature of [empty_rec] postulates that it
is sufficient to provide a function from [empty] to any type (which
can very well be just a constant type, e.g., nat), and an argument [e]
of type [empty], so the result of the call to [empty_ret] will bee of
type [P e]. More concisely, empty_rect allows us to produce a result
of _any_ type, given that we can provide an argument of type
[empty]. While it might sound very surprising at the first moment,
upon some reflection it seems like a perfectly valid principle, since
we will _never_ be able to construct the required value of type
[empty] on the first place. In more fancy words, such recursion
principle can be reformulated as the following postulate:

%
\begin{center}

Assuming existence of a value, which \emph{cannot be constructed},\\
we will be able to construct \emph{anything}.

\end{center}
%

This is a very important insight, which will become illuminating when
we will be discussing reasoning with negation in the next chapter.

To conclude this section, we only mention that defining a datatype
with no constructors is not the only way to get a type, which is not
inhabited. For example, the following type
[strange]%~\cite{Bertot-Casteran:BOOK}% has a constructor, which,
however, can never be invoked, as it requires a value of it type
itself in order to return a value: *)

Inductive strange : Set :=  cs : strange -> strange.

(** 

Therefore, an attempt to create a value of type [strange] by invoking
its single constructor will inevitably lead to an infinie,
non-terminating, series of constructor calls, and such programs cannon
be encoded in Coq. It is interesting to take a look at the recursion
principle of [strange]:

*)

Check strange_rect.

(** 
[[
strange_rect
     : forall P : strange -> Type,
       (forall s : strange, P s -> P (cs s)) -> forall s : strange, P s
]]

That is, if we pose the argument [P] to be a constant type function
[fun _ => empty], and the second argument to be just an identity
function [(fun _ x => x)] that maps its second argument to itself, we
will get a function that, upon receiving argument of type [strange]
will construct an argument of type [empty]! More precisely, the
existence of a value of type [strange] would allow us to create a
value of type [empty] and, therefore a value of _any_ type, as was
previously demonstrated. 

To summarize, designing a datatype, which is not inhabited, while not
trivial, is not impossible, and it is a task of a designer of the type
to make sure that its values in fact can be constructed.

*)

(** * More datatypes 

While programming with natural numbers is fun, it is time for us to
take a brief look at other datatypes familiar from functional
programming, as they appear in Coq.


The type of pairs is parametrized by two arbitrary types [A] and
[B] (by now let us think of its sort [Type] as of a generalization of
a generalization of [Set], which we have seen before). As in Haskell
or OCaml, [prod] can also be seen as a type-level constructor with two
parameters that can be possibly curried:
*)

Check prod.
(**
[ prod : Type -> Type -> Type]

Pairs in Coq are defined as a higher-order datatype [prod] with just
one constructor [pair]:

*)
Print prod.
(** 
[[
Inductive prod (A B : Type) : Type :=  pair : A -> B -> A * B

For pair: Arguments A, B are implicit and maximally inserted
For prod: Argument scopes are [type_scope type_scope]
For pair: Argument scopes are [type_scope type_scope _ _]
]]

The display above, besides showing how [prod] is defined, specifies
that the type arguments of [prod] are _implicit_, in the sense that
they will be inferred by the type-checker when enough information is
provided, e.g., the arguments of the constructor [pair] are
instantiated with particular values. For instance, type arguments can
be omitted in the following expression: *)

Check pair 1 tt.

(** 
[ (1, tt) : nat * unit]

If one wants to explicitly specify the type arguments of a
constructor, the [@]-prefixed notation can be used:

*)

Check @pair nat unit 1 tt.

(** 
[ (1, tt) : nat * unit]

Notice that the parameters of the datatype come first in the order
they are declared, followed by the arguments of the constructor (often
also referred to as _indices_).

The last two lines following the definition of [prod] specify that the
notation for pairs is overloaded (in particular, the "[_ * _]"
notation is also used by Coq to denote the multiplication of natural
numbers), so it is given a specific _interpretation scope_. That is,
when the expression [nat * unit] will appear in the type position, it
will be interpreted as a type [pair nat unit] rather than like an
(erroneous) attempt to "multiply" two types as they were integers. 

Coq comes with a number of functions for manipulating datatypes, such
as pair. For instance, the first and second components of a pair:
*)

Check fst.
(**
[fst : forall A B : Type, A * B -> A]
*)

Check snd.
(**
[fst : forall A B : Type, A * B -> A]

Curiously, the notation "[_ * _]" is not hard-coded into Coq, but
rather is defined as a lightweight syntactic sugar on top of standard
Coq syntax. Very soon we will see how one can easily extend Coq's
syntax by defining their own notations. We will also see how is it
possible to find what a particular notation means.

The arsenal of a functional programmer in Coq would be incomplete
without proper sum and list datatypes:
*)

Print sum.
(**
[Inductive sum (A B : Type) : Type :=  inl : A -> A + B | inr : B -> A + B]
*)

Print list.

(** 
[Inductive list (A : Type) : Type := nil : list A | cons : A -> list A -> list A]
*)

(** * Searching for definitions and notations

Of course, we could keep enumerating datatypes and operations on them
from the standard Coq/SSReflect library (which is quite large), but
it's always better for a starting Coq hacker to have a way to find
necessary definitions on her own. Fortunately, Coq provides a very
powerful search tool, whose capabilities are greatly amplified by
SSReflect. Its use is better demonstrated by examples.

*)

Search "filt".
(** 
[[
List.filter  forall A : Type, (A -> bool) -> list A -> list A
List.filter_In
   forall (A : Type) (f : A -> bool) (x : A) (l : list A),
   List.In x (List.filter f l) <-> List.In x l /\ f x = true
]]
*)

Search "filt" (_ -> list _).
(** 
[[
List.filter  forall A : Type, (A -> bool) -> list A -> list A
]]

That is, the first [Search] query just takes a string and looks for
definitions of functions and propositions that have it as a part of
their name. The second pattern elaborates the first by adding a
requirement that the type of the function should include [(_ -> list
_)] as a part of its return type, which narrows the search scope. As usual the
underscores [_] denote a wildcard in the pattern and can be used both
in the name or type component. Moreover, one can use named patterns of
the form [?id] to bind free identifiers in the sub-types of a sought
expression. For instance, the next query will list all function with
map-like types (notice how the higher-order constructor types are
abstracted over using wildcards):
*)

Search _ ((?X -> ?Y) -> _ ?X -> _ ?Y).
(**
[[
option_map  forall A B : Type, (A -> B) -> option A -> option B
List.map  forall A B : Type, (A -> B) -> list A -> list B
...
]]

If necessary, the type patterns in the query can have their types
explicitly specified in order to avoid ambiguities due to notation
overloading. For instance, the following search will return all
functions and propositions that make use of the [_ * _] notation and
operate with natural numbers: *)

Search _ (_ * _ : nat).

(** 

In contrast, the next query will only list the functions/propositions,
where [_ * _] is treated as a notation for the pair datatype
(including [fst] and [snd], which we have already seen):

*)

Search _ (_ * _: Type).

(**

A detailed explanation of the syntax of [Search] tool as well as
additional examples can be found in Chapter 10 of SSReflect
documentation%~\cite{Gontier-al:TR}%.

When working with someone's Coq development, sometimes it might be not
entirely obvious what particular notation means: Coq's extensible
parser is very simple to abuse by defining completely intractable
abbreviations, which might say a lot to the library developer, but not
to its client. Coq provide the [Locate] to help in demystifying
notations as well as locating the position of particular definitions.
For example, the following query will show all the definitions of the
notation "[_ + _]" as well as the scopes they defined in.

*)

Locate "_ + _".

(** 
[[
Notation            Scope     
"x + y" := sum x y   : type_scope
                      
"m + n" := addn m n  : nat_scope
                      (default interpretation)
...
]]

We can see now that the plsu-notation is used in particular for the
addition of natural numbers (in [nat_scope]) and the declaration of a
sum type (in [type_scope]). Similarly to the notations, the [Locate]
command can help finding the definition in the source modules they
defined:%\footnote{The module system of Coq is similar to OCaml and
will be discussed further in this chapter.}% *)

Locate map.

(**
[[
Constant Coq.Lists.List.map
  (shorter name to refer to it in current context is List.map)
Constant Ssreflect.ssrfun.Option.map
  (shorter name to refer to it in current context is ssrfun.Option.map)
...
]]
*)

(** * An alternative syntax to define inductive datatypes

In the previous sections of this chapter we have already seen the way
inductive datatypes are defined in the setting "traditional"
Coq. These are the definitions that will be displayed when using the
[Print] utility. However, in the rest of the development in this book,
we will be using a version of Coq, enhanced with the SSReflect tool,
which, in particular, provides more concise notation for defining
constructors. For instance, as an alternative to the standard
definition of the product datatype, we can define our own product in the following way:

*)

Inductive my_prod (A B : Type) : Type :=  my_pair of A & B.

(** 

Notice that [A] and [B] are type parameters of the whole datatype as
well as of its single constructor [my_pair], which _additionally_
required two value arguments, _whose_ types are [A] and [B],
respectively. 

Next, let us try to create a value of type [my_prod nat unit] and
check its type.  

[[
Check my_pair 1 tt.

Error: The term "1" has type "nat" while it is expected to have type "Type".
]]

The error message is cause by the fact that the constructor has
expected the type parameters to be provided _explicitly_ first, so the
value above should in fact has been created by calling [my_pair nat
unit 1 tt]. Since mentioning types every time is tedious, we can now
take advantage of Coq's elaboration algorithm, which is capable to
infer them from the values of actual arguments (e.g., [1] and [tt]),
and declare [my_pair]'s type arguments as implicit:
*)

Implicit Arguments my_pair [A B].

(**

We have already witnessed standard Coq's datatypes making use of
specific user-defined notations. Let us define such notation for the
type [my_prod] and its [my_pair] constructor.
 *)

Notation "X ** Y" := (my_prod X Y) (at level 2).
Notation "( X ,, Y )" := (my_pair X Y).

(** 

The [level] part in the first notation definition is mandatory for
potentially left-recursive notations, which is the case here, in order
to set up parsing priorities with respect to other notations.

With these freshly defined notations we are now free to write the
following expressions:

*)

Check (1 ,, 3).

(** 
[[
(1,, 3)
     : nat ** nat
]]

*)
Check nat ** unit ** nat.

(** 
[[
(nat ** unit) ** nat
     : Set
]]

Notice that the notation "[_ ** _]" for [my_pair] by default is set to
be left-associative. The other associativity should be declared
explicitly, and we address the reader to the Chapter 12 of Coq
manual%~\cite{Coq-manual}% for the details of the [Notation] command
syntax.


 * Sections and modules

We conclude this chapter by a very brief overview of Coq's module
system.

Sections are the simplest way to structure the programs in Coq. In
particular, sections allow the programmer to limit the scope of
packages imported to the current file (each compiled [*.v] file in the
scope of the interpreter is considered as a package), as well as to
defined _locally-scoped_ variables. To see how it works, let us
construct a section containing an utility function for natural
numbers.  Declaring a section starts from the keyword [Section],
followed by the name of the section:

 *)

Section NatUtilSection.

(** 

We not define a _variable_ [n] of type [n], whose scope is lexically
limited by the section [NatUtilSection] (including its internal
sections). One can think of variables declared this way as of
unspecified values, which we assume to be available outside of the
section.

*)

Variable n: nat.

(** 

We can now define a function, implementing a multiplication of natural
numbers by mean of addition. For this we assume the variable [n] to be
fixed, so the multiplication can be formulated just as a function of
_one_ parameter:

*)

Fixpoint my_mult m := match (n, m) with
 | (0, _) => 0
 | (_, 0) => 0
 | (_, m'.+1) => my_plus (my_mult m') n
 end. 

(** 

We now close the section by using the [End] keyword.

*)

End NatUtilSection.

(** 

Unlike Haskell or Java's modules, sections in Coq are transparent:
their internal definitions is visible outside of their bodies, and the
definitions' names need not be qualified. The same _does not_ apply to
sections' variables. Instead, they become _parameters_ of definitions
they happened to be used in. This can be seen by printing the
implementation of [my_mult] outside of the section [NatUtilSection].

*)

Print my_mult.

(** 

[[
my_mult = 
fun n : nat =>
fix my_mult (m : nat) : nat :=
  let (n0, y) := (n, m) in
  match n0 with
  | 0 => 0
  | _.+1 => match y with
            | 0 => 0
            | m'.+1 => my_plus (my_mult m') n
            end
  end
     : nat -> nat -> nat
]]

We can see now that the variable [n] became an actual parameter of
[my_mult], so the function now takes _two_ parameters, just as
expected.

An alternative to sections in Coq, which provides better
encapsulation, are _modules_. A module, similarly to a section, can
contain locally-declared variables, sections and modules (but not
modules within sections!). However, the internals of a module are not
implicitly exposed to the outside, instead they should be exported
explicitly by means of putting them into a submodule and via the
command [Export], just as demonstrated below:

*)

Module NatUtilModule.

Fixpoint my_fact n :=
  if n is n'.+1 then my_mult n (my_fact n') else 1.

Module ToExport.
Definition fact := my_fact.
End ToExport.

End NatUtilModule.

(**

The submodule [ToExport] creates a synonym [fact] for the function
[my_fact], defined outside of it. The following command explicitly
exports all internals of the module [NatUtilModule.ToExport],
therefore making [fact] visible outside of [NatUtilModule].

 *)

Export NatUtilModule.ToExport.

(** 
[[
Check my_fact.

Error: The reference my_fact was not found in the current environment.
]]
*)

Check fact.

(**
[[
fact
     : nat -> nat
]]
*)


