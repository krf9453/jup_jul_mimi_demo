function adder(maxval)
    function y(point,n)
        if point + n > maxval
            return point + n - maxval
        else
            return point + n
        end
    end
end

function subtractor(minval,maxval)
    function y(point,n)
        if point - n < minval
            return min(maxval,point - n + maxval)
        else
            return point - n
        end
    end
end

lon_subtractor = subtractor(1,360)
lon_adder = adder(360)
lat_adder = adder(180)
lat_subtractor = subtractor(1,180)

using CSV
using NetCDF
using StatsBase
using DataFrames

function get_fingerprints()

    fp_dir = joinpath(@__DIR__, "..", "data")
    isdir(fp_dir) || mkpath(fp_dir)
    fp_file = joinpath(fp_dir, "FINGERPRINTS_SLANGEN_Bakker.nc")
    if !isfile(fp_file)
        url = "https://github.com/scrim-network/BRICK/raw/master/fingerprints/FINGERPRINTS_SLANGEN_Bakker.nc"
        download(url, fp_file)
    end

    fplat = ncread(fp_file,"lat")
    fplon = ncread(fp_file,"lon")
    fpAIS = ncread(fp_file,"AIS")
    fpGSIC = ncread(fp_file,"GLAC")
    fpGIS = ncread(fp_file,"GIS")
    ncclose()

    return fplat,fplon,fpAIS,fpGSIC,fpGIS
end


