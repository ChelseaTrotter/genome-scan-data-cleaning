using RCall


# end

function run_cleaning_in_r(cleaning_file, args)    

    R"""
        source($cleaning_file)
        clean_and_write($(args["url"])
                ,$(args["geno_output_file"])
                ,$(args["pheno_output_file"])
                ,$(args["new_gmap_file"])
                ,$(args["threashold"])
                ,$(args["threashold"])
                ,$(args["nseed"])
                ,$(args["ncores"])
                ,$(args["error_prob"])
                ,$(args["stepsize"])
                )

    """
    
end



