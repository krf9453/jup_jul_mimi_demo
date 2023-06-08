using MimiCIAM
using Mimi
using PlotlyJS
using NetCDF
using CSV
using DataFrames

#=
Combined function that gets npv, optimal, and no adapt cost in same loop 
@param model = given ciam model
@param ssprcp = ssprcp scenario 
@param lslr = local sea level rise data for segments
@param segments = list of segments
@param trials = number of trials for lslr
@param ts = number of timesteps
@param at = at parameter 
@param params = list of parameter to test
@num_params = number of parameter trials 
@return tuple matrices for optimal cost 2050 and 2100, no adapt cost 2050 and 2100, net present value, and optimal strategy
=#

function run_ciam_data_f(model, ssprcp, lslr, segments, trials,ts, at, params = nothing, num_params = 1)

    # op_array/na_array = rows are segments, columns are models/trial
    #npv_array = rows are segments, columns are models/trials 
    #optimal_adapt = rows are segemnts, columns are models/trials

    #if params are tested, order of cols in matrix is param 1 trial 1, param 2 trial 1, etc
    op_array_2050 = []
    op_array_2100 = []
    na_array_2050 = []
    na_array_2100 = []
    npv_array = []
    optimal_adapt = []


    update_param!(model, :slrcost, :ntsteps, ts)
    update_param!(model, :slrcost, :at, at)
    MimiCIAM.run(model)
    
    
        for i in range(1,trials)
            lslr_trial = lslr[i, :]
            for k in range(1, length(segments)-1)
                lslr_trial = hcat(lslr_trial, lslr[(trials * k) + i, :])
            end
            update_param!(model, :slrcost, :lslr, lslr_trial)
            run(model)
            
            temp_opad = []
                    
            temp_op_2050 = []
            temp_op_2100 = []
            temp_na_2050 = []
            temp_na_2100 = []
                    
            temp_npv = []
            for j in range(1, num_params)

                
                if params !== nothing
                    update_param!(model, :slrcost, :movefactor, params[1][j])
                    update_param!(model, :slrcost, :dvbm, params[2][j])
                    update_param!(model, :slrcost, :vslel, params[3][j])
                    update_param!(model, :slrcost, :vslmult, params[4][j])
                    update_param!(model, :slrcost, :wvel, params[5][j])
                    update_param!(model, :slrcost, :wvpdl, params[6][j])
                end
                
                run(model)
            
                optadapt_temp = []
                for k in range(1, length(segments))
                    op_cost = model[:slrcost, :OptimalCost][1,k]
                    if op_cost == model[:slrcost, :ProtectCost][:,:,1][1,k]
                        push!(optadapt_temp, "Protect-1")
                    elseif op_cost == model[:slrcost, :ProtectCost][:,:,2][1,k]
                        push!(optadapt_temp, "Protect-2")
                    elseif op_cost == model[:slrcost, :ProtectCost][:,:,3][1,k]
                        push!(optadapt_temp, "Protect-3")
                    elseif op_cost == model[:slrcost, :ProtectCost][:,:,4][1,k]
                        push!(optadapt_temp, "Protect-4")
                    elseif op_cost == model[:slrcost, :ProtectCost][:,:,5][1,k]
                        push!(optadapt_temp, "Protect-5")
                    elseif op_cost == model[:slrcost, :RetreatCost][:,:,1][1,k]
                        push!(optadapt_temp, "Retreat-1")
                    elseif op_cost == model[:slrcost, :RetreatCost][:,:,2][1,k]
                        push!(optadapt_temp, "Retreat-2")
                    elseif op_cost == model[:slrcost, :RetreatCost][:,:,3][1,k]
                        push!(optadapt_temp, "Retreat-3")
                    elseif op_cost == model[:slrcost, :RetreatCost][:,:,4][1,k]
                        push!(optadapt_temp, "Retreat-4")
                    elseif op_cost == model[:slrcost, :RetreatCost][:,:,5][1,k]
                        push!(optadapt_temp, "Retreat-5")
                    elseif op_cost == model[:slrcost, :RetreatCost][:,:,6][1,k]
                        push!(optadapt_temp, "Retreat-6")
                    else 
                        push!(optadapt_temp, "None?")
                    end
                end

                if j == 1
                    
                    temp_opad = optadapt_temp

                    temp_op_2050 = model[:slrcost, :OptimalCost][6,:]
                    temp_op_2100 = model[:slrcost, :OptimalCost][11,:]
                    temp_na_2050 = model[:slrcost, :NoAdaptCost][6,:]
                    temp_na_2100 = model[:slrcost, :NoAdaptCost][11,:]
                    
                    temp_npv = model[:slrcost, :NPVOptimal]
                else
                    temp_opad = hcat(temp_opad, optadapt_temp)
                    
                    temp_op_2050 = hcat(temp_op_2050, model[:slrcost, :OptimalCost][6,:])
                    temp_op_2100 = hcat(temp_op_2100, model[:slrcost, :OptimalCost][11,:])
                    temp_na_2050 = hcat(temp_na_2050, model[:slrcost, :NoAdaptCost][6,:])
                    temp_na_2100 = hcat(temp_na_2100, model[:slrcost, :NoAdaptCost][11,:])

                    temp_npv = hcat(temp_npv,  model[:slrcost, :NPVOptimal])
                
                end
            end
            if i == 1                    
                optimal_adapt = temp_opad
                
                op_array_2050 = temp_op_2050
                op_array_2100 = temp_op_2100
                na_array_2050 = temp_na_2050
                na_array_2100 = temp_na_2100
                
                npv_array = temp_npv
                
            else

                optimal_adapt = hcat(optimal_adapt, temp_opad)
                
                op_array_2050 = hcat(op_array_2050, temp_op_2050)
                op_array_2100 = hcat(op_array_2100, temp_op_2100)
                na_array_2050 = hcat(na_array_2050, temp_na_2050)
                na_array_2100 = hcat(na_array_2100, temp_na_2100)

                npv_array = hcat(npv_array,  temp_npv)
            end
            

        end
    

    if num_params !== nothing 
        name = "Sneasy_"
    else 
        name = "Hermans_"
    end
    CSV.write(string("OptimalCost_Gulf_2050_", name, ssprcp, ".csv"), DataFrame(op_array_2050, :auto))
    CSV.write(string("OptimalCost_Gulf_2100_", name, ssprcp, ".csv"), DataFrame(op_array_2100, :auto))
    CSV.write(string("NoAdaptCost_Gulf_2050_", name, ssprcp, ".csv"), DataFrame(na_array_2050, :auto))
    CSV.write(string("NoAdaptCost_Gulf_2100_", name, ssprcp, ".csv"), DataFrame(na_array_2100, :auto))
    CSV.write(string("NPVOptimal_Gulf_", name, ssprcp, ".csv"), DataFrame(npv_array, :auto))
    CSV.write(string("OptimalStrategy_Gulf_", name, ssprcp, ".csv"), DataFrame(optimal_adapt, :auto))
    return op_array_2050, op_array_2100, na_array_2050, na_array_2100, npv_array, optimal_adapt 
end