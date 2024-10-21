*! bumparea v1.4 (21 Oct 2024)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

*v1.4 (21 Oct 2024): several bug fixes. weights added. wrap updated. xlabel() is fully pass through. labgap(), labc(), labangle() added.
*v1.31 (11 Jun 2024): added wrap() for label wraps
*v1.3  (26 May 2024): added collapse, fillin.
*v1.21 (15 Jan 2024): minor cleanups, updates to defaults  
*v1.2  (25 Jul 2023): Bug fixed on labels. Better checks for by() variable. colorby(name), colorother(), colorvar() added.
*v1.11 (26 Jun 2023): Minor bug fixes + additional checks
*v1.1  (28 May 2023): Minor code cleanups. if/in added. duplicates check added.
*v1.0  (10 May 2023): First release

cap prog drop bumparea

prog def bumparea, sortpreserve
version 15
	
syntax varlist(min=2 max=2 numeric) [if] [in] [aw fw pw iw/], by(varname)  ///
	[ top(real 10) DROPOther smooth(real 4) palette(string) alpha(real 80) offset(real 15) RECENter(string) ] ///
	[ format(string) percent LWidth(string) LColor(string) ] ///
	[ LABSize(string) ] ///
	[ saving(passthru) colorby(name) COLOther(string) colorvar(varname numeric)  ] /// // v1.2
	[ stat(string) wrap(numlist >0 max=1) * labprop labscale(real 0.33333) labgap(string) LABColor(string) LABAngle(string) ] // v1.4
	
	
	// check dependencies
	capture findfile colorpalette.ado
	if _rc != 0 {
		display as error "The {bf:palettes} package is missing. Install the {stata ssc install palettes, replace:palettes} and {stata ssc install colrspace, replace:colrspace} packages."
		exit 198
	}
	
	capture findfile labmask.ado
	if _rc != 0 qui ssc install labutil, replace	
	
	cap findfile labsplit.ado
		if _rc != 0 quietly ssc install graphfunctions, replace		
	
	
	if "`colorby'"!="" & "`colorvar'"!="" {
		display as error "Both colorby() and colorvar() cannot be specified."
		exit 198
	}	
	
	if "`colorby'"!="name" & "`colorby'"!="" {
		display as error "The valid option is colorby(name)."
		exit 198
	}	
	
	if "`stat'" != "" & !inlist("`stat'", "mean", "sum") {
		display as error "Valid options are {bf:stat(mean)} [default] or {bf:stat(sum)}."
		exit
	}		
	
	
	
	marksample touse, strok	

quietly {	
preserve	

	keep if `touse'
	
	local colcheck = 1
	
	if "`colorvar'"=="" {
			
			local colcheck = 0
			
			gen _color = 1
			local colorvar _color
	}

	keep `varlist' `by' `colorvar' `exp'

	gettoken yvar xvar : varlist 

	
	if "`stat'" == "" local stat sum
	
	if "`weight'" != "" local myweight  [`weight' = `exp']	

	collapse (`stat') `yvar' (first) `colorvar' `myweight', by(`by' `xvar')
	
	fillin `by' `xvar'
	recode `yvar' (0=.)	
	drop _fillin
	

	cap confirm numeric var `by'
		if _rc!=0 {  // if string
			
			encode `by', gen(over2)
		}
		else {  // if numeric
			tempvar tempov 
			egen   over2 = group(`by')
			
			if "`: value label `by''" != "" {
				decode `by', gen(`tempov')		
				labmask over2, value(`tempov')
			}
			else {
				labmask over2, value(`by')					
			}
		}	
		
		local by over2
		

	decode `by', gen(_label)
	
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
		replace _label = "Others" if _maxlast==2
		replace _rank = . if _maxlast==2
		replace `by'   = . if _maxlast==2
		
		collapse (sum) `yvar' (mean) _rank _x `colorvar', by(`xvar' `by' _label)
		
		summ _rank
		replace _rank = r(max) + 1 if _rank==.
		
		summ `by'
		replace `by' =  r(max) + 1 if  `by'==.
	}
	else {
		keep if _maxlast==1 // keep top X
	}


	summ `colorvar' , meanonly
	replace `colorvar' = r(max) + 1 if `colorvar'==.
	
	
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
		bysort `xvar': egen double _locmid = max(_yhi)
		replace _locmid = _locmid / 2

	}

	if "`recenter'" == "bottom" | "`recenter'"=="bot" | "`recenter'"=="b" {
		gen _locmid  =  0
	}	
	
	if "`recenter'" == "top" | "`recenter'"=="t"  {
		bysort `xvar': egen double _locmid  =   max(_yhi)
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
	expand `newobs' 
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
	
	
	gen double _xval   = .  
	gen double _yvallo = .
	gen double _yvalhi = .
	

	by `by' (`xvar'), sort: gen _tagctry = 1 if (_n==_N)
	gen _taglast = _x==`last' & _tagctry==1
	gen _ranklast = _rank if _x==`last'
	

	sort _group `xvar' _seq
	levelsof _group, local(grp)
	

	forval i = 1/`items' {
		
		di "`i'|
		
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
	
	replace _ranklast = `top' + 1 if _label=="Others"
	
	
	
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


	if "`colorby'"=="name" {
		local colvar _group 
	}
	else {
		local colvar _ranklast
	}
	
	local counter = 1
	
	foreach i of local lvls {
		
		if `colcheck'==0 {
			
			colorpalette `palette', nograph n(`items') `poptions'

			local areas `areas' (rarea _yvalhi _yvallo _xval if `colvar'==`i', fi(100) fc("`r(p`counter')'%`alpha'") lc(`lcolor') lw(`lwidth')) 
	
			local counter = `counter' + 1
		
		}
		else {
			
			summ `colorvar', meanonly
			local items2 = r(max)
					
			summ `colorvar' if `colvar'==`i', meanonly
			local index = r(mean)
			
			colorpalette `palette', nograph n(`items2') `poptions'
			
			local areas `areas' (rarea _yvalhi _yvallo _xval if `colvar'==`i', fi(100) fc("`r(p`index')'%`alpha'") lc(`lcolor') lw(`lwidth')) 
		
		}
	}


	if "`dropother'"=="" {
		
		if "`colother'" == "" local colother gs12
		
		summ `colvar', meanonly
		local lastcor = r(max)
	
		local areas `areas' (rarea _yvalhi _yvallo _xval if `colvar'==`lastcor', fi(100) fc("`colother'%`alpha'") lc(`lcolor') lw(`lwidth'))
	
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
	

	gen _blab = _label + labnum if _taglast==1


	
	
	if "`wrap'" != "" {
		ren _blab _blab_temp
		labsplit _blab_temp, wrap(`wrap') gen(_blab)
		drop _blab_temp
	}		
	
	
	if "`labsize'"   == "" local labsize   2.8
	if "`labcolor'"  == "" local labcolor  black
	if "`labangle'"  == "" local labangle  0
	if "`labgap'"    == "" local labgap  1.5
	
	if "`labprop'" != "" {
	
		summ _sumvar if _taglast==1, meanonly
		gen double _labwgt = `labsize' * (_sumvar / r(max))^`labscale' if _taglast==1
			
		levelsof _label, local(lvls)
			
		foreach x of local lvls {
			summ _labwgt if _label=="`x'" & _taglast==1, meanonly
			local labw = r(max)
				
			local labels `labels' (scatter _ymid `xvar' if _label=="`x'" & _taglast==1, msymbol(none) mlabel(_blab) mlabgap(`labgap') mlabsize(`labw') mlabpos(3) mlabcolor(`labcolor') mlabangle(`labangle'))
		}
	
	}
	else {
		local labels (scatter _ymid `xvar' if _taglast==1, msymbol(none) mlabel(_blab) mlabgap(`labgap') mlabsize(`labsize') mlabpos(3) mlabcolor(`labcolor') mlabangle(`labangle'))
	}	
	
	
	


	// draw
	twoway ///
		`labels' ///
		`areas' ///
		, ///
		ylabel(`ymin' `ymax', nolabels noticks nogrid) ///
		yscale(noline) ///
		xscale(noline range(`xrmin' `xrmax')) ///
		legend(off) `options' 
		
	*/
	
	
restore
}
	
end



************************
***** END OF FILE ******
************************
