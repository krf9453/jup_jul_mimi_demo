There are a few tutorials in this repository. The only one with testing is mimi_tutorial.ipynb. 
I recommend only pulling mimi_tutorial.ipynb.  

#folder : jup_jul_mimi_demo
##jup_demo.ipynb:

jup_demo is a tutorial for julia and includes examples of how variables, arrays, functions, loops 
and more work in julia. 

Tests:

There aren't prepared tests for this file.

##mimi_tutorial.ipynb:

mimi_tutorial is a tutorial for mimi framework, showing how you can access the results of Mimi climate models and change those results with different
parameters and timesteps.

Tests:

The first blocks of Julia code will show how to use Mimi, get a model, run a model, explore and access specific or general results.

Go to In [4] (the fourth block of julia code in the jupyter notebook). This shows the direct result of changing a parameter the model 
MimiDICE2010. We will be looking at radiative forcing : FORC for our test.

To get these results, first make sure that mimi package is downloaded in Julia.

*this code segment uses the plot feature that will save pngs to your personal file. The title of the pngs are BeforeChangeC02.png 
and AfterChangeC02.png. Make sure these names are avaiable, and if not, you can change them in your own personal run of the code.
if you cannot, I recommend using the explore feature (explore(your_model)) and manually going to the graph for radiativeforcing : FORC 
after each change to a parameter.*

After running this code segment, check that your graph of radiativeforcing : FORC are the same as the one seen in the github repository 
titled BeforeChangeC02.png and AfterChangeC02.png. 

#folder : mimiCIAM_demo
##jup_mimiCIAM.ipynb:

jup_mimiCIAM uses mimiCIAM to get costs like no adapt cost and optimal costs given certain parameters (like SSP and SLR) for given segments (locations around of the world). This file runs multiple models, changing SSP's to see results, and looking at different segments. The main focus of this file, though, is to look at the cost change when changing the sea level rise (slr) predictions. The slr parameter is updated and the results can be seen in the chanrts shown in the file. 

##SLR_Manip : SLR_Notebook.ipynb

SLR_Manip is a folder to hold the sea level rise manipulation code found in SLR_Notebook.ipynb. This notebook read netCDF files to read slr data from Antarctica.


