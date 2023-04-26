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

    # add all pkgs with specific versions (not pinned)
    @info "Installing packages..."
    install_minimal()
    # Other packages
    install_non_minimal()
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
    Pkg.add(name="BenchmarkTools")
    Pkg.add(name="CairoMakie")
    Pkg.add(name="Colors")
    Pkg.add(name="ColorTypes")
    Pkg.add(name="Combinatorics")
    Pkg.add(name="CSV")
    Pkg.add(name="CSVFiles")
    Pkg.add(name="Cubature")
    Pkg.add(name="DataFrames")
    Pkg.add(name="DataStructures")
    Pkg.add(name="DifferentialEquations")
    Pkg.add(name="DistributedArrays")
    Pkg.add(name="Distributions")
    Pkg.add(name="ExcelFiles")
    Pkg.add(name="FFTW")
    Pkg.add(name="Flux")
    Pkg.add(name="Formatting")
    Pkg.add(name="GLMakie")
    Pkg.add(name="HDF5")
    Pkg.add(name="Hwloc")
    Pkg.add(name="Images")
    Pkg.add(name="ITensors")
    Pkg.add(name="JLD")
    Pkg.add(name="Latexify")
    Pkg.add(name="LaTeXStrings")
    Pkg.add(name="LinearAlgebra")
    Pkg.add(name="LsqFit")
    Pkg.add(name="Match")
    Pkg.add(name="Measurements")
    Pkg.add(name="Plots")
    Pkg.add(name="Polynomials")
    Pkg.add(name="ProgressMeter")
    Pkg.add(name="PyCall")
    Pkg.add(name="PyPlot")
    Pkg.add(name="QuantumOptics")
    Pkg.add(name="Reexport")
    Pkg.add(name="StaticArrays")
    #Pkg.add(name="StaticCompiler")
    #Pkg.add(name="StaticTools")
    Pkg.add(name="Statistics")
    Pkg.add(name="SymPy")
    Pkg.add(name="ThreadsX")
    Pkg.add(name="Traceur")
    Pkg.add(name="Zygote")
    
    
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
