*! bumpline v1.0 (10 May 2023): First release
*! Asjad Naqvi (asjadnaqvi@gmail.com, @AsjadNaqvi)


cap prog drop bumparea

prog def bumparea, sortpreserve
version 15
	
syntax varlist(min=2 max=2) [if] [in], by(varname)  ///
	[ top(real 10) DROPOther smooth(real 4) palette(string) alpha(real 80) offset(real 15) RECENter(string) ] ///
	[ format(string) percent LWidth(string) LColor(string) ] ///
	[ LABSize(string) XLABSize(string) XLABAngle(string) ] ///
	[ xtitle(passthru) title(passthru) subtitle(passthru) note(passthru) ] ///
	[ scheme(passthru) name(passthru) xsize(passthru) ysize(passthru)  ] 
	
	
	// check dependencies
	capture findfile colorpalette.ado
	if _rc != 0 {
		display as error "colorpalette package is missing. Install the {stata ssc install colorpalette, replace:colorpalette} and {stata ssc install colrspace, replace:colrspace} packages."
		exit
	}
	
	capture findfile labmask.ado
	if _rc != 0 {
		qui ssc install labutil, replace
		exit
	}	
	

qui {	
preserve	

	keep `varlist' `by'

	gettoken yvar xvar : varlist 
	
	drop if `yvar' == .
	egen _x = group(`xvar')

	gsort `xvar' -`yvar'
	by `xvar': gen _rank = _n	

	bysort `by' : egen _minrank = min(_rank)

	sort `xvar' _rank

	summ _x, meanonly
	local last = r(max)

	gen _mark = 1 if _rank <= `top' & _x==`last'

	bysort `by': egen _maxlast = max(_mark)
	

	if "`dropother'" == "" {
		
		replace _maxlast = 2 if _maxlast==.
		replace `by' = "Others" if _maxlast==2
		replace _rank = . if _maxlast==2
		
		collapse (sum) `yvar' (mean) _rank _x, by(`xvar' `by')
		
		summ _rank
		replace _rank = r(max) + 1 if _rank==.
	}
	else {
		keep if _maxlast==1 // keep top X
	}

	
	egen _group = group(`by')

	// reverse the ranks
	summ _rank, meanonly
	gen _rankrev = r(max) + 1 - _rank

	sort `xvar' _rankrev

	by `xvar': gen double _sumvar = sum(`yvar')
	
	by `xvar' : gen double _ylo = _sumvar[_n-1]
	replace _ylo = 0 if _ylo==.
	gen double _yhi = _sumvar	
	

	// recenter

	if "`recenter'" == "" | "`recenter'"=="middle"  | "`recenter'"=="mid"  | "`recenter'"=="m" {
		bysort year: egen double _locmid = max(_yhi)
		replace _locmid = _locmid / 2

	}

	if "`recenter'" == "bottom" | "`recenter'"=="bot" | "`recenter'"=="b" {
		gen _locmid  =  0
	}	
	
	if "`recenter'" == "top" | "`recenter'"=="t"  {
		bysort year: egen double _locmid  =   max(_yhi)
	}		

	// displace
	replace _ylo = _ylo - _locmid
	replace _yhi = _yhi - _locmid
	gen double _ymid = (_ylo + _yhi) / 2  	
	

	// get a generic sigmoid in place	
	sort `by' `xvar'
	gen _id = _n
	order _id
	
	local points = 50
	local newobs = `points'		
	*expand `=`newobs' + 1'
	expand `newobs' //, gen(mark)
	bysort _id: gen _seq = _n
	
	

	*** for the sigmoid box
		
	sort `by' `xvar' _seq
	bysort _id: gen double _xnorm =  ((_n - 1) / (`newobs' - 1)) // scale from 0 to 1

	gen double _ynorm =  (1 / (1 + (_xnorm / (1 - _xnorm))^-`smooth'))



	// fill in the indeterminate points
	replace _ynorm = 0 if _seq==1
	replace _ynorm = 1 if _seq==`newobs'	
	
		
	// we interporate upto x-1 items
	levelsof _x, local(lvls)
	local items = r(r) - 1
	
	
	gen double _xval = .  // _xnorm + `xvar'
	gen double _yvallo = .
	gen double _yvalhi = .
	

	by `by' (`xvar'), sort: gen _tagctry = 1 if (_n==_N)
	gen _taglast = _x==`last' & _tagctry==1
	gen _ranklast = _rank if _x==`last'
	

	sort _group `xvar' _seq
	levelsof _group, local(grp)
	
	forval i = 1/`items' {
		
		local j = `i' + 1		
		foreach y of local grp {  // y
		
			// x
			summ `xvar' if _group==`y' & _x==`i', meanonly
			local xmin = r(min)
			summ `xvar' if _group==`y' & _x==`j', meanonly 
			local xmax = r(max)
			replace _xval = (`xmax' - `xmin') * (_xnorm - 0) / (1 - 0) + `xmin' if _x==`i' & _group==`y'
			
			
			// y
			summ _ylo if _group==`y' & _x==`i', meanonly
			local ymin = r(min)
			summ _ylo if _group==`y' & _x==`j', meanonly 
			local ymax = r(max)
			replace _yvallo = (`ymax' - `ymin') * (_ynorm - 0) / (1 - 0) + `ymin' if _x==`i' & _group==`y'
					
			summ _yhi if _group==`y' & _x==`i', meanonly
			local ymin = r(min)
			summ _yhi if _group==`y' & _x==`j', meanonly 
			local ymax = r(max)
			replace _yvalhi = (`ymax' - `ymin') * (_ynorm - 0) / (1 - 0) + `ymin' if _x==`i' & _group==`y'
			
			
			summ _ranklast if _group==`y', meanonly
			replace _ranklast = r(max) if _group==`y' & _ranklast==.
		
		}
	}
	
	
	if "`lwidth'" == "" local lwidth 0.2
	if "`lcolor'" == "" local lcolor white
	if "`palette'" == "" {
		local palette tableau	
	}
	else {
		tokenize "`palette'", p(",")
		local palette  `1'
		local poptions `3'
	}	
	
	levelsof _ranklast, local(lvls)
	local items = r(r)

	local counter = 1
	
	foreach i of local lvls {
		
		colorpalette `palette', nograph n(`items') `poptions'

		local areas `areas' (rarea _yvalhi _yvallo _xval if _ranklast==`i', fi(100) fc("`r(p`counter')'%`alpha'") lc(`lcolor') lw(`lwidth'))
	
	
		local counter = `counter' + 1
	}

	
	// control the x axis
	summ `xvar', meanonly
	local xrmin = `r(min)'
	summ `xvar', meanonly
	local xrmax = r(max) + ((r(max) - r(min)) * (`offset' / 100)) 
	
	// control the y axis
	summ _yhi, meanonly
	
	if "`recenter'" == "" | "`recenter'" == "middle" | "`recenter'" == "mid"  | "`recenter'" == "m" { 

		local ymin = -1 * abs(r(min)) * 1.05
		local ymax =      abs(r(min)) * 1.05
	}
	
	if "`recenter'" == "bottom" | "`recenter'" == "bot"  | "`recenter'" == "b" { 

		local ymin = 0
		local ymax = abs(r(min)) * 1.05
	}	

	if "`recenter'" == "top" | "`recenter'" == "t"  { 

		local ymin = -1 * abs(r(min)) * 1.05
		local ymax =      0
	}		
	
	
	if `"`format'"' == "" {
		if "`percent'" == "" {
			local format "%12.0fc"
		}
		else {
			local format "%5.2f"
		}
	}
	
	
		if "`percent'" == "" {
			gen labnum = " (" + string(`yvar', "`format'") + ")" if _taglast==1
		}
		else {
			summ `yvar' if _taglast==1, meanonly
			gen labnum = " (" + string((`yvar'/`r(sum)')* 100, "`format'") + "%)" if _taglast==1
		}	
	
	
	gen _blab = `by' + labnum if _taglast==1
	
	
	if "`labsize'" == "" local labsize 2.8
	if "`xlabsize'" == "" local xlabsize 2.5
	if "`ylabsize'" == "" local ylabsize 2.5
	if "`xlabangle'" == "" local xlabangle 0
	
	levelsof `xvar'
	local xlist = "`r(levels)'"
	
	// draw
	twoway ///
		(scatter _ymid `xvar' if _taglast==1, mlabel(_blab) mlabpos(3) mlabsize(`labsize') mc(none) mlabgap(1.5)) ///
		`areas' ///
		, ///
		`title' `note' `subtitle' `xsize' `ysize' `name' ///
		xlabel(`xlist', labsize(`xlabsize') angle(`xlabangle')) ///
		ylabel(`ymin' `ymax', nolabels noticks nogrid) ///
		yscale(noline) ///
		xscale(noline range(`xrmin' `xrmax')) ///
		legend(off) 
		
	*/
	
	
restore
}
	
end



************************
***** END OF FILE ******
************************