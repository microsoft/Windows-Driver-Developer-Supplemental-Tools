call :test PendingStatusError WDMTestTemplate wdm queries
call :test ExaminedValue WDMTestTemplate wdm queries
call :test StrSafe KMDFTestTemplate kmdf queries
call :test MultiplePagedCode WDMTestTemplate wdm queries
call :test NoPagedCode WDMTestTemplate wdm queries
call :test NoPagingSegment WDMTestTemplate wdm queries
call :test OpaqueMdlUse WDMTestTemplate wdm queries
call :test OpaqueMdlWrite WDMTestTemplate wdm queries
call :test KeWaitLocal WDMTestTemplate wdm queries
call :test IrqlTooHigh WDMTestTemplate general queries\experimental
call :test IrqlTooLow WDMTestTemplate general queries\experimental
call :test WrongDispatchTableAssignment WDMTestTemplate wdm queries
call :test ExtendedDeprecatedApis WDMTestTemplate general queries
call :test WdkDeprecatedApis WDMTestTemplate general queries
call :test IllegalFieldAccess WDMTestTemplate wdm queries
call :test PoolTagIntegral WDMTestTemplate general queries
call :test ObReferenceMode WDMTestTemplate wdm queries
call :test DeviceInitApi KMDFTestTemplate kmdf queries\experimental
call :test DefaultPoolTag WDMTestTemplate general queries
call :test DefaultPoolTagExtended WDMTestTemplate general queries\experimental
call :test InitNotCleared WDMTestTemplate wdm queries
call :test IrqlNotUsed WDMTestTemplate general queries
call :test IrqlNotSaved WDMTestTemplate general queries
call :test IllegalFieldWrite WDMTestTemplate wdm queries
call :test IllegalFieldAccess2 WDMTestTemplate wdm queries

exit /b 0

:test
echo %0 %1 {
rd /s /q working\%1 >NUL 2>&1
robocopy /e %2 working\%1\
robocopy /e ..\%3\%4\%1\ working\%1\driver\

cd working\%1

echo building
msbuild /t:rebuild /p:platform=x64


@REM the "..\..\TestDB\%1" in the command below specifies a location for the database we want to create. The %1 will correspond to the 
@REM first argument of the calls above, for example, PendingStatusError for the first call.
echo creating_database
mkdir ..\..\TestDB
codeql database create -l=cpp -c "msbuild /p:Platform=x64 /t:rebuild" "..\..\TestDB\%1" 

@REM Similar to the case above, the %1 corresponds to PendingStatusError
cd ..\..
echo analysing_database
mkdir "AnalysisFiles\Test Samples"
codeql database analyze "TestDB\%1" --format=sarifv2.1.0 --output="AnalysisFiles\Test Samples\%1.sarif" "..\%3\%4\%1\*.ql" 


echo comparing analysis result with expected result
sarif diff -o "diff\%1.sarif" "..\%3\%4\%1\%1.sarif" "AnalysisFiles\Test Samples\%1.sarif"

echo %0 %1 }
