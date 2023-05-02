# peaksCNN_batch
This Matlab code follows the idea from the paper (in citaion) with some modifications, for training and using deep learning CNN (convolutional neural network) model to classify LC-MS features as true (high quality) and false (low quality). This is the updated version of peaksCNN, and supports multiple .mzXML inputs.

## Use pretrained model for peak classification (use function "peaksEVA_batch.m")
Example usage: download and unzip the code, type the following one-line code in matlab

    peaksEVA_batch([], 'pklist.csv', [5,6], 'net64', 1);
    
Once the file selection dialog pops up, selected the example dataset (5 mzXML files).
pklist.csv is generated from elmaven via targeted peak-picking using a know standard list.

Required inputs:
1) input .mzXML file(s). Leave it blank[] for opening a file dialog.
2) input peaklist file generated from peakpicking (XCMS,mzMINE,ElMaven)
3) specify column numbers for m/z and rt in the peaklist file.
4) name of the pretrained model. Two pretrained models are included in this repo: "net64.mat" and "net48.mat". They have similar performance except for the image compression ratio (to 64X64  vs. to 48X48). They were trained using the script "peaksCNN.m".
5) verbose. 0 or 1. verbose=1 will save all EICs as pictures.
Output:
 1) A subfolder with a time stamp will be generated (i.e., tmp-2022-04-28-12:00), containing a "true" folder and a "false" folder.
 2) images for EICs of all the peaks will be classified and saved into either "true" or "false" folders.  the output "img" stores an array of EIC images.(Only if verbose=1). 
 3) A copy of the peaklist file will be created under the same folder, New columns "ispeak" & "Quality" will be added to the end of the peaklist. Instead of being 0 or 1 for "ispeak" in peakCNN, here, "ispeak" is an integer showing the number of true peaks. "Quality" is the averaged probablily of being true peaks.

Note: DO NOT close the popup figure (for updating EIC plots) until the run is completed.

## Train your own model. (use script "peaksCNN.m" )
1) download the training set from link below
https://pubs.acs.org/doi/suppl/10.1021/acs.analchem.1c01309/suppl_file/ac1c01309_si_001.zip
2) Customize your model settings (optional, see below) and run peaksCNN.m.
<br /> a) Adjust the training data: manually examine the plots in true and false folders, make some rearrangement based on your judgement. You can also add some new images to the training data set, which could be obtained from the classification results of your own data.
<br /> b) change the architecture of the CNN models by adding/modifying/removing layers. (https://www.mathworks.com/help/deeplearning/ug/layers-of-a-convolutional-neural-network.html) 
<br /> c) change the splits of training & validation sets
<br /> d) change the training options
3) After the run is completed, save the CNNmodel 'net' from workspace or type the code below. 
    
    save('mymodel.mat', 'net')
## Dependancy
1) Deep learning toolbox
2) Signal processing toolbox
3) Curve fitting toolbox
4) bioinformatics toolbox
5) statistics and machine learning toolbox
## Citation 
Anal. Chem. 2021, 93, 36, 12181–12186 "EVA: Evaluation of Metabolic Feature Fidelity Using a Deep Learning Model Trained With Over 25000 Extracted Ion Chromatograms"
