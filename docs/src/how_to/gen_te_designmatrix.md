# [Generate a Timeexpanded Designmatrix](@id ht_gen_te_designmatrix)

In the following we discuss how to generate a Timeexpanded Designmatrix.

You start by repeating the first steps (up to and including the Data segment) of the [Designmatrix Visualization tutorial](@ref dm_vis).
Afterwards you continue as follows.

## Plot Timeexpanded Designmatrix

In the code below, data of the `Unfold` module was used.
To display a timeexpanded designmatrix we add the following code:
```
bfDict = Dict(Any=>(f,basisfunction))
ufCont = UnfoldLinearModelContinuousTime(bfDict)
```
The following code will result in the default configuration.
```
cDesign = PlotConfig(:design)
```
At this point you can detail changes you want to make to the visualization through the plot config. These are detailed further below. 

We set `sortData=false`, as it makes no sense to sort data for timeexpanded designmatrices (and it is `true` by default).
```
cDesign.setExtraValues(sortData=false)
```

This is how you plot the timeexpanded designmatrix.
```
cDesign.plot(designmatrix!(ufCont, evts))
```

![Default Timeexpanded Designmatrix](../images/designmatrix_te_default.png)
Note that without further adjustments in the configuration, you may experience cluttering of labels. 
As you can see, this is the case here. 

In order to avoid the cluttering problem, we can limit the number of labels by changing the `xTicks`.
```
cDesign.setExtraValues(xTicks=12)
```
In this case it was set to 12 labels on the x-axis.


When plotting the result is as follows:

![Label Limited Timeexpanded Designmatrix](../images/designmatrix_te_12_labels.png)
As you can see labels are cut off to the left.
In the [corresponding How To section](@ref ht_soobl) you can see a workaroundfor it.