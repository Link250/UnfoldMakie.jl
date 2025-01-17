
using GeometryBasics
using Makie

"""
    PlotConfig(<plotname>)

This struct is used as the configuration and simple plot method for an UnfoldMakie plot.

## Values for `<plotname>`
- `:line`: Line Plot
- `:butterfly`: Butterfly Plot
- `:erp`: ERP Image
- `:design`: Designmatrix
- `:topo`: Topo Plot
- `:eegtopo`: EEG Topo Plot
- `:paraCoord`: Parallel Coordinates Plot

## Attributes

The PlotConfig includes multiple Named Tuples with settings for different areas.
Their attributes can be set through setter Methods callable on the PlotConfig instance:

- `setExtraValues(kwargs...)`
- `setLayoutValues(kwargs...)`
- `setVisualValues(kwargs...)`
- `setMappingValues(kwargs...)`
- `setLegendValues(kwargs...)`
- `setColorbarValues(kwargs...)`
- `setAxisValues(kwargs...)`

## Plotting

The config includes a simple way to create a plot with the choosen settings.
The used plot-function is choosen based on the given plot type in the constructor.

`plot(plotData::Any; kwargs...)`

See the plot function of each plot type for more informations about data types and possibly additional kwargs.

Called functions per `<plotname>`:
- `:line` -> `plot_line(...)`
- `:butterfly` -> `plot_line(...)`
- `:erp` -> `plot_erp(...)`
- `:design` -> `plot_design(...)`
- `:topo` -> `plot_topo(...)`
- `:eegtopo` -> `plot_topo(...)`
- `:paraCoord` -> `plot_paraCoord(...)`

Following the bang convention, use this to exectute the !-version of each function respectively:

`plot!(f::Union{GridPosition, Figure}, plotData::Any; kwargs...)`


# Example

`config = PlotConfig(:line)`

`config.setLegendValues(nbanks=2)`

`config.setLayoutValues(showLegend=true, legendPosition=:bottom)`

`config.setMappingValues(color=:coefname, group=:coefname)`

`config.plot(data)`


"""
mutable struct PlotConfig
    plotType::Any
    extraData::NamedTuple
    layoutData::NamedTuple
    visualData::NamedTuple
    mappingData::NamedTuple
    legendData::NamedTuple
    colorbarData::NamedTuple
    axisData::NamedTuple

    setExtraValues::Function    
    setLayoutValues::Function
    setVisualValues::Function
    setMappingValues::Function
    setLegendValues::Function
    setColorbarValues::Function
    setAxisValues::Function

    # removes all varaibles from mappingData which aren't columns in input plotData
    resolveMappings::Function

    plot::Function
    plot!::Function

    "plot types: :line, :design, :topo, :eegtopo, :butterfly, :erp, :paracoord"
    function PlotConfig(pltType)
        this = new()

        this.plotType = pltType
        # standard values for ALL plots
        this.extraData = (
            # lineplot vars
            categoricalColor=true,
            categoricalGroup=true,
            stderror=false,
            pvalue=[],
            # butterfly plot vars
            topoLegend=false,
            # designmatrix vars
            xTicks=nothing,
            standardizeData=true,
            # Designmatrix and erp image var 
            sortData=true,
            # erp image var
            meanPlot=false,
            erpBlur=10,
            # paracoord fix-values
            pc_aspect_ratio = 0.55,
            pc_right_padding = 15,
            pc_left_padding = 25,
            pc_top_padding = 26,
            pc_bottom_padding = 16,
            pc_tick_label_size = 14,
        )
        this.layoutData = (;
            showLegend=true,
            legendPosition=:right,
            xlabelFromMapping=:x,
            ylabelFromMapping=:y,
            useColorbar=false,
        )
        this.visualData = (;
            colormap=:haline,
        )
        this.mappingData = (
            x=(:x, :time),
            y=(:y, :estimate, :yhat),
        ) 
        this.legendData = (;
            orientation = :vertical,
            tellwidth = true,
            tellheight = false
        )
        this.colorbarData = (;
            vertical = true,
            tellwidth = true,
            tellheight = false
        )

        this.axisData = (;)
        
        # setter for very plot specific Data
        this.setExtraValues = function (;kwargs...)
            this.extraData = merge(this.extraData, kwargs)
            return this
        end
        this.setLayoutValues = function (;kwargs...)
            # position affects multiple values in legendData
            kwargsVals = values(kwargs)
            if haskey(kwargsVals, :legendPosition)
                if kwargsVals.legendPosition == :right
                    sdtLegVal = (;tellwidth = true, tellheight = false, orientation = :vertical)
                    sdtBarVal = (;tellwidth = true, tellheight = false)
                elseif kwargsVals.legendPosition == :bottom
                    sdtLegVal = (;tellwidth = false, tellheight = true, orientation = :horizontal)
                    sdtBarVal = (;tellwidth = false, tellheight = true, vertical=false, flipaxis=false)
                end
                this.legendData = merge(this.legendData, sdtLegVal)
                this.colorbarData = merge(this.colorbarData, sdtBarVal)
            end

            this.layoutData = merge(this.layoutData, kwargs)
            return this
        end
        this.setVisualValues = function (;kwargs...)
            this.visualData = merge(this.visualData, kwargs)
            return this
        end
        this.setMappingValues = function (;kwargs...)
            this.mappingData = merge(this.mappingData, kwargs)
            return this
        end
        this.setLegendValues = function (;kwargs...)
            this.legendData = merge(this.legendData, kwargs)
            return this
        end
        this.setColorbarValues = function (;kwargs...)
            this.colorbarData = merge(this.colorbarData, kwargs)
            return this
        end
        this.setAxisValues = function (;kwargs...)
            if :xlabel ∈ keys(kwargs)
                this.layoutData = merge(this.layoutData, (;xlabelFromMapping = nothing))
            end
            if :ylabel ∈ keys(kwargs)
                this.layoutData = merge(this.layoutData, (;ylabelFromMapping = nothing))
            end
            this.axisData = merge(this.axisData, kwargs)
            return this
        end

        # standard values for each plotType
        if (pltType == :line)
            this.setMappingValues(
                color=(:color, :coefname),
            )
            this.setLayoutValues(
                hidespines = (:r, :t)
            )
        elseif (pltType == :design)
            this.setLayoutValues(
                useColorbar = true
            )
            this.setLayoutValues(
                xlabelFromMapping=nothing,
                ylabelFromMapping=nothing,
            )
            this.setAxisValues(
                xticklabelrotation=pi/8
            )
        elseif (pltType == :topo || pltType == :eegtopo)
            this.setLayoutValues(
                showLegend= pltType == :topo,
                xlabelFromMapping=nothing,
                ylabelFromMapping=nothing,
                useColorbar = true,
                hidespines = (),
                hidedecorations = ()
            )
            this.setVisualValues(
                contours=(color=:white, linewidth=2),
                label_scatter=true,
                label_text=true,
                bounding_geometry=(pltType == :topo) ? Rect : Circle,
                colormap=Reverse(:RdBu),
            )
            this.setMappingValues(
                topodata=(:topodata, :data, :y),
                topoPositions=(:pos, :positions, :position, :topoPositions, :x, :nothing),
                topoLabels=(:labels, :label, :topoLabels, :sensor, :nothing),
                topoChannels=(:channels, :channel, :topoChannel, :nothing),
            )
        elseif (pltType == :butterfly)
            this.setExtraValues(topoLegend = true)
            this.setLayoutValues(
                showLegend = false,
                hidespines = (:r, :t)
            )
            this.setMappingValues(
                topoPositions=(:pos, :positions, :position, :topoPositions, :x, :nothing),
                topoLabels=(:labels, :label, :topoLabels, :sensor, :nothing),
                topoChannels=(:channels, :channel, :topoChannel, :nothing),
            )
        elseif (pltType == :erp)
            this.setExtraValues(
                sortData = true,
            )
            this.setLayoutValues(
                useColorbar = true,
            )
            this.setColorbarValues(
                label = "Voltage [µV]"
            )
            this.setAxisValues(
                xlabel = "Time",
                ylabel = "Sorted trials"
            )
        elseif (pltType == :paracoord)
            this.setExtraValues(
                sortData = true,
            )
            this.setLayoutValues(
                xlabelFromMapping=:channel,
                ylabelFromMapping=:y,
                hidespines=(),
                hidedecorations=(;label = false),
            )
            this.setMappingValues(
                channel=:channel,
                category=:category,
                time=:time,
            )
        end

        # removes all varaibles from mappingData which aren't columns in input plotData
        this.resolveMappings = function (plotData)
            function isColumn(col)
                string(col) ∈ names(plotData)
            end
            # filter columns to only include the ones that are in plotData, or throw an error if none are
            function getAvailable(key, choices)
                available = choices[keys(choices)[isColumn.(collect(choices))]]
                if length(available) >= 1
                    return available[1]
                else
                    return (:nothing ∈ collect(choices)) ?
                        nothing :
                        @error("default columns for $key = $choices not found, user must provide one by using plotconfig.setMappingValues()")
                end
            end
            # have to use Dict here because NamedTuples break when trying to map them with keys/indices
            mappingDict = Dict()
            for (k,v) in pairs(this.mappingData)
                mappingDict[k] = isa(v, Tuple) ? getAvailable(k, v) : v
            end
            this.mappingData = (;mappingDict...)
        end

        this.plot = function (plotData::Any; kwargs...)
            this.plot!(Figure(), plotData; kwargs...)
        end

        this.plot! = function (f::Union{GridPosition, Figure}, plotData::Any; kwargs...)
            if (this.plotType == :design)
                plot_design!(f, plotData, this)
            elseif (this.plotType == :erp)
                plot_erp!(f, plotData, this)
            elseif (this.plotType == :line || this.plotType == :butterfly)
                plot_line!(f, plotData, this)
            elseif (this.plotType == :paracoord)
                plot_paraCoord!(f, plotData, this; kwargs...)
            elseif (this.plotType == :topo || this.plotType == :eegtopo)
                plot_topo!(f, plotData, this; kwargs...)
            else
                @error "Unknown plot type, cannot use plot function."
            end
        end

        return this
    end
end