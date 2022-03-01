# Bayesian-Modeling-of-COVID-19-with-Methods-to-Address-Underreporting

Project Outline:
1. Implemented an ODE-based disease transmission model adapted from Grinsztajn et. al in order to model COVID-19 transmission in North Carolina during two time periods: an earlier stage and later stage of the pandemic.
2. Modified prior distributions proposed in Grinsztajn et. al based on more recent findings on R0 and recovery-time specific to the U.S.
3. Addressed underreporting using two different approaches:
(a) Link observed death counts to the underlying unobserved infections: infection(t) = observedDeaths(t+25)∗
(1/I F R).
(b) Add a parameter in the model, an underreporting factor, to characterize the number of unobserved infections:
infection(t) = observedInfections(t) ∗ (1/pReported).
4. Bayesian Inference: Hamiltonian Monte Carlo to estimate model parameters.
