# hear-hear

This repository contains the code to download and process data for the Luister! project. This README will updated soon! The code will be shared under the MIT License.

The `scripts` folder contains 2x scripts at the moment: one for downloading data from Qualtrics, another for (pre)processing the data.

The data processing pipeline involves (sections copied from the data processing R script):

```
1. LOAD LIBRARIES
2. READ DATA
3. UNLIST
4. DROP VARIABLES
5. MERGE VARIABLES
6. RENAME VARIABLES
7. RECODE VARIABLES
8. COMPUTE VARIABLES
9. LABEL VARIABLES
10. WRITE DATA
```

## TODO

1. *Decide which export from Qualtrics would be the most appropriate.* If the default export is not suitable, we will have to switch the `labels` & `convert` arguments to `FALSE` in the `fetch_survey()` function.

- create 2x exports, one for the arguments set to `TRUE` and the other set to `FALSE`
- write to .sav and inspect which is better overall
- probably the one set to `FALSE` will be better, but it's good to confirm...

2. *Review and update the configuration files to align with the data exported using R.* There may be some mismatches due to working with a SPSS export and/or default R export to define the configuration files.

3. *Streamline the code for recoding variables + setting value labels + computing variables.* The code for these sections are just copied and pasted for each variable that needs to be processed. The code should be cleaner like that used in the renaming variables + setting variable labels sections. This will require restructuring the configuration files, but this cannot be done before completing the previous 2x TODOs.

4. *Apply data pipeline for ouders data*. Self-explanatory.

5. *Implement a batch file to automate scripts*. Self-explanatory.

6. *Provide code for data upload to / download from Yoda*. Requires iBridges.