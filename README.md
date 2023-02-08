There are a few tutorials in this repository. 

jup_demo.ipynb:
jup_demo is a tutorial for julia and includes examples of how variables, arrays, functions, loops 
and more work in julia. 
Tests:
There aren't prepared tests for this file.

mimi_tutorial.ipynb:
mimi_tutorial is a tutorial for mimi framework, showing how you can access the results of Mimi climate models and change those results with different
parameters and timesteps.
Tests:
The first blocks of Julia code will show how to use Mimi, get a model, run a model, explore and access specific or general results.
Go to In [4] (the fourth block of julia code in the jupyter notebook). This shows the direct result of changing a parameter the model 
MimiDICE2010. To get these results, first make sure that mimi package is downloaded in Julia. 
use MimiDICE2010 and get a model 
run this model (run(your_model))
use Mimi
using the Mimi.plot option, save a png of radiative forcing component with FORC as the parameter. (Mimi.plot(your_model, :radiativeforcing, :FORC))
now we will update a parameter
using update_param! , change fco22x to 3.000, as shown (update_param!(your_model, :fco22x, 3.000))
after this, run the model again. 
now save a png of the same component/parameter pairing under a different png name. 
Your results should have changed. To check, look at the before_change.png and the after_change.png files in this repository. 
