ENV["JUPYTER"] = "/usr/local/bin/jupyter-notebook";
# The following ENV variables are defined outside this script
#ENV["JULIA_PKGDIR"] = "/usr/share/julia/packages";
if !("JULIA_DEPOT_PATH" in keys(ENV))
    # set DEPOT_PATH as if not given in ENV
    #ENV["JULIA_DEPOT_PATH"] = "/usr/share/julia";
    empty!(DEPOT_PATH)
    push!(DEPOT_PATH, "/usr/share/julia")
end

using Pkg; 


# Installs all necessary packages in the global environment
## See https://github.com/markusschmitt/compphys2021/blob/main/tutorials/install.jl
get_global_env() = string("v", VERSION.major, ".", VERSION.minor)
get_global_env_folder() = joinpath(DEPOT_PATH[1], "environments", get_global_env())
get_active_env() = Base.active_project() |> dirname |> basename

# activate global environment (if not already active)
function activate_global_env()
    if get_active_env() != get_global_env()
        Pkg.REPLMode.pkgstr("activate --shared $(get_global_env())")
    end 
    nothing
end

# Installs all correct versions of our package dependencies.
function install()
    activate_global_env()

    # add all pkgs with specific versions (not pinned)
    @info "Installing packages..."
    # IJulia Kernel
    Pkg.add("IJulia")
    # Other packages
    Pkg.add(name="BenchmarkTools", version="1.3.1")
    Pkg.add(name="CSV", version="0.10.4")
    Pkg.add(name="CSVFiles", version="1.0.1")
    Pkg.add(name="ColorTypes", version="0.11.0")
    Pkg.add(name="Cubature", version="1.5.1")
    Pkg.add(name="DataFrames", version="1.3.2")
    Pkg.add(name="DifferentialEquations", version="7.1.0")
    Pkg.add(name="Distributions", version="0.25.53")
    Pkg.add(name="FFTW", version="1.4.6")
    Pkg.add(name="Flux", version="0.12.4")
    Pkg.add(name="Formatting", version="0.4.2")
    Pkg.add(name="HDF5", version="0.16.5")
    Pkg.add(name="JLD", version="0.13.1")
    Pkg.add(name="LaTeXStrings", version="1.3.0")
    Pkg.add(name="LsqFit", version="0.12.1")
    Pkg.add(name="Measurements", version="2.7.1")
    Pkg.add(name="Polynomials", version="3.0.0")
    Pkg.add(name="ProgressMeter", version="1.7.2")
    Pkg.add(name="PyCall", version="1.93.1")
    Pkg.add("PyPlot")
    Pkg.add(name="Plots", version="1.27.4")
    Pkg.add(name="Traceur", version="0.3.1")
    Pkg.add(name="Zygote", version="0.6.37")

    # precompile
    @info "Precompile all packages..."
    pkg"precompile"

    @info "Building IJulia kernel..."
    Pkg.build("IJulia")
end

function install_minimal()
    activate_global_env()

    # add all pkgs with specific versions (not pinned)
    @info "Installing minimal packages..."
    # IJulia Kernel
    Pkg.add("IJulia")
    # Add minimal packages below, others have to be installed manually
    # ...

    # precompile
    @info "Precompile minimal packages..."
    pkg"precompile"

    @info "Building IJulia kernel..."
    Pkg.build(name="IJulia")
end

function install_non_minimal()

    # add all pkgs with specific versions (not pinned)
    @info "Installing non-minimal packages..."
    # Add non minimal packages below, others have to be installed manually
    Pkg.add(name="BenchmarkTools", version="1.3.1")
    Pkg.add(name="CSV", version="0.10.4")
    Pkg.add(name="CSVFiles", version="1.0.1")
    Pkg.add(name="ColorTypes", version="0.11.0")
    Pkg.add(name="Cubature", version="1.5.1")
    Pkg.add(name="DataFrames", version="1.3.2")
    Pkg.add(name="DifferentialEquations", version="7.1.0")
    Pkg.add(name="Distributions", version="0.25.53")
    Pkg.add(name="FFTW", version="1.4.6")
    Pkg.add(name="Flux", version="0.12.4")
    Pkg.add(name="Formatting", version="0.4.2")
    Pkg.add(name="HDF5", version="0.16.5")
    Pkg.add(name="JLD", version="0.13.1")
    Pkg.add(name="LaTeXStrings", version="1.3.0")
    Pkg.add(name="LsqFit", version="0.12.1")
    Pkg.add(name="Measurements", version="2.7.1")
    Pkg.add(name="Polynomials", version="3.0.0")
    Pkg.add(name="ProgressMeter", version="1.7.2")
    Pkg.add(name="PyCall", version="1.93.1")
    Pkg.add(name="PyPlot")
    Pkg.add(name="Plots", version="1.27.4")
    Pkg.add(name="Traceur", version="0.3.1")
    Pkg.add(name="Zygote", version="0.6.37")

    # precompile
    @info "Precompile non-minimal packages..."
    pkg"precompile"
end

# Get the command to execute by CL argument
if size(ARGS, 1) == 1
    cmd = ARGS[1]
    if cmd == "--install"
        @info "Making full install (IJulia and all packages)"
        install()
    elseif cmd == "--install-min"
        @info "Making minimal install (IJulia and minimal packages)"
        install_minimal()
    elseif cmd == "--install-non-min"
        @info "Installing non minimal packages"
        install_non_minimal()
    end
end
