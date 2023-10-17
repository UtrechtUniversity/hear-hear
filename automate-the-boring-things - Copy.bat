title batch script for hear hear

set startTime=%time%

cd "C:\Users\Moope001\OneDrive - Universiteit Utrecht\Documents\programming\hear-hear"

Rscript "scripts/qualtrics-download.R"
Rscript "scripts/preprocessing.R"
python "scripts/yoda-upload.py"

echo Start Time: %startTime%
echo Finish Time: %time%

pause