using JLD2, Dates

dir = joinpath(splitpath(dirname(pathof(@__MODULE__)))[1:(end - 1)])

nation = "italy"

# Load calibration data (with figaro input-output tables)
calibration_data = load(joinpath(dir, "data/" * nation * "/calibration/calibration/2010Q1.jld2"))["calibration_data"]
figaro = load(joinpath(dir, "data/" * nation * "/calibration/figaro/2010.jld2"))["figaro"]

# Load time series data
data = load(joinpath(dir, "data/" * nation * "/calibration/data/1996.jld2"))["data"]
ea = load(joinpath(dir, "data/" * nation * "/calibration/ea/1996.jld2"))["ea"]

# add calibration times to the data
max_calibration_date = DateTime(2016, 12, 31)
estimation_date = DateTime(1996, 12, 31)

struct CalibrationData
    calibration::Dict{String, Any}
    figaro::Dict{String, Any}
    data::Dict{String, Any}
    ea::Dict{String, Any}
    max_calibration_date::DateTime
    estimation_date::DateTime
end

const ITALY_CALIBRATION = CalibrationData(calibration_data, figaro, data, ea, max_calibration_date, estimation_date)

using Downloads

const ZENODO_REPOSITORY_URL = "https://zenodo.org/records/18698434/files/"
const AVAILABLE_COUNTRIES = ["AT", "BE", "BG", "CY", "CZ", "DE", "DK", "EE", "EL", "ES", "FI", "FR", "HR", "HU", "IE", "IT", "LT", "LU", "LV", "MT", "NL", "PL", "PT", "RO", "SE", "SI", "SK"]

"""
    download_zenodo_calibration_object(country)

`country` should be a 2-digit country code. See AVAILABLE_COUNTRIES for which countries are available.
"""
function download_zenodo_calibration_object(country)
    if !(country in AVAILABLE_COUNTRIES)
        error("Country $(country) is not in the list of available countries. See AVAILABLE_COUNTRIES.")
    end
    url = ZENODO_REPOSITORY_URL * country * "_calibration_object.jld2"
    dir = joinpath(splitpath(dirname(pathof(@__MODULE__)))[1:(end - 1)])
    file_path = joinpath(dir, "data/" * country * "/calibration_object.jld2")
    if isfile(file_path)
        # @info "Calibration object for $country already exists at $file_path. Loading from there."
        return load(file_path)["calibration_object"]
    end
    mkdir(joinpath(dir, "data/" * country))
    Downloads.download(url, file_path)
    co = load(file_path)["calibration_object"]
    return co
end
