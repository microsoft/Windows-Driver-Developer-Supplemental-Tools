@REM call :test PendingStatusError WDMTestingTemplate wdm queries
@REM call :test ExaminedValue WDMTestingTemplate wdm queries
@REM call :test StrSafe KMDFTestTemplate kmdf queries
@REM call :test MultiplePagedCode WDMTestingTemplate wdm queries
@REM call :test NoPagedCode WDMTestingTemplate wdm queries
@REM call :test NoPagingSegment WDMTestingTemplate wdm queries
@REM call :test OpaqueMdlUse WDMTestingTemplate wdm queries
@REM call :test OpaqueMdlWrite WDMTestingTemplate wdm queries
@REM call :test KeWaitLocal WDMTestingTemplate wdm queries
@REM call :test IrqTooHigh WDMTestingTemplate wdm experimental
@REM call :test IrqTooLow WDMTestingTemplate wdm experimental
call :test DispatchMismatch WDMTestingTemplate wdm queries


exit /b 0

:test
echo %0 %1 {
rd /s /q out\%1 >NUL 2>&1
robocopy /e %2 out\%1\
robocopy /e ..\%3\%4\%1\ out\%1\driver\

cd out\%1

echo building
msbuild /t:rebuild /p:platform=x64


@REM the "..\..\TestDB\%1" in the command below specifies a location for the database we want to create. The %1 will correspond to the 
@REM first argument of the calls above, for example, PendingStatusError for the first call.
echo creating_database
mkdir ..\..\TestDB
codeql database create -l=cpp -c "msbuild /p:Platform=x64 /t:rebuild" "..\..\TestDB\%1" 

@REM Similar to the case above, the %1 corresponds to PendingStatusError
cd ..\..
@REM echo analysing_database
@REM mkdir "AnalysisFiles\Test Samples"
@REM codeql database analyze "TestDB\%1" --format=sarifv2.1.0 --output="AnalysisFiles\Test Samples\%1.sarif" "..\%3\%4\%1\%1.ql" 


@REM echo comparing analysis result with expected result
@REM sarif diff -o "test\%1.sarif" "..\%3\%4\%1\%1.sarif" "AnalysisFiles\Test Samples\%1.sarif"

echo %0 %1 }
