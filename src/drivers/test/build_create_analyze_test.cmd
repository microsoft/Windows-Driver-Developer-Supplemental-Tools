echo %0 %1 {
rd /s /q working\%1 >NUL 2>&1
robocopy /e %2 working\%1\
robocopy /e ..\%3\%4\%1\ working\%1\driver\

cd working\%1

echo building
msbuild /t:rebuild /p:platform=x64 /p:UseNTIFS=%5


@REM the "..\..\TestDB\%1" in the command below specifies a location for the database we want to create. The %1 will correspond to the 
@REM first argument of the calls above, for example, PendingStatusError for the first call.
echo creating_database
mkdir ..\..\TestDB
codeql database create -l=cpp -c "msbuild /p:Platform=x64;UseNTIFS=%5 /t:rebuild" "..\..\TestDB\%1" 

@REM Similar to the case above, the %1 corresponds to PendingStatusError
cd ..\..
echo analysing_database
mkdir "AnalysisFiles\Test Samples"
codeql database analyze "TestDB\%1" --format=sarifv2.1.0 --output="AnalysisFiles\Test Samples\%1.sarif" "..\%3\%4\%1\*.ql" 


echo comparing analysis result with expected result
sarif diff -o "diff\%1.sarif" "..\%3\%4\%1\%1.sarif" "AnalysisFiles\Test Samples\%1.sarif"

echo %0 %1 }
