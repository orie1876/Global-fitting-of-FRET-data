import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from lmfit import Parameters, minimize, report_fit



def gauss2(x1, amp1, cen1, sigma1,amp2,cen2,sigma2):          # This is the equation we're fitting to
    """Gaussian lineshape."""
    return amp1 * np.exp(-(x-cen1)**2 / (2.*sigma1**2))+amp2 * np.exp(-(x-cen2)**2 / (2.*sigma2**2))


def gauss_dataset(params, i, x):
    """Calculate Gaussian lineshape from parameters for data set."""
    amp1 = params['amp1_%i' % (i+1)]
    cen1 = params['cen1_%i' % (i+1)]
    sig1 = params['sig1_%i' % (i+1)]
    amp2 = params['amp2_%i' % (i+1)]
    cen2 = params['cen2_%i' % (i+1)]
    sig2 = params['sig2_%i' % (i+1)]
    return gauss2(x, amp1, cen1, sig1,amp2, cen2, sig2)


def objective(params, x, data):
    """Calculate total residual for fits of Gaussians to several data sets."""
    ndata, _ = data.shape
    resid = 0.0*data[:]

    # make residual per data set
    for i in range(ndata):
        resid[i, :] = data[i, :] - gauss_dataset(params, i, x)

    # now flatten this to a 1D array, as minimize() needs
    return resid.flatten()



x = np.linspace(0.05, 1, 20)       # Make the 
file=r"/Users/Mathew/Dropbox (Cambridge University)/Ed Code/Global Fitting/DataA30P.txt"
datas = pd.read_table(file,header=None)
trans_datas=np.transpose(datas)

data=trans_datas.to_numpy()



fit_params = Parameters()
for iy, y in enumerate(data):
    fit_params.add('amp1_%i' % (iy+1), value=1000, min=0.0, max=100000)
    fit_params.add('cen1_%i' % (iy+1), value=0.2, min=0.0, max=1.0)
    fit_params.add('sig1_%i' % (iy+1), value=0.1, min=0.01, max=0.5)
    fit_params.add('amp2_%i' % (iy+1), value=400, min=0.0, max=2000)
    fit_params.add('cen2_%i' % (iy+1), value=0.55, min=0.5, max=1.0)
    fit_params.add('sig2_%i' % (iy+1), value=0.1, min=0.01, max=0.3)
    
    

for iy in range(2,len(data)+1):
    fit_params['cen1_%i' % iy].expr = 'cen1_1'
    fit_params['sig1_%i' % iy].expr = 'sig1_1'
    fit_params['cen2_%i' % iy].expr = 'cen2_1'
    fit_params['sig2_%i' % iy].expr = 'sig2_1'
    
out = minimize(objective, fit_params, args=(x, data))
report_fit(out.params)

plt.figure()
for i in range(len(data)):
    y_fit = gauss_dataset(out.params, i, x)
    plt.plot(x, data[i, :], 'o', x, y_fit, '-')
plt.show()


cen=out.params['cen1_1']
cen2=out.params['cen2_1']
wid1=out.params['sig1_1']
wid2=out.params['sig2_1']

print(cen,cen2,wid1,wid2)


