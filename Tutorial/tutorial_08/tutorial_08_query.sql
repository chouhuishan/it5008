If it is not in 3NF, it is not BCNF

R= {A, B, C, D, E, F , G, H}
Σ = { 
        {A} → {C},
        {A} → {E},
        {A, B} → {D},
        {F} → {H},
        {C, E} → {A},
        {B, C, E} → {D},
        {A, B, F} → {D},
        {A, B, F} → {G},
        {B, C, E, F} → {G} 
}

Superkeys = {A, B, F}, {B, C, E, F} -- is superkey the same as candidate keys?
{A, B, F}, {B, C, E, F} = {A, B, C, E, F}

Trivial 
    {A} → {A}
    {A, B} → {A}

    consider {A, B} → {D}
    {D} is not a subset of {A, B} → not trivial (RHS needs to be a subset of LHS)
    {A, B}+ = {A, B, D, C, E} is not equivalent to R → not a superkey (LHS cannot be a superkey) 

    This concludes that this is not BCNF.

    Superkeys are {A, B, F} and {B, C, E, F}
    Prime attributes sets = {A, B, F} Union {B, C, E, F} = {A, B, C, E, F}
    D is not a subset of {A, B, C, E, F} → D is not a prime attribute (RHS cannot be a prime attribute)


    
-- Not Trivial
    {A} → {B}
    {A, B} → {C, D}

1. Boyce-Codd Normal Form.
-- (a) Is R with Σ in 3NF?
RHS is the prime attributes 
-- (b) Is R with Σ in BCNF?
BCNF : All of them are trivial/LHS are super keys


Normalization.
-- (a) Decompose1 R with Σ into a 3NF decomposition using the algorithm from the lecture.
-- Canonical cover = Σ 
    A C, → E = {A, C, E}
    F → H = {F, H}
    C, E → A = {C, E, A} ❌ can be removed (same as the first one)
    B, C, E → D = {B, C, E, D}
    B, C, E, F → G = {B, C, E, F, G} → {B, C, E, F} is a subset of this 

    Final 3NF decomposition = {
        {A, C, E},
        {F, H},
        {B, C, E, D},
        {B, C, E, F, G}
    }

-- (b) Is the result dependency preserving?
See the slides Theorem 9

-- (c) Is the result in BCNF?

    