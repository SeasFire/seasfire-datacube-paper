using GLMakie
using CairoMakie
CairoMakie.activate!()

x = [1,2,4,8,16]
y = [0.611, 0.6078, 0.5995, 0.5953, 0.5836]
fig = with_theme( theme_latexfonts()) do
    fig = Figure(resolution=(600,400), fontsize=16)
    ax = Axis(fig[1,1]; xscale=log2, title="Model performance per forecasting window",
        xlabel = "Forecasting Window (8-days)",
        ylabel = "AUPRC (%)")
    ax.xticks = (x, string.(x))
    scatterlines!(ax, x,y; linestyle = :dash, label = "U-Net++")
    ylims!(ax, 0.58, 0.62)
    axislegend(ax, framecolor = :grey35)
    fig
end
save("Figure_7_unet_results.pdf", fig)