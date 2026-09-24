code_files 

Overview

The figures and the statistical results reported in the manuscript  are organized into separate subfolders within the main
folder named:

    code_files

Each figure and the analyses associated with it has its own dedicated subfolder. These subfolders contain:

    
    A. MATLAB scripts for generating the figures
    B. Associated .mat/.xlsx data files
    C. Statistical analyses corresponding to the results reported in the manuscript


How to Run the Code for A, B, C

To generate the figures and reproduce the analyses:

1.  Open MATLAB

2.  Navigate to the specific figure subfolder inside Data_Codes using
    the MATLAB command window. For example:

        cd('path_to_repository/Data_Codes/FigureX')

    Replace “FigureX” with the appropriate figure folder (e.g., Figure2,
    Figure3, Figure4).

3.  Run the main script within that folder:

        run('FigureX_script.m')

    The script will: Generate the respective figure panels; Reproduce
    the statistical analyses; Print relevant statistical outputs in the
    MATLAB Command Window


4. The column headers in data.xlsx correspond to the following measures:

   SCR_UT : Skin Conductance Response of Uncertain Threat condition
   SCR_US : Skin Conductance Response of Uncertain Safety condition
   SCR_CT : Skin Conductance Response of Certain Threat condition
   SCR_CS : Skin Conductance Response of Certain Safety condition

   FearAffect: Anxiety scores measured using Fear Affect scale of the National Institutes of Health Toolbox

   RT_UT : Reaction Time of Uncertain Threat condition
   RT_US : Reaction Time of Uncertain Safety condition
   RT_CT : Reaction Time of Certain Threat condition
   RT_CS : Reaction Time of Certain Safety condition


Notes
For any questions regarding data organization or code execution, please contact Shruti Kinger at shrutik@iiitd.ac.in

