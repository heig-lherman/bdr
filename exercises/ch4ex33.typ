= Exercice 1

- A(#underline[a1], a2)

- AC(#underline[a1, c1], k)
  - AC(a1) ref A(a1)
  - AC(c1) ref C(a1)

- B(#underline[b1, b2], b3, a1)
  - B(a1) ref A(a1)
  - B(a1) not null

- D(#underline[b1, b2], d1, d2) 
  - D(b1, b2) ref B(b1, b2)

- E(#underline[b1, b2], e1) 
  - E(b1, b2) ref B(b1, b2)

- C(#underline[c1], c2, c3, c4, c41, c42, f1)
  - C(f1) ref F(f1)
  - C(f1) not null
  - C(f1) unique

- F(#underline[f1])
- F2(#underline[f1, f2])
  - F2(f1) ref F(f1)

= Exercice 2

- G(#underline[h1, g1], g2)
  - G(h1) ref H(h1)

- H(#underline[h1], h2)

- I(#underline[i1, i2], h1, g1)
  - I(h1, g1) ref G(h1, g1)
  - I(h1, g1) not null

= Exercice 3

- Livre(#underline[ISBN], titre)
  
