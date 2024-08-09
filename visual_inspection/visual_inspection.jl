using YAXArrays, DimensionalData, Zarr
using DimensionalData
using GLMakie
c = open_dataset("/Users/lalonso/Documents/SeasFireCube_v3.zarr/");
ds = c["fcci_ba"];
s_data = ds.data[:,:,1];
lon = lookup(ds, Dim{:longitude});
lat = lookup(ds, Dim{:latitude});
heatmap(lon, lat, s_data; colormap = :inferno, colorscale = log10, colorrange = (0.01,50_000))

ds_2 = c["fcci_ba"];

ds_3 = c["t2m_mean"]

savecube(ds_3, "t2m_mean.zarr")

savecube(ds, "fcci_ba.zarr")