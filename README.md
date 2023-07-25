
![bumparea-1](https://github.com/asjadnaqvi/stata-bumparea/assets/38498046/08bed45f-5c89-4047-bad8-cd6892690b98)

![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-bumparea) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-bumparea) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-bumparea) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-bumparea) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-bumparea)

---

[Installation](#Installation) | [Syntax](#Syntax) | [Examples](#Examples) | [Feedback](#Feedback) | [Change log](#Change-log)

---

# bumparea v1.2
(06 Jun 2023)

## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

SSC (**v1.1**):

```
ssc install bumparea, replace
```

GitHub (**v1.2**):

```
net install bumparea, from("https://raw.githubusercontent.com/asjadnaqvi/stata-bumparea/main/installation/") replace
```



The `palettes` package is required to run this command:

```
ssc install palettes, replace
ssc install colrspace, replace
```

Even if you have these packages installed, please check for updates: `ado update, update`.

If you want to make a clean figure, then it is advisable to load a clean scheme. These are several available and I personally use the following:

```
ssc install schemepack, replace
set scheme white_tableau  
```

You can also push the scheme directly into the graph using the `scheme(schemename)` option. See the help file for details or the example below.

I also prefer narrow fonts in figures with long labels. You can change this as follows:

```
graph set window fontface "Arial Narrow"
```


## Syntax

The syntax for **v1.2** is as follows:

```stata
bumparea y x [if] [in], by(varname) 
                [ top(num) dropother smooth(num) palette(str) labcond(str) offset(num) alpha(num) 
                  lcolor(str) lwidth(str) percent format(fmt) recenter(mid|top|bot) colorby(name) colorvar(var) colother(str)
                  xlabel(str) xtitle(str) ytitle(str) title(str) subtitle(str) note(str) 
                  ysize(num) xsize(num) scheme(str) name(str) saving(str) ]
```

See the help file `help bumparea` for details.

The most basic use is as follows:

```
bumparea y x, by(group)
```

where `y` is a numerical variable we want to plot and `x` is the time dimension. Both need to be numeric. The `by()` is the category variable.



## Examples

Load the Stata dataset

```
use "https://github.com/asjadnaqvi/stata-bumparea/blob/main/data/owid_emissions_reduced.dta?raw=true", clear
drop if iso_code==""
keep if year >= 1990
```

Let's test the `bumparea` command:


```
bumparea total_ghg year, by(country) 
```

<img src="/figures/bumparea1.png" height="400">


```
bumparea total_ghg year, by(country) top(10) ///
	xsize(2) ysize(1) 
```

<img src="/figures/bumparea2.png" height="400">


### percent
```
bumparea total_ghg year, by(country) top(10) ///
	percent labs(2) xsize(2) ysize(1) 	
```

<img src="/figures/bumparea3.png" height="400">

### dropother

```
bumparea total_ghg year, by(country) top(10) ///
	dropother labs(2) xsize(2) ysize(1) 
```

<img src="/figures/bumparea4.png" height="400">

```
bumparea total_ghg year, by(country) top(10) ///
	dropother percent labs(2) xsize(2) ysize(1) 	
```

<img src="/figures/bumparea5.png" height="400">

```
bumparea total_ghg year, by(country) ///
	top(12) dropother labs(2) xsize(2) ysize(1) 
```

<img src="/figures/bumparea6.png" height="400">

### smooth

```
bumparea total_ghg year, by(country) top(10) ///
	smooth(1) dropother labs(2) xsize(2) ysize(1) 	
```

<img src="/figures/bumparea7.png" height="400">

```
bumparea total_ghg year, by(country) top(10) ///
	smooth(8) dropother labs(2) xsize(2) ysize(1) 	
```

<img src="/figures/bumparea8.png" height="400">

### recenter

```
bumparea total_ghg year, by(country) top(10) ///
	recenter(top) dropother labs(2) xsize(2) ysize(1) 	
```

<img src="/figures/bumparea9.png" height="400">

```
bumparea total_ghg year, by(country) top(10) ///
	recenter(bot) dropother labs(2) xsize(2) ysize(1) 		
```

<img src="/figures/bumparea10.png" height="400">



### alpha and lines

```
bumparea total_ghg year, by(country) top(10) ///
	lc(black) lw(0.03) dropother labs(2) xsize(2) ysize(1) 	
```

<img src="/figures/bumparea11.png" height="400">

### colors

```
bumparea total_ghg year, by(country) top(10) ///
	lc(black) lw(0.03) palette(reds, reverse) dropother labs(2) xsize(2) ysize(1) 	
```

<img src="/figures/bumparea12.png" height="400">

```
bumparea total_ghg year, by(country) top(10) ///
	lc(black) lw(0.03) palette(viridis) dropother labs(2) xsize(2) ysize(1) 
```

<img src="/figures/bumparea13.png" height="400">

```
bumparea total_ghg year, by(country) top(10) ///
	lc(black) lw(0.03) palette(CET C6) alpha(100) dropother labs(2) xsize(2) ysize(1) 			
```

<img src="/figures/bumparea14.png" height="400">

```	
bumparea total_ghg year, by(country) top(10) ///
	lc(black) lw(0.03) palette(CET C6) alpha(50) dropother labs(2) xsize(2) ysize(1) 		
```

<img src="/figures/bumparea15.png" height="400">

### all together

```
bumparea total_ghg year, by(country) smooth(6) palette(CET L20) labs(2) ///
	top(10) dropother recenter(mid) alpha(90) lw(0.15) xlaba(45) ///
	title("Top 10 countries by annual GHG emissions", size(6)) ///
			note("Source: OWID.") ///
			xsize(2) ysize(1) 
```

<img src="/figures/bumparea16.png" height="400">


### custom x axis

```
use "https://github.com/asjadnaqvi/stata-bumparea/blob/main/data/owid_emissions_reduced.dta?raw=true", clear
drop if iso_code==""
keep if inlist(year, 1990, 1993, 1997, 2000, 2005, 2007, 2010, 2014, 2017, 2019)

bumparea total_ghg year, by(country) smooth(8) palette(CET L08) labs(2) ///
	top(15) dropother recenter(mid) alpha(80) lw(0.1) xlaba(45) ///
	title("Top 10 countries by annual GHG emissions", size(6)) ///
			note("Source: OWID. bumparea package. @AsjadNaqvi") ///
			xsize(2) ysize(1)
```

<img src="/figures/bumparea17.png" height="400">


### v1.2 options 

```
bumparea total_ghg year, by(country) top(10) ///
			xsize(2) ysize(1) 		
```

<img src="/figures/bumparea18.png" height="400">

```
bumparea total_ghg year, by(country) top(10) colother(gs6) ///
			xsize(2) ysize(1) 		
```

<img src="/figures/bumparea19.png" height="400">

```
bumparea total_ghg year, by(country) top(10) colorby(name) ///
			xsize(2) ysize(1		
```

<img src="/figures/bumparea20.png" height="400">

```
cap drop cats
gen cats = .
replace cats = 1 if inlist(country, "Indonesia", "Japan")
replace cats = 2 if inlist(country, "United States", "Canada")
replace cats = 3 if inlist(country, "Iran", "Saudi Arabia")
replace cats = 4 if inlist(country, "China")
			
bumparea total_ghg year, by(country) top(10) colorvar(cats) ///
			xsize(2) ysize(1) colo(white)			
```

<img src="/figures/bumparea21.png" height="400">


## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-bumparea/issues) to report errors, feature enhancements, and/or other requests.


## Change log

**v1.2 (25 Jul 2023)**
- Several new options added: `colorby(name)` to alpha sort the colors, `colorby(var)` to color using a custom `var`, `colother()` to define the color of the "Other" category.
- A bug with labels fixed (found by Marc Kaulisch)
- Better checks for `by()` variables.
- `saving()` option added. 
- Several small bug fixes and code optimizations.

**v1.11 (06 Jun 2023)**
- Minor bug fixes, checks, enhancements. 

**v1.1 (28 May 2023)**
- Fixed `if` and `in` conditions that were not passing correctly.
- Added checks for duplicates.
- Minor code cleanups, updates to defaults, and help file.

**v1.0 (10 Apr 2023)**
- Public release.







