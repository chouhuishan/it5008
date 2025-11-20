-- BCNF - Boyce-Codd Normal Form
--        A relation R with a set of functional dependencies Σ if and only if for 
--        every functional dependency X → {A} ∈ Σ+
--        ** Dependency (X → {A}) is trivial; {A} ⊆ X 
--           or X is a superkey (definition: refer to tutorial_07/tutorial_07.sql)
-- {department} → {faculty}
--      1. Is faculty ⊆ department? No. 
--         Therefore, it is non-trivial, as faculty ⊈ department
--      2. Department is not one of the candidate keys and it does not contain candidate keys.
;
-- 3NF - Third Normal Form
--       A relation R with a set of functional dependencies Σ is in 3NF 
--       if and only if, for every functional dependencies X → {A} ∈ Σ+
--        ** Dependency (X → {A}) is trivial; {A} ⊆ X 
--           or X is a superkey
--           or A is a prime attribute (recall: Prime attributes = UNION of candidate key❗️❗️❗️❗️❗️)
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
-- 1. Boyce-Codd Normal Form.
-- (a) Is R with Σ in 3NF?
-- Simplify RHS:
--          {A} → {C},
--          {A} → {E},
--          {A, B} → {D}, 
--          {F} → {H}, 
--          {C, E} → {A}, 
--          {B, C, E} → {D},
--          {A, B, F} → {D},
--          {A, B, F} → {G},
--          {B, C, E, F} → {G}
-- As per tutorial 7, Prime attributes = {A, B, C, E, F}
-- Non-prime attributes = {D, G, H}
;
-- {A} → {C}
--   Is C a subset of A? No. C ∉ A ❌ not trivial
--   A is not a superkey ❌
--   C is prime ✅
;
-- {A} → {E}
--   Is E a subset of A? No. E ∉ A ❌ not trivial
--   A is not a superkey ❌
--   E is prime ✅
;
-- {A, B} → {D} ➡️ does not satisfy 3NF
--   Is D a subset of A, B? No. E ∉ {A, B} ❌ not trivial
--   {A, B} is not a superkey ❌
--   {D} is not prime ❌
;
-- {F} → {H} ➡️ does not satisfy 3NF
--   Is H a subset of F? No. H ∉ F ❌ not trivial
--   F is not a superkey ❌
--   H is not prime ❌
;
-- {C, E} → {A} 
--   Is A a subset of C, E? No. A ∉ {C, E} ❌ not trivial
--   {C, E} is not a superkey ❌
--   A is prime ✅
;
-- {B, C, E} → {D} ➡️ does not satisfy 3NF
--   Is D a subset of {B, C, E}? No. D ∉ {B, C, E} ❌ not trivial
--   {B, C, E} is not a superkey❌
--   D is not prime ❌
;
-- {A, B, F} → {D}
--   Is D a subset of {A, B, F}? No. D ∉ {A, B, F} ❌ not trivial
--   {A, B, F} is a superkey✅
--   D is not prime ❌
;
-- {A, B, F} → {G}
--   Is G a subset of {A, B, F}? No. G ∉ {A, B, F} ❌ not trivial
--   {A, B, F} is a superkey✅
--   G is not prime ❌
;
-- {B, C, E, F} → {G}
--   Is G a subset of {B, C, E, F}? No. G ∉ {B, C, E, F} ❌ not trivial
--   {B, C, E, F} is a superkey✅
--   G is not prime ❌
;
-- ANS: No. Since not all the FD satisfy the 3NF, R with Σ IS NOT in 3NF.
;
-- (b) Is R with Σ in BCNF?
-- ANS: No. 
--          BCNF ⊆ 3NF
--          If a relation is not in 3NF, it is definitely not in BCNF.
;
-- 2. Normalization
-- (a) Decompose1 R with Σ into a 3NF decomposition 
-- using the algorithm from the lecture.
;
-- From tutorial 7: (steps below follow lecture slides)
--      1. Compute candidate keys : {A, B, F} and {B, C, E, F}
--      2. Compute minimal cover : {A} → {C}, {A} → {E}, {F} → {H}, {C, E} → {A}, {B, C, E} → {D}, {B, C, E, F} → {G}
--      3. Compute canonical cover: {A} → {C, E}, {F} → {H}, {C, E} → {A}, {B, C, E} → {D}, {B, C, E, F} → {G}
--      4. Synthesize R for each σ ∈ Σ : { {A, C, E}, {F , H}, {A, C, E}, {B, D, C, E}, {B, C, E, F , G} }
--      5. Remove subsumed relations : { {A, C, E}, {F , H}, {B, D, C, E}, {B, C, E, F , G} }
--         ** {A, C, E} is repeated twice, so remove one of it
--      6. Add candidate keys (if needed) : Not neded
--         ** {B, C, E, F} is a subset of {B, C, E, F , G}
--      Resulting decomposition : { {A, C, E}, {F , H}, {B, D, C, E}, {B, C, E, F , G} }
;
-- (b) Is the result dependency preserving?
-- ANS: Yes. This is guaranteed by the algorithm.
-- (c) Is the result in BCNF?
-- Check if it satisfy BCNF conditions. (refer above)
--      • {A, C, E} with Σ1 = { {A} → {C}, {A} → {E}, {C, E} → {A} }
--      • {F , H} with Σ2 = { {F} → {H} }
--      • {B, C, D, E} with Σ3 = { {B, C, E} → {D} }
--      • {B, C, E, F , G} with Σ4 = { {B, C, E, F} → {G} }