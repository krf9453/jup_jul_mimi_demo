#npv_ciam.ipynb
This notebook downscales segments in the US Gulf coast then runs them through CIAM, creating CSV's of data output including net present valueoptimal, optimal cost, no adapt cost, and optimal adaptation strategy.

*for the outputs, the rows are the segements, and the columns are typically models/trials from Herman's data*

In this notebook is a function run_ciam_data(). This function will get all of the out listed above.

##Running run_ciam_data() for all segments of the gulf coast
*will reference jupyter notebook cells by number, which includes markdown and julia cells*
1. Pull npv_ciam.ipynb, downscaling.jl, gulf_segments.csv, segment_data_gulf.csv 
2. pull SLR_Manip (you only need all the contribution csv's titled [contribution]_[ssp/rcp]_f.csv)
2. run the cell 1 and cell 2 to import necessary packages (make sure you have the packages installed!)
3. run cells 16-19 to read necessary data / helper functions
4. run cell 22 to instantiate function run_ciam_data()
5. run alls cells in the section "Run all segments in the Gulf Coast" cells 30-34
6. CSVs for NPVOptimal, OptimalCost, NoAdaptCost, and OptimalAdapt will be saved for every ssp/rcp scenario (should end up with 12 CSVs)