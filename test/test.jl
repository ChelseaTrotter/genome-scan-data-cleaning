include("../src/read_data.jl")
include("../src/cli.jl")

function main()
    args = parse_commandline()
    url = args["url"]
    rcall_read_cross2(url)
end

main()