import pandas as pd
import numpy as np
import os

LV_test_path = "/Users/sauravanchlia/Fair_ML/PRL/prod/FairPC.jl/analysis/data/latent_variable"

def test(df):
    return df.sample(n=50, random_state=1).to_csv(os.path.join(LV_test_path, "samples.csv"))

