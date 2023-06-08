# sneasy_param.ipynb

this notebook reads slr data from Sneasy Brick, downscales segments in the US Gulf coast then runs them through 
CIAM, creating CSV's of data output including net present value optimal, optimal cost,
no adapt cost, and optimal adaptation strategy
this data runs this for 10000 trials of parameters, saving parameter data

*for the outputs, the rows are the segements, and the columns are typically models/trials from Sneasy's data*

*column order: trial 1 param 1, trial 1 param 2, etc*

## running for all segments in the gulf coast

1. pull sneasy_param.ipynb, run_ciam_data_function.jl, downscaling.jl, projections_csv files (for contribution data), gulf_segments.csv, lonlat_gulf_list.csv, move_factor_s.csv, dvbm_s.csv, vslel_s.csv, vslmult_s.csv, wvel_s.csv, wvpdl_s.csv
2. run cells 1-9 to read necessray data (also make sure you have packages installed!)

*do NOT run cell 15!!!!! else you change the parameter data!!!!*
3. run cells 17-18 to get parameters
4. run cells 24-29 

(should end up with 24 csvs)