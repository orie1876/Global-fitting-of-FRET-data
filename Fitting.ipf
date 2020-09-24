#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function parameters()
make/o/n=1 x1=0.1651
make/o/n=1 x2=.35599
make/o/n=1 w1=0.072
make/o/n=1 w2=0.15871
end


function load() 
// Function to load the FRET data into one table
LoadWave/J/M/D/A=wave/K=0 

// This is loaded into a 2D matrix.


end


function final_fit()
wave wave0		// Let knows exist. 

variable a,b,c,d									// Some variables

make/o/n=200 fit_xaxis // This is for the fit axis
variable e=0
for(a=0;a<200;a+=1)
fit_xaxis[a]=e
e+=0.005
endfor



wave FRET_axis




variable number_of_fits=(dimsize(wave0,1)-1) 		// Number of time-points to fit. 
variable length=(dimsize(wave0,0))
make/o/n=(length) tempy			// Temp wave to store data in


make/o/n=(number_of_fits) y0_fit,a1_fit,x1_fit,w1_fit,a2_fit,x2_fit,w2_fit,int1,int2,conc1,conc2		// To store variables in

wave x1,x2,w1,w2	// This is to get the data for the fits. 

for(a=0;a<(number_of_fits);a+=1)				// Go through and fit them all

	//First of all need to extract the data
	for(b=0;b<length;b+=1)
	
	tempy[b]=wave0[b][a+1]
	
	
	endfor
	
	string name="Y_"+num2str(a)			// Duplicate the wave to store
	duplicate/o tempy,$name

	make/o/n=7 W_coef= {0,10,0.3,0.1,10,0.5,0.1}		// Perform the fits on all of the data
	w_coef[0]=0
	w_coef[1]=10
	w_coef[2]=x1[0]
	w_coef[3]=w1[0]
	w_coef[4]=10
	w_coef[5]=x2[0]
	w_coef[6]=w2[0]
	
	FuncFit/H="0011011" twogauss W_coef tempy /X=FRET_axis /D 
	
	string fitsave="total_fit_"+num2str(a)
	wave fit_tempy
	duplicate/o fit_tempy,$fitsave
	// Store the fits in a table.
	
	y0_fit[a]=w_coef[0]
	a1_fit[a]=w_coef[1]
	x1_fit[a]=w_coef[2]
	w1_fit[a]=w_coef[3]
	a2_fit[a]=w_coef[4]
	x2_fit[a]=w_coef[5]
	w2_fit[a]=w_coef[6]
	
	// Now for single gauss fits to add to graphs:
	make/o/n=4 w_coef
	
	k0=y0_fit[a]
	k1=a1_fit[a]
	k2=x1_fit[a]
	k3=w1_fit[a]
	
	CurveFit/H="1111" gauss tempy /X=FRET_axis /D 
	
	string peak1="Peak_1_"+num2str(a)
	duplicate/o fit_tempy,$peak1
	
	k0=y0_fit[a]
	k1=a2_fit[a]
	k2=x2_fit[a]
	k3=w2_fit[a]
	
	CurveFit/H="1111" gauss tempy /X=FRET_axis /D 
	
	string peak2="Peak_2_"+num2str(a)
	duplicate/o fit_tempy,$peak2
	
	Integrate $peak1/D=peak_INT;DelayUpdate
	
	int1[a]=peak_int[199]
	conc1[a]=int1[a]/0.05
	
	Integrate $peak2/D=peak2_INT;DelayUpdate
	
	int2[a]=peak2_int[199]
	conc2[a]=int2[a]/0.05
	
	
	
	display $name vs FRET_axis	
	ModifyGraph mode=5,rgb=(39321,39321,39321)
	ModifyGraph width=283.465,height=198.425
	ModifyGraph gFont="Arial",gfSize=20
	Label left "No. of oligomers";DelayUpdate
	Label bottom "FRET Efficiency"
	ModifyGraph height=170.079
	AppendToGraph $fitsave vs fit_xaxis
	ModifyGraph lsize($fitsave)=2,rgb($fitsave)=(1,3,39321)
	AppendToGraph $peak1,$peak2 vs fit_xaxis
	ModifyGraph lsize($peak2)=2,rgb($peak2)=(65535,43690,0),lsize($peak1)=2;DelayUpdate
	ModifyGraph rgb($peak1)=(2,39321,1)
	
	
endfor




end












Function twogauss(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = y0 + a1*exp(-((x-xc1)/w1)^2) + a2*exp(-((x-xc2)/w2)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 7
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = a1
	//CurveFitDialog/ w[2] = xc1
	//CurveFitDialog/ w[3] = w1
	//CurveFitDialog/ w[4] = a2
	//CurveFitDialog/ w[5] = xc2
	//CurveFitDialog/ w[6] = w2

	return w[0] + w[1]*exp(-((x-w[2])/w[3])^2) + w[4]*exp(-((x-w[5])/w[6])^2)
End


function kill()

	variable                      winMask;
 
	variable                      i,n;
	variable                      all=0x1000+0x40+0x10+0x4+0x2+0x1;
	string                        theWins;
 
	winMask = !winMask ? all : winMask;
 
	theWins = winList("*",";","WIN:"+num2iStr(winMask & all));
	for(i=0,n=itemsInList(theWins,";") ; i<n ; i+=1)
		doWindow/K $stringFromList(i,theWins,";");
	endfor;
end

macro close_windows()
kill()
end