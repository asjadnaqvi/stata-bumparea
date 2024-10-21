{smcl}
{* 21Oct2024}{...}
{hi:help bumparea}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-bumparea":bumparea v1.4 (GitHub)}}

{hline}

{title:bumparea}: A Stata package for bump or ribbon plots. 


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:bumparea} {it:y x} {ifin} {weight}, {cmd:by}(varname) 
        {cmd:[} {cmd:top}({it:num}) {cmdab:dropo:ther} {cmd:smooth}({it:num}) {cmd:palette}({it:str}) {cmd:labcond}({it:str}) {cmd:offset}({it:num}) {cmd:alpha}({it:num}) {cmd:stat}({it:mean}|{it:sum}) 
          {cmdab:lc:olor}({it:str}) {cmdab:lw:idth}({it:str}) {cmd:percent} {cmd:format}({it:fmt}) {cmdab:rec:enter}(mid|top|bot) {cmd:colorby}({it:name}) {cmd:colorvar}({it:var}) {cmdab:colo:ther}({it:str}) 
          {cmd:wrap}({it:num}) {cmdab:labs:ize}({it:str}) {cmdab:labc:olor}({it:str}) {cmdab:laba:ngle}({it:str}) {cmdab:labg:ap}({it:str}) {cmd:labprop}  {cmd:labscale}({it:num}) * {cmd:]}


{p 4 4 2}
The options are described as follows:

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt bumparea y x, by(group)}}The command requires a numeric {it:y} variable and a numeric {it:x} variable. The x variable is usually a time variable.
The {opt by()} variable defines the groupings.{p_end}

{p2coldent : {opt top(num)}}The number of rows to show in the graph. The default option is {opt top(10)}. Non {opt top()} values are grouped in the "Others" category.{p_end}

{p2coldent : {opt stat(mean|sum)}}If there are multiple observations per {opt by()} variables, then by default the program take the sum by triggering {opt stat(sum)}.
Even though these options is available, preparing the data beforehand is highly recommended.{{p_end}

{p2coldent : {opt dropo:ther}}Drop the "Others" category from the graph and just show the {opt top()} categories.{p_end}

{p2coldent : {opt smooth(num)}}The smoothing parameter that ranges from 1-8. The default is {opt smooth(4)}. A value of 1 shows straight lines,
while a value of 8 shows step-wise jumps.{p_end}

{p2coldent : {opt palette(str)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt colorby(name)}}Color by alphabetical values. This option is still beta and only takes only one argument. This option is highly useful when
making several bumparea plots for comparison to assign the same color to the same {opt by()} category. Otherwise, the color order is determined by the rank
order.{p_end}

{p2coldent : {opt colorvar(var)}}Color by a predefined variable. Define a color variable that takes on values in increments of one. This is to fully control and customize the 
colors assigned.{p_end}

{p2coldent : {opt colo:ther(var)}}Color of the other category. Default is {opt colo(gs12)}.{p_end}

{p2coldent : {opt alpha(num)}}The transparency of area fills. Default is {opt alpha(80)} for 80% transparency.{p_end}

{p2coldent : {opt offset(num)}}Extends the x-axis range to accommodate labels. The default value is {it:15} for 15% of {it:xmax-xmin}.{p_end}

{p2coldent : {opt rec:enter(options)}}This option changes where the graph is recentered. The default option is {opt rec:enter(middle)}. Additional options are {opt rec:enter(top)} 
or {opt rec:enter(bottom)}. For brevity, the following can be specified: {it:middle} = {it:mid} = {it:m}, {it:top} = {it:t}, {it:bottom} = {it:bot} = {it:b}.{p_end}

{p2coldent : {opt percent}}Shows the percentage share for the {opt by()} categories. Default is actual values.{p_end}

{p2coldent : {opt format(fmt)}}Format the values of the {opt by()} categories. Default value is {opt format(%12.0fc)} for actual values and {opt format(%5.2f)} for the {opt percent} option.{p_end}

{p2coldent : {opt lw:idth(str)}}The line width of the area stroke. The default is {opt lw(0.2)}.{p_end}

{p2coldent : {opt lc:olor(str)}}The line color of the area stroke. The default is {opt lc(white)}.{p_end}

{p2coldent : {opt wrap(num)}}Wrap the labels after a number of characters. Word boundaries are respected.{p_end}

{p2coldent : {opt labs:ize(str)}}Size of the ribbon labels. Default is {opt labs(2.8)}.{p_end}

{p2coldent : {opt labc:olor(str)}}Color of the ribbon labels. Default is {opt labc(black)}.{p_end}

{p2coldent : {opt laba:ngle(str)}}Angle of the ribbon labels. Default is {opt laba(0)} for horizontal.{p_end}

{p2coldent : {opt labg:ap(str)}}Gap of the ribbon labels. Default is {opt labg(1.5)}.{p_end}

{p2coldent : {opt labprop}}Make ribbon labels proportional to their relative value.{p_end}

{p2coldent : {opt labscale(num)}}Scale factor of {opt labprop}. Default is {opt labscale(0.3333)}. Values closer to zero result in more exponential scaling, while values closer
to one are almost linear scaling.{p_end}

{p2coldent : {opt *}}All other standard twoway options not elsewhere specified.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

Please make sure that you have the latest versions of the following packages installed:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}
{stata ssc install graphfunctions, replace}


{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-bumparea":GitHub}.

{hline}


{title:Package details}

Version      : {bf:bumparea} v1.4
This release : 21 Oct 2024
First release: 10 Apr 2023
Repository   : {browse "https://github.com/asjadnaqvi/stata-bumparea":GitHub}
Keywords     : Stata, graph, bump chart, ribbon plot
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}


{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-bumparea/issues":GitHub} by opening a new issue.


{title:Citation guidelines}

Suggested citation guidlines for this package:

Naqvi, A. (2024). Stata package "bumparea" version 1.4. Release date 21 Oct 2024. https://github.com/asjadnaqvi/stata-bumparea.

@software{bumparea,
   author = {Naqvi, Asjad},
   title = {Stata package ``bumparea''},
   url = {https://github.com/asjadnaqvi/stata-bumparea},
   version = {1.4},
   date = {2024-10-21}
}


{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: An update}. University of Bern Social Sciences Working Papers No. 43. 


{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb graphfunctions}, {helpb joyplot}, 
	{helpb marimekko}, {helpb polarspike}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb splinefit}, {helpb streamplot}, {helpb sunburst}, {helpb ternary}, {helpb treecluster}, {helpb treemap}, {helpb trimap}, {helpb waffle}

or visit {browse "https://github.com/asjadnaqvi":GitHub}.	