var documenterSearchIndex = {"docs":
[{"location":"plot_results/#Setup","page":"Results (ERP-Style)","title":"Setup","text":"","category":"section"},{"location":"plot_results/","page":"Results (ERP-Style)","title":"Results (ERP-Style)","text":"using Unfold\nusing UnfoldMakie\nusing StatsModels # can be removed in Unfold v0.3.5\nusing DataFrames\nusing CairoMakie\n\n\ninclude(joinpath(dirname(pathof(Unfold)), \"../test/test_utilities.jl\") ) # to load data\ndata, evts = loadtestdata(\"test_case_3b\");\nbasisfunction = firbasis(τ=(-0.4,.8),sfreq=50,name=\"stimulus\")\nf  = @formula 0~1+conditionA+continuousA\n\nbfDict = Dict(Any=>(f,basisfunction))\n\nm = fit(UnfoldModel,bfDict,evts,data); \nresults = coeftable(m); nothing","category":"page"},{"location":"plot_results/#Default-Plot","page":"Results (ERP-Style)","title":"Default Plot","text":"","category":"section"},{"location":"plot_results/","page":"Results (ERP-Style)","title":"Results (ERP-Style)","text":"plot_results(results)","category":"page"},{"location":"plot_results/#With-StandardErrors","page":"Results (ERP-Style)","title":"With StandardErrors","text":"","category":"section"},{"location":"plot_results/","page":"Results (ERP-Style)","title":"Results (ERP-Style)","text":"se_solver = solver=(x,y)->Unfold.solver_default(x,y,stderror=true)\nm = Unfold.fit(UnfoldModel,bfDict,evts,data.+10 .*rand(length(data)),solver=se_solver)\n\nresults = coeftable(m)\nplot_results(results,stderror=true)","category":"page"},{"location":"plot_results/#Two-different-events","page":"Results (ERP-Style)","title":"Two different events","text":"","category":"section"},{"location":"plot_results/","page":"Results (ERP-Style)","title":"Results (ERP-Style)","text":"\ndata, evts = loadtestdata(\"test_case_4b\");\nbf1 = firbasis(τ=(-0.4,.8),sfreq=50,name=\"stimulusA\")\nbf2 = firbasis(τ=(-0.2,1.2),sfreq=50,name=\"stimulusB\")\n\nf  = @formula 0~1\nbfDict = Dict(\"eventA\"=>(f,bf1),\n              \"eventB\"=>(f,bf2))\n\nresults = coeftable(fit(UnfoldModel,bfDict,evts,data.+10 .*rand(length(data)),solver=se_solver,eventcolumn=\"type\"))\n\nplot_results(results,stderror=true)","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = UnfoldMakie","category":"page"},{"location":"#UnfoldMakie","page":"Home","title":"UnfoldMakie","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for UnfoldMakie.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [UnfoldMakie]","category":"page"},{"location":"plot_design/#Setup","page":"DesignMatrices","title":"Setup","text":"","category":"section"},{"location":"plot_design/","page":"DesignMatrices","title":"DesignMatrices","text":"using Unfold\nusing UnfoldMakie\nusing StatsModels # can be removed in Unfold v0.3.5\nusing DataFrames\nusing CairoMakie\n\n\ninclude(joinpath(dirname(pathof(Unfold)), \"../test/test_utilities.jl\") ) # to load data\ndata, evts = loadtestdata(\"test_case_3b\");\nbasisfunction = firbasis(τ=(-0.4,.8),sfreq=50,name=\"stimulus\")\nf  = @formula 0~1+conditionA+continuousA\n\n\nufMass = UnfoldLinearModel(Dict(Any=>(f,-0.4:1/50:.8)))\ndesignmatrix!(ufMass, evts)","category":"page"},{"location":"plot_design/#Plot-Designmatrix","page":"DesignMatrices","title":"Plot Designmatrix","text":"","category":"section"},{"location":"plot_design/","page":"DesignMatrices","title":"DesignMatrices","text":"plot(designmatrix(ufMass))","category":"page"},{"location":"plot_design/","page":"DesignMatrices","title":"DesignMatrices","text":"Often it is helpful to sort the designmatrix","category":"page"},{"location":"plot_design/","page":"DesignMatrices","title":"DesignMatrices","text":"plot(designmatrix(ufMass),sort=true)","category":"page"},{"location":"plot_design/","page":"DesignMatrices","title":"DesignMatrices","text":"You can also turn columnwise standardization off","category":"page"},{"location":"plot_design/","page":"DesignMatrices","title":"DesignMatrices","text":"plot(designmatrix(ufMass),standardize=false)","category":"page"},{"location":"plot_design/#Plot-Timeexpanded-Designmatric","page":"DesignMatrices","title":"Plot Timeexpanded Designmatric","text":"","category":"section"},{"location":"plot_design/","page":"DesignMatrices","title":"DesignMatrices","text":"To see the result of the timeexpanded designmatrix, we can simply call plot on an Timeexpanded UnfoldObject","category":"page"},{"location":"plot_design/","page":"DesignMatrices","title":"DesignMatrices","text":"bfDict = Dict(Any=>(f,basisfunction))\nufCont = UnfoldLinearModelContinuousTime(bfDict)\ndesignmatrix!(ufCont, evts) # add the designmatrix but don't fit\n\nplot(designmatrix(ufCont))","category":"page"},{"location":"plot_design/","page":"DesignMatrices","title":"DesignMatrices","text":"Currently there is no easy way to get the non-timeexpanded designmatrix from a UnfoldLinearModelContinuousTime","category":"page"}]
}