function downscale_brick(brickcomps, lonlat, ensInds, ystart=2010, yend=2100, tstep=10)
    # To do - check with vectors of lat, lon
    (fplat,fplon,fpAIS,fpGSIC,fpGIS) = get_fingerprints()
    (btime,AIS,GSIC,GIS,TE,LWS,GMSL) = brickcomps

    # Select indices of time of interest, with respect to timestep
    tinds = findall(x -> x .>= ystart && x .<=yend, btime)
    years = collect(ystart:yend)
    yinds = findall(x -> x % tstep==0, years)
    # Need to normalize LSL relative to 2000
    inorm = findall(x -> x==2000, btime)
    
    tdim=length(btime)

    if length(years)==length(tinds)
        tinds = tinds[yinds]
    else
        println("Error: years outside of bounds")
        return nothing
    end

    num_ens = length(ensInds)

    # Output matrix: ens x time x segment
    lsl_out = zeros(num_ens, length(tinds), length(lonlat))

    # Trim component vectors to timesteps and ensembles. Assume interval is 1 year
    if tdim==size(AIS)[1] # check that time dimension is 1
        # for normalizing



        AIS_norm = AIS[inorm,ensInds]
        GSIC_norm = GSIC[inorm,ensInds]
        GIS_norm = GIS[inorm,ensInds]
        TE_norm = TE[inorm,ensInds]
        LWS_norm = LWS[inorm,ensInds]
        GMSL_norm = GMSL[inorm,ensInds]
        # actual projections
        AIS = AIS[tinds,ensInds]
        GSIC = GSIC[tinds,ensInds]
        GIS = GIS[tinds,ensInds]
        TE = TE[tinds,ensInds]
        LWS = LWS[tinds,ensInds]
        GMSL = GMSL[tinds,ensInds]
    else
        println("Error: time dimension is not 1 for brick components")
        return nothing
    end

    for f in 1:length(lonlat) # Loop through lonlat tuples

        lon = lonlat[f][1]
        lat = lonlat[f][2]
        # Convert Longitude to degrees East
        # CIAM Lat is already in (-90,90) by default
        if lon <0
            lon = lon + 360
        end

        # Find fingerprint degrees nearest to lat,lon
        ilat = findall(isequal(minimum(abs.(fplat.-lat))),abs.(fplat.-lat))
        ilon = findall(isequal(minimum(abs.(fplon.-lon))),abs.(fplon.-lon))


        # Take average of closest lat/lon values
        fpAIS_flat = collect(skipmissing(Iterators.flatten(fpAIS[ilon,ilat])))
        fpGSIC_flat = collect(skipmissing(Iterators.flatten(fpGSIC[ilon,ilat])))
        fpGIS_flat = collect(skipmissing(Iterators.flatten(fpGIS[ilon,ilat])))

        fpAIS_loc = mean(fpAIS_flat[isnan.(fpAIS_flat).==false],dims=1)[1]
        fpGSIC_loc = mean(fpGSIC_flat[isnan.(fpGSIC_flat).==false],dims=1)[1]
        fpGIS_loc = mean(fpGIS_flat[isnan.(fpGIS_flat).==false],dims=1)[1]
        fpTE_loc = 1.0
        fpLWS_loc=1.0

        # Keep searching nearby lat/lon values if fingerprint value is NaN unless limit is hit
        inc =1

        while isnan(fpAIS_loc) || isnan(fpGIS_loc) || isnan(fpGSIC_loc) && inc<5

            newlonStart = lon_subtractor.(fplon[ilon],inc)[1]
            newlatStart = lat_subtractor.(fplat[ilat],inc)[1]
            newlonEnd = lon_adder.(fplon[ilon],inc)[1]
            newlatEnd = lat_adder.(fplat[ilat],inc)[1]

            latInd1 = minimum(findall(isequal(minimum(abs.(fplat.-newlatStart))),abs.(fplat.-newlatStart)))
            #minimum(findall(x-> x in newlatStart,fplat))
            latInd2 = maximum(findall(isequal(minimum(abs.(fplat.-newlatEnd))),abs.(fplat.-newlatEnd)))
            #maximum(findall(x -> x in newlatEnd,fplat))

            lonInd1 = minimum(findall(isequal(minimum(abs.(fplon.-newlonStart))),abs.(fplon.-newlonStart)))
            #minimum(findall(x-> x in newlonStart,fplon))
            lonInd2 = maximum(findall(isequal(minimum(abs.(fplon.-newlonEnd))),abs.(fplon.-newlonEnd)))
            #maximum(findall(x -> x in newlonEnd,fplon))

            if latInd2 < latInd1
                latInds=[latInd1; 1:latInd2]
            else
                latInds=latInd1:latInd2
            end

            if lonInd2 < lonInd1
                lonInds=[lonInd1; 1:lonInd2]
            else
                lonInds = lonInd1:lonInd2
            end

            fpAIS_flat = collect(skipmissing(Iterators.flatten(fpAIS[lonInds,latInds])))
            fpGSIC_flat = collect(skipmissing(Iterators.flatten(fpGSIC[lonInds,latInds])))
            fpGIS_flat = collect(skipmissing(Iterators.flatten(fpGIS[lonInds,latInds])))

            fpAIS_loc = mean(fpAIS_flat[isnan.(fpAIS_flat).==false],dims=1)[1]
            fpGSIC_loc = mean(fpGSIC_flat[isnan.(fpGSIC_flat).==false],dims=1)[1]
            fpGIS_loc = mean(fpGIS_flat[isnan.(fpGIS_flat).==false],dims=1)[1]

            inc = inc + 1

        end

        # If still NaN, throw an error
        if isnan(fpAIS_loc) || isnan(fpGIS_loc) || isnan(fpGSIC_loc)
            println("Error: no fingerprints found for ($(lon),$(lat))")
            return nothing
        end
        
       # Multiply fingerprints by BRICK ensemble members
       if ndims(AIS) > 1
            for n in 1:size(AIS)[2] # loop through ensemble members
                lsl_out[n, :, f] = fpGIS_loc * GIS[:,n] + fpAIS_loc * AIS[:,n] + fpGSIC_loc * GSIC[:,n] +
                                   fpTE_loc * TE[:,n] + fpLWS_loc * LWS[:,n]
                # CIAM - LSL should be sea-level change relative to year 2000
                lsl_norm = fpGIS_loc * GIS_norm[n] + fpAIS_loc * AIS_norm[n] + fpGSIC_loc * GSIC_norm[n] +
                           fpTE_loc * TE_norm[n] + fpLWS_loc * LWS_norm[n]
                lsl_out[n, :, f] = lsl_out[n, :, f] .- lsl_norm
            end
        else
            lsl_out[1, :, f] = fpGIS_loc * GIS[:] + fpAIS_loc * AIS[:] + fpGSIC_loc * GSIC[:] +
                fpTE_loc * TE[:] + fpLWS_loc * LWS[:]
            # CIAM - LSL should be sea-level change relative to year 2000
            lsl_norm = fpGIS_loc * GIS_norm + fpAIS_loc * AIS_norm + fpGSIC_loc * GSIC_norm +
                       fpTE_loc * TE_norm + fpLWS_loc * LWS_norm
            lsl_out[1, :, f] = lsl_out[1, :, f] .- lsl_norm
        end

    end # End lonlat tuple

    return lsl_out,GMSL
end