using YAXArrays, Zarr, NetCDF
using GLMakie
using DimensionalData
using OnlineStats
using NaNStatistics
using Colors
using GLMakie.GeometryBasics
using ColorSchemes
using Dates
using GeoMakie

function getTimeIndex(a)
    idx = nanargmax(a)
    if idx==1
        return NaN
    elseif a[idx]==0.0f0
        return NaN
    else
        return idx
    end
end

ds_o = open_dataset("/Users/lalonso/Documents/SeasFireCube_v3.zarr/");
ds = ds_o["fcci_ba"];
lon = lookup(ds, :longitude)
lat = lookup(ds, :latitude)
tempo = lookup(ds, :Ti)
tempo= string.(Date.(tempo))
tempo = [t[1:7] for t in tempo]

d = ds.data[:,:,:];
d_sum = replace(nansum(d, dims=3)[:,:,1], 0.0=>NaN) #.+ 1
d_sum_max = nansum(d, dims=3)[:,:,1] .+ 1

d_mean = nanmean(d, dims=3)[:,:,1] .+ 1

d_max = nanmaximum(d, dims=3)[:,:,1]
d_max = replace(d_max, 0.0f0=>NaN)

tempo_index = [getTimeIndex(d[i,j,:]) for (i, lo) in enumerate(lon), (j,la) in enumerate(lat)]
pos_max = argmax(d_sum_max)

fs = 2

pnts_vars = [Point3f(i,0,k) for k in range(-6,6,12) for i in range(-2.5,2.5,5)];

nao = ds_o["oci_nao"].data[:]
ao =ds_o["oci_ao"].data[:]
nino =ds_o["oci_nina34_anom"].data[:]

# ml and graphs variables
# lst
lst = ds_o["lst_day"].data[pos_max[1], pos_max[2],:]
# ndvi
ndvi = ds_o["ndvi"].data[pos_max[1], pos_max[2],:]
# rH
rH = ds_o["rel_hum"].data[pos_max[1], pos_max[2],:]
# ssr
ssr = ds_o["ssr"].data[pos_max[1], pos_max[2],:]
# sst => sea surface temperature, none here, the location is in-land
sst = ds_o["sst"].data[pos_max[1], pos_max[2],:]
# rain
rain = ds_o["tp"].data[pos_max[1], pos_max[2],:]
# vpd
vpd = ds_o["vpd"].data[pos_max[1], pos_max[2],:]
# t2m
t2m = ds_o["t2m_mean"].data[pos_max[1], pos_max[2],:]
# ax_fires
gfed = ds_o["gfed_ba"].data[pos_max[1], pos_max[2],:]
gwis = ds_o["gwis_ba"].data[pos_max[1], pos_max[2],:]

#time ticks
#tempo =  string.(Date.(DateTime.(tempo)))
lentime = length(tempo)
slice_dates = range(1, lentime, step=lentime ÷ 15)


vars_names = setdiff(propertynames(ds_o),[:time, :longitude, :latitude])
vars_names = [
    :t2m_mean, :tp, :swvl1, :vpd, :gfed_ba,
    :fcci_ba, :gwis_ba, :lai, :ndvi, :rel_hum, 
    :ws10, :ssr, :sst, :skt, :mslp]

ds_n = ds_o["t2m_mean"]

vars_names_str = join(string.(vars_names),"\n")

function assemble_face(ds_n; cmap=:plasma, save_plot=true, name="variable")
    front = ds_n[Ti=1].data[:,:]
    back = ds_n[Ti=966].data[:,:]
    top = ds_n[latitude=At(89.875)].data[:,:]
    bottom = ds_n[latitude=At(-89.875)].data[:,:]
    left = ds_n[longitude=At(-179.875)].data[:,:]
    right = ds_n[longitude=At(179.875)].data[:,:]
    imgs = [top, rotr90(front), rotl90(right), back[:,end:-1:1], left[end:-1:1,:], rotr90(bottom[:,end:-1:1])]
    tmp_data = replace(ds_n.data[:,:,:], missing=>NaN)
    mn = nanminimum(tmp_data)
    mx = nanmaximum(tmp_data)
    fig = Figure(figure_padding=0, resolution =(600*4,400*4))
    axs = [Axis(fig[i,j], aspect=1) for i in 1:2 for j in 1:3]
    if name in ["fcci_ba", "gfed_ba", "gwis_ba"]
        [heatmap!(axs[i], imgs[i]; colormap = cmap,
            colorscale=log10, colorrange = (mn+0.01, mx)) for i in 1:6]
    else
        [heatmap!(axs[i], imgs[i]; colormap = cmap, colorrange = (mn, mx)) for i in 1:6]
    end
    hidedecorations!.(axs)
    hidespines!.(axs)
    colgap!(fig.layout,0)
    rowgap!(fig.layout,0)
    if save_plot
        save("faces_$name.png", fig)
    else
        return Makie.colorbuffer(fig.scene)
    end
end

function meshcube(o=Vec3f(0), sizexyz = Vec3f(1))
    uvs = map(v -> v ./ (3, 2), Vec2f[
    (0, 0), (0, 1), (1, 1), (1, 0),
    (1, 0), (1, 1), (2, 1), (2, 0),
    (2, 0), (2, 1), (3, 1), (3, 0),
    (0, 1), (0, 2), (1, 2), (1, 1),
    (1, 1), (1, 2), (2, 2), (2, 1),
    (2, 1), (2, 2), (3, 2), (3, 1),
    ])
    m = normal_mesh(Rect3f(Vec3f(-0.5) .+ o, sizexyz))
    m = GeometryBasics.Mesh(meta(coordinates(m);
        uv = uvs, normals = normals(m)), faces(m))
end

# cs = collect(keys(colorschemes))
# to_rm = findall(x->x>0, occursin.("flag", string.(cs)))
# to_rm_names = cs[to_rm]
# cs = setdiff(cs, to_rm_names)
# to_rm = findall(x->x>0, occursin.("glasbey", string.(cs)))
# to_rm_names = cs[to_rm]
# cs = setdiff(cs, to_rm_names)
# to_rm = findall(x->x>0, occursin.("cyclic", string.(cs)))
# to_rm_names = cs[to_rm]
# cs = setdiff(cs, to_rm_names)

cs = [
    :seaborn_icefire_gradient, :lipari, :lapaz, :lajolla, :seaborn_rocket_gradient,
    :CMRmap, :plasma, :viridis, :fastie, :vik,
    :bone_1, :inferno, :linear_worb_100_25_c53_n256, :linear_wyor_100_45_c55_n256, :Iridescent
]
m = meshcube();
# for (i,v_name) in enumerate(vars_names)
#     ds_n = ds_o[v_name]
#     if length(size(ds_n)) ==3
#         assemble_face(ds_n; cmap = cs[i], name = string(v_name))
#     end
# end


# img_faces = assemble_face(ds_n);
# img = Makie.FileIO.load("faces_fcci_ba.png");
# mesh(m; color = img, interpolate=false)

winter = resample_cmap(:Winter,10)
#winter = resample_cmap(:winter,10)

spring = resample_cmap(:spring,10)
summer = resample_cmap(:summer,10)
autumn = resample_cmap(:autumn,10)
fall = resample_cmap(:fall, 10)

#. the groups are 0: 'DJF', 1: 'JJA' , 2:'MAM' , 3:'SON'
# Dec- Jan - Feb # winter
# Jun - Jul - Ago 1->2 # summer
# Mar - April - May 1->2 # spring
# Sep- Oct- Nov # fall
cmap = [winter[7], summer[8], spring[5], fall[10]]


max_burnt_season = Cube("fcci_season.nc")
max_bs = max_burnt_season.data[:,:]
function doMapa(vars_names)
    with_theme( theme_latexfonts()) do
        fig = Figure(#figure_padding=(10,10,10,60),
            resolution=(1200*fs,600*fs), fontsize=16*fs)
        ax_left = LScene(fig[1:5,1], show_axis=false)
        lay_mid_1 = GridLayout(fig[1:2,2])
        axs_sum = Axis(lay_mid_1[1,1]) #[LScene(lay_mid_1[i,j], show_axis=false) for j in 1:3 for i in 1:2]
        lay_mid_2 = GridLayout(fig[1:2,3])
        axs_time = Axis(lay_mid_2[1,1]) #[LScene(lay_mid_2[i,j], show_axis=false) for j in 1:3 for i in 1:2]

        lay_mid_3 = GridLayout(fig[3:5,2:3])
        ax_fires = Axis(lay_mid_3[1,1:3]; ) 
        hidexdecorations!(ax_fires, ticks=false, grid=false)

        #ax_fires.yticks = ([2e4, 4e4,6e4], ["2", "4", "6"])
        ax_lines = Axis(lay_mid_3[2,1:3])
        hidexdecorations!(ax_lines, ticks=false, grid=false)
        ax_lines_s = Axis(lay_mid_3[3,1:3])
        #ylims!(ax_lines_s, 0.01, 100)

        hidexdecorations!(ax_lines_s, ticks=false, grid=false)

        ax_ndvi = Axis(lay_mid_3[4,1:3])
        hidexdecorations!(ax_ndvi, ticks=false, grid=false)

        ax_lines2 = Axis(lay_mid_3[5,1:3])
        in_white = ["tp", "t2m_mean", "ws10", "ssr"]
        c=1
        for j in -1:1
            for k in -2:2
                color = "$(vars_names[c])" ∉ in_white ? :black : :white 
                img = Makie.FileIO.load("faces_$(vars_names[c]).png");
                mesh!(ax_left, meshcube(Vec3f(0,j,k), Vec3f(2,0.8,0.8)); color = img)
                text!(ax_left, Vec3f(1.55,j,k+0.4), text= "$(vars_names[c])",
                    align=(:center, :center), color=color, fontsize=12*fs)
                c+=1
            end
        end
        #Label(fig[1:5,1], text=vars_names_str, tellwidth=false, tellheight=false)

        # [mesh!(axs_sum[k], Sphere(Point3f(0),1); color = rotr90(d_sum[end:-1:1,:]),
        #     colorrange = (1.00001, 5.75f6), colormap = :CMRmap,
        #     colorscale=log2, lowclip=:snow1) for k in 1:6]
        limits!(axs_sum, -179.5,179.5, -60,75)
        hm=heatmap!(axs_sum, lon, lat, d_sum; colorrange=(1.0, 5.744f6),
            colorscale=log2,
            colormap=:gnuplot,
            nan_color=(:deepskyblue,0.025),
            )
        lines!(axs_sum, GeoMakie.coastlines(); color=:black, linewidth=0.5)
        scatter!(axs_sum, lon[pos_max[1]], lat[pos_max[2]]; marker=:rect, color=:black)

        hidedecorations!(axs_sum, ticks=false, ticklabels=false, grid=false)
        axs_sum.xtickformat = "{1:d}ᵒ"
        axs_sum.ytickformat = "{1:d}ᵒ"

        hidespines!(axs_sum)
        Colorbar(lay_mid_1[0,1], hm, vertical=false,
            label = "fcci_ba sum over all years [ha]", #flipaxis=false,
            #colorrange = (1.00001, 5.75f6), scale=log2,
            #lowclip=false,
            width = Relative(0.5))

        # [mesh!(axs_time[k], Sphere(Point3f(0),1); color = rotr90(tempo_index[end:-1:1,:]),
        #     #colorrange = (1.00001, 5.75f6),
        #     colormap =:Spectral_11, nan_color=:grey15,
        #     lowclip=:snow1) for k in 1:6]

        limits!(axs_time, -179.5,179.5, -60,75)
        hm=heatmap!(axs_time, lon, lat, max_bs; #colorrange=(1.0, 5.744f6),
            colormap=cgrad(cmap, 4, categorical=true),
            nan_color= (:deepskyblue,0.025), #:whitesmoke,
            shading=false,
            colorrange=(-0.5,3.5)
            )
        lines!(axs_time, GeoMakie.coastlines(); color=:black, linewidth=0.5)
        
        hideydecorations!(axs_time, ticks=false, ticklabels=true, grid=false)
        hidexdecorations!(axs_time, ticks=false, ticklabels=false, grid=false)
        axs_time.xtickformat = "{1:d}ᵒ"
        axs_time.ytickformat = "{1:d}ᵒ"

        hidespines!(axs_time)
        cb = Colorbar(lay_mid_2[0,1], hm, vertical=false,
            label = "Season", #flipaxis=false,
            #colorrange = (1.00001, 5.75f6), scale=log2,
            width = Relative(0.5))
        cb.ticks = (0:3, ["DJF", "JJA", "MAM", "SON"])
        # 1d variables
        lines!(ax_lines2, nino; label = "oci_nina34_anom", color=:coral1)
        lines!(ax_lines2, nao; label =  "oci_nao", color=:dodgerblue)
        lines!(ax_lines2, ao; label = "oci_ao", color=:navy)

        #axislegend(ax_lines2; framecolor=:transparent, bgcolor=(:white, 0.85))

        #3d variables
        lines!(ax_lines, lst; label = "lst", color=Cycled(3))
        lines!(ax_lines, t2m; label = "t2m_mean", color=Cycled(4))

        #axislegend(ax_lines; framecolor=:transparent, bgcolor=(:white, 0.85))

        lines!(ax_ndvi, ndvi; label = "ndvi", color=:olive)
        
        #axislegend(ax_ndvi; framecolor=:transparent, bgcolor=(:white, 0.85))

        lines!(ax_lines_s, rH; label = "rel_hum", color=Cycled(5))
        lines!(ax_lines_s, rain; label = "tp", color=Cycled(6))
        lines!(ax_lines_s, vpd; label = "vpd", color=:gold)

        #axislegend(ax_lines_s; framecolor=:transparent, bgcolor=(:white, 0.85))

        lines!(ax_fires, d[pos_max,:]; label = "fcci_ba", color = :black)
        lines!(ax_fires, gfed; label = "gfed_ba")
        lines!(ax_fires, gwis; label = "gwis_ba")
        Label(lay_mid_3[1,1:3, Top()], L"\times 10^{4}", halign=-0.01)
        ax_fires.yticks = ([1e4,4e4,7e4], string.([1,4,7]))

        axcontent = unique(vcat(map(x-> Makie.get_labeled_plots(x; merge=true, unique=false),
            [ax_fires, ax_lines, ax_lines_s, ax_ndvi, ax_lines2])))

        Legend(lay_mid_3[1:5,4], vcat(first.(axcontent)...), vcat(last.(axcontent)...), framecolor=:grey45, framewidth=0.5)

        xlims!(ax_lines2, 0,966)
        xlims!(ax_ndvi, 0,966)
        xlims!(ax_lines, 0,966)
        xlims!(ax_lines_s, 0,966)
        xlims!(ax_fires, 0,966)
        
        ax_lines2.xticks = (slice_dates, tempo[slice_dates])
        ax_lines2.xticklabelrotation = π / 4
        ax_lines2.xticklabelalign = (:right, :center)

        ax_fires.xticks = (slice_dates, tempo[slice_dates])
        ax_lines.xticks = (slice_dates, tempo[slice_dates])
        ax_lines_s.xticks = (slice_dates, tempo[slice_dates])
        ax_ndvi.xticks = (slice_dates, tempo[slice_dates])
        hidespines!.([ax_fires, ax_lines, ax_lines2, ax_lines_s, ax_ndvi])
        #linkxaxes!.([ax_lines2, ax_ndvi, ax_lines, ax_lines_s, ax_fires])
        rowgap!(lay_mid_3, 5)
        rowsize!(fig.layout, 1, Auto(2))
        fig
    end
end

doMapa(vars_names)

