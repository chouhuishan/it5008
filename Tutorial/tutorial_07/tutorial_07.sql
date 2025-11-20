-- R with a set of functional dependencies ➡️ R with Σ
-- Trivial dependencies : σ : X → Y, if and only if Y ⊆ X
--      Set X uniquely determines its subset X
-- Completely non-trivial : σ : X → Y, if and only if Y ≠ ∅ and Y ∩ X = ∅
--      No common attributes
;
-- S is superkey of R, if and only if S → R ➡️ S ⊆ R
--      A superkey is a superkey of a key.
-- S is a candidate key of R, if and only if S → R ➡️ S ⊆ R
--      For all T ⊂ S, T is not a superkey of R.
;
-- R = {A, B, C, D, E, F , G, H}
-- Σ = { 
--     {A} → {C, E}, 
--     {A, B} → {D}, 
--     {F} → {H}, 
--     {C, E} → {A}, 
--     {B, C, E} → {D},
--     {A, B, F} → {D, G},
--     {B, C, E, F} → {G} 
--     }
;
-- 1. Functional Dependencies.
-- (a) From the functional dependencies in Σ and the text description of the application, can
-- you figure out the mapping of the attributes and the letters?
;
-- (b) Compute the attribute closures of the subset of attributes of R with Σ in order to find
-- the candidate keys of R with Σ.
--      Look for attributes that do not appear at the RHS ➡️ B, F
-- {B, F}+ = {B, F, H}
-- Set of 3 attributes superset of {B, F} : Add the remaining key into B, F
-- {A, B, F}+ = {A, B, C, D, E, F, G, H} ➡️ Candidate key found!
-- {B, C, F}+ = {B, C, F, H}
-- {B, D, F}+ = {B, D, F, H}
-- {B, E, F}+ = {B, E, F, H}
-- {B, F, G}+ = {B, E, F, H}
-- {B, F, H}+ = {B, F, H}
;
-- Set of 4 attributes superset of {B, F} : Add the remaining key into B, F except A
-- {B, C, D, F}+ = {B, C, D, F, H}
-- {B, C, E, F}+ = {A, B, C, D, E, F, G, H} ➡️ Candidate key found!
-- {B, C, F, G}+ = {B, C, F, G, H}
-- {B, C, F, H}+ = {B, C, F, H}
-- {B, D, E, F}+ = {B, D, E, F, H}
-- {B, D, F, G}+ = {B, D, F, G, H}
-- {B, D, F, H}+ = {B, D, F, H}
-- {B, E, F, G}+ = {B, E, F, G, H}
-- {B, E, F, H}+ = {B, E, F, H}
-- {B, F, G, H}+ = {B, F, G, H}
;
-- ANS: {A, B, F}+ and {B, C, E, F}+
-- NOTE: Attributes closures >= 5 do not make candidate keys
;
-- (c) Find the prime attributes of R with Σ.
-- Prime attributes: {A, B, F} ∪ {B, C, E, F} = {A, B, C, E, F}
-- Prime attributes = UNION of candidate key❗️❗️❗️❗️❗️
;
-- 2. Minimal Cover.
-- (a) Compute a minimal cover of R with Σ
--     1. Simplify the RHS
--          {A} → {C},
--          {A} → {E},
--          {A, B} → {D}, 
--          {F} → {H}, 
--          {C, E} → {A}, 
--          {B, C, E} → {D},
--          {A, B, F} → {D},
--          {A, B, F} → {G},
--          {B, C, E, F} → {G}
;
;
--     2. Simplify the LHS
--          {A} → {C},
--          {A} → {E},
--          {A, B} → {D}, 
--          {F} → {H}, 
--          {C, E} → {A}, 
--          {B, C, E} → {D},
--          {A, B, F} → {D}, ❌ since {A, B} → {D}
--          {A, B, F} → {G},
--          {B, C, E, F} → {G}
;
;
--     3. Simplify the set
--          {A} → {C},
--          {A} → {E}, 
--          {F} → {H}, 
--          {C, E} → {A}, 
--          {B, C, E} → {D},
--          {A, B} → {D}
--          {A, B, F} → {G},
--          {B, C, E, F} → {G}
;
-- Possible ANS: {A} → {C}, {A} → {E}, {F} → {H}, {C, E} → {A}, {B, C, E} → {D}, {B, C, E, F} → {G}
-- Possible ANS: {A} → {C}, {A} → {E}, {F} → {H}, {C, E} → {A}, {A, B} → {D}, {A, B, F} → {G}
;
-- (b) Compute a canonical cover of R with Σ.
--          canonical cover == minimal cover; choose any of the possible ans above
--          (merge the above with the same LHS)
--          ANS: {A} → {C, E}, {F} → {H}, {C, E} → {A}, {B, C, E} → {D}, {B, C, E, F} → {G}