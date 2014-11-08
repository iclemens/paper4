
This directory contains the scripts used to analyze the data for paper 3 and 4.

Analysis is broken down into several steps, each step writes its output into the cache directory (which can be chosen in Step 1). Because of this, you only need to run these steps after clearing the cache directory or changing the algorithm (parameters) used.

Step 1: Load global configuration
---------------------------------

The global configuration for these analysis scripts is stored in a global variable called global_configuration. The "initialize.m" script loads the data required into this global variable. There are two types of data in the global configuration:

 - Experiment details (conditions &c.)
   These settings are located in config/common.m
 - Data, cache, and figure paths
   These are machine specific and loaded from config/MACHINE_ID.m
   
If you have not yet specified data, cache, and figure paths then running "initialize" will open a text editor and allow you to change the default configuration. 

WARNING: After changing the configuration file, you will need to run "initialize" again.
WARNING: Most analysis functions WILL NOT WORK without running "initialize" first.


Step 2: Importing all data
--------------------------

The EyeLink and Psychometric data are located in ASCII files. These are inefficient to work with, therefore the first step is to convert them all into Matlab files.

From the import directory, please run "load_and_preprocess(1)" and "load_and_preprocess(2)" to import data for the first and second experiment respectively. This script preprocesses the data by converting strings such as "near" and "far" into actual distances (0.5 and 2.0), making storage more efficient. Furthermore, simple checks are performed to make sure the EyeLink and psychometric data match. Simple calibration is also performed.

The "convert_calibration_file" is used to create a calibration file from the data, in case it went missing, you do not need to call this manually. The "break_times" function loads the raw data and reports on the breaks between blocks. It is in the import directory because it needs the raw data files.

Figures showing the calibration data are created in the Reports/calibration directory.


Step 3: Rejecting artifacts
---------------------------

Run the "trial_rejection" script to reject trials with artifacts.


Step 4: Analyze psychometric curves and eye movements
-----------------------------------------------------


Step 5: Fit models and perform statistical test
-----------------------------------------------


Step 6: Create figures
----------------------

