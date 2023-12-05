rd /s /q working >NUL 2>&1
rd /s /q TestDB >NUL 2>&1
rd /s /q AnalysisFiles >NUL 2>&1

@REM call :test <DriverName> <DriverTemplate> <DriverType> <DriverDirectory> <UseNTIFS parameter value>
call :test PendingStatusError WDMTestTemplate wdm queries 0
call :test ExaminedValue WDMTestTemplate wdm queries 0
call :test StrSafe KMDFTestTemplate kmdf queries 0
call :test MultiplePagedCode WDMTestTemplate wdm queries 0
call :test NoPagedCode WDMTestTemplate wdm queries 0
call :test NoPagingSegment WDMTestTemplate wdm queries 0
call :test OpaqueMdlUse WDMTestTemplate wdm queries 0
call :test OpaqueMdlWrite WDMTestTemplate wdm queries 0
call :test KeWaitLocal WDMTestTemplate wdm queries 0
call :test IrqlTooHigh WDMTestTemplate general queries\experimental 0
call :test IrqlTooLow WDMTestTemplate general queries\experimental 0
call :test IrqlSetTooHigh WDMTestTemplate general queries\experimental 0
call :test IrqlSetTooLow WDMTestTemplate general queries\experimental 0
call :test WrongDispatchTableAssignment WDMTestTemplate wdm queries 0
call :test ExtendedDeprecatedApis WDMTestTemplate general queries 0
call :test WdkDeprecatedApis WDMTestTemplate general queries 0
call :test IllegalFieldAccess WDMTestTemplate wdm queries 0
call :test PoolTagIntegral WDMTestTemplate general queries 0
call :test ObReferenceMode WDMTestTemplate wdm queries 0
call :test DeviceInitApi KMDFTestTemplate kmdf queries\experimental 0
call :test DefaultPoolTag WDMTestTemplate general queries 0
call :test DefaultPoolTagExtended WDMTestTemplate general queries\experimental 0
call :test InitNotCleared WDMTestTemplate wdm queries 0
call :test IrqlNotUsed WDMTestTemplate general queries 0
call :test IrqlNotSaved WDMTestTemplate general queries 0
call :test IllegalFieldWrite WDMTestTemplate wdm queries 0
call :test IllegalFieldAccess2 WDMTestTemplate wdm queries 0
call :test RoutineFunctionTypeNotExpected WDMTestTemplate general queries 0
call :test KeSetEventIrql WDMTestTemplate general queries\experimental 0
call :test KeSetEventPageable WDMTestTemplate general queries 0
call :test UnicodeStringFreed WDMTestTemplate general queries\experimental 1

exit /b 0

:test
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
