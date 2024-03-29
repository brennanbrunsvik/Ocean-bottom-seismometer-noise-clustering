This is an example of the code used for "clustering" analysis in Janiszewski et al. (in prep). The goal is to separate ocean-bottom seismometer noise spectra into different groups based on station characteristics (such as depth). Then, evaluate the similarity between spectra in those groups. If grouping by a certain station characteristic produces groups that have very similar spectral properties, then there may be a strong correlation/causation between noise and that station characteristic.

Full reference: 
Janiszewski, H. A., Eilon, Z., Russell, J., Brunsvik, B., Gaherty, J., Mosher, S., Hawley, W., & Coats, S. (in prep). Broadband Ocean Bottom Seismometer Noise Properties.

The code is not necessarily edited/finalized to be self-explanatory, but you may be able to figure it out yourself. If you would like to use this or identify problems, feel free to contact me (brennan.brunsvik@gmail.com). Many comments may be outdated. 

To get started, simply run **clusterLoopBig.m**. See comments in that file to understand how to run different analyses. 

**plot_pen_bar.m** makes the plots that show penalty reduction compilation, from several station characteristics, and multiple hierarchy levels. You should be able to immediately run this file. See Figure 5 (as of 2022.09.12). If you want to re-do the penalty calculations that go into this plot, there are a few steps. You have to run clusterLoopBig.m with savePenaltFile = true, over-all station characteristics (all datCompSpec), over both layer depths (1 and 3). This produces the .mat file that stores the data plotted in plot_pen_bar.m. 

This does not include code to actually calculate Spectra (e.g., the SpecIn.mat and similar files). See the published manuscript for links to the repositories that have that code. I included the spectra .mat files from our paper in this repository. 

I am running Matlab 2021b. I used the arguments block extensively, which was introduced in 2019b. 
