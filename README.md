# SeasFire Technical Validation 

This repository contains the code and notebooks for the technical validation part of the "SeasFire as a Multivariate Earth System Datacube for Wildfire Dynamics" paper. The technical validation is divided into three key components:

## Visual Inspection
  
Folder: /visual_inspection

Description: Coming soon! This section focuses on visually inspecting SeasFire data. Notebooks and scripts within this folder guide the user through visualization techniques, enabling a comprehensive understanding of the multivariate Earth system datacube for wildfire dynamics. The notebook is used to generate the results of figure 5.

## Causality  [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/1p9zm-PePoD05BQ5Ok0QcElIu2pOxYv6b#scrollTo=buNoPgct6quV)

Description: Explore causality relationships within the SeasFire dataset. In this notebook, we utilize the PCMCI algorithm  to identify potential causal factors influencing wildfire dynamics as well as their lagged effects. The notebook is used to generate the results of figure 6. The illustration of figure 6 is done by the Makie.jl library.

## Machine Learning Modeling
  
Folder: /ml_experiments

Description: Implement machine learning models to predict wildfire dynamics using SeasFire data. Code within this section covers the development, training, and evaluation of U-Net++ model for burned area pattern forecasting that can be defined as a segmentation task.

## Tutorials  [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/1DJIfNd1syFqo1ptVp1S2SttEtrqMDiXH?usp=sharing) 

Folder: /tutorials

Description: It contains a tutorial to access and visualise the data cube, which is readily available on Zenodo and easy to use on Google Colab. 
