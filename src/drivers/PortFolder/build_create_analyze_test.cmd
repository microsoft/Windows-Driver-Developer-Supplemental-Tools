call :test PendingStatusError WDMTestingTemplate
@REM I only having this call because this PR is for PendingStatusError check. 
@REM Normally it will contain all calls to ported checks. For example, 
@REM call :test NoPagedCode KMDFTestingTemplate

exit /b 0

:test
echo %0 %1 {
rd /s /q out\%1 >NUL 2>&1
robocopy /e %2 out\%1\
robocopy /e ..\wdm\queries\%1\ out\%1\driver\

cd out\%1

echo building
msbuild /t:rebuild /p:platform=x64


@REM the "..\..\TestDB\%1" in the command below specifies a location for the database we want to create. The %1 will correspond to the the 
@REM first argument of the call above, aka, PendingStatusError in this case. 
echo creating_database
codeql database create -l=cpp -c "msbuild /p:Platform=x64 /t:rebuild" "..\..\TestDB\%1" 

@REM Similar to the case above, the %1 corresponds to PendingStatusError
cd ..\..
echo analysing_database
codeql database analyze "TestDB\%1" --format=sarifv2.1.0 --output="AnalysisFiles\Test Samples\%1.sarif" "..\wdm\queries\%1\%1.ql" 

echo comparing analysis result with expected result
sarif diff -o "test\%1.sarif" "..\wdm\queries\%1\%1.sarif" "AnalysisFiles\Test Samples\%1.sarif"

echo %0 %1 }


