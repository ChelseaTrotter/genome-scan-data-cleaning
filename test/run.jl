include("../src/read_data.jl")
include("../src/cli.jl")


function main()
    args = parse_commandline()
    cleaning_file = "../src/data_cleaning.R"
    run_cleaning_in_r(cleaning_file, args)
end

main()