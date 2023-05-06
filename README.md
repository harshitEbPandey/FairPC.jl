# Learn Fair PC

This repo contains the code and experiments from the paper "[Group Fairness by Probabilistic Modeling with Latent Fair Decisions](http://starai.cs.ucla.edu/papers/ChoiAAAI21.pdf)", published in AAAI 2021. Refer to that repository for more details.


## Files

```
  analysis/data                Data dump for EP of instances on nonLatent and FairPC
  analysis/se_analysis.py      python code for combined analysis
  src/compareSE.jl             Generate Sufficient Explanations for instances and store results
```

## example run
```
$  julia --project bin/learn.jl compas --exp-id 1  --dir "exp/compas/1" --struct_type "FairPC"  --sensitive_variable "Ethnic_Code_Text_"  --fold 1 
```
