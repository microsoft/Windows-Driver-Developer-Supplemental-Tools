rd /s /q working >NUL 2>&1
rd /s /q TestDB >NUL 2>&1
rd /s /q AnalysisFiles >NUL 2>&1

@REM call :test <DriverName> <DriverTemplate> <DriverType> <DriverDirectory> <BuildType>
call :test PendingStatusError WDMTestTemplate wdm queries Debug
call :test ExaminedValue WDMTestTemplate wdm queries Debug
call :test StrSafe KMDFTestTemplate kmdf queries Debug
call :test MultiplePagedCode WDMTestTemplate wdm queries Debug
call :test NoPagedCode WDMTestTemplate wdm queries Debug
call :test NoPagingSegment WDMTestTemplate wdm queries Debug
call :test OpaqueMdlUse WDMTestTemplate wdm queries Debug
call :test OpaqueMdlWrite WDMTestTemplate wdm queries Debug
call :test KeWaitLocal WDMTestTemplate wdm queries Debug
call :test IrqlTooHigh WDMTestTemplate general queries\experimental Debug
call :test IrqlTooLow WDMTestTemplate general queries\experimental Debug
call :test IrqlSetTooHigh WDMTestTemplate general queries\experimental Debug
call :test IrqlSetTooLow WDMTestTemplate general queries\experimental Debug
call :test WrongDispatchTableAssignment WDMTestTemplate wdm queries Debug
call :test ExtendedDeprecatedApis WDMTestTemplate general queries Debug
call :test WdkDeprecatedApis WDMTestTemplate general queries Debug
call :test IllegalFieldAccess WDMTestTemplate wdm queries Debug
call :test PoolTagIntegral WDMTestTemplate general queries Debug
call :test ObReferenceMode WDMTestTemplate wdm queries Debug
call :test DeviceInitApi KMDFTestTemplate kmdf queries\experimental Debug
call :test DefaultPoolTag WDMTestTemplate general queries Debug
call :test DefaultPoolTagExtended WDMTestTemplate general queries\experimental Debug
call :test InitNotCleared WDMTestTemplate wdm queries Debug
call :test IrqlNotUsed WDMTestTemplate general queries Debug
call :test IrqlNotSaved WDMTestTemplate general queries Debug
call :test IllegalFieldWrite WDMTestTemplate wdm queries Debug
call :test IllegalFieldAccess2 WDMTestTemplate wdm queries Debug
call :test RoutineFunctionTypeNotExpected WDMTestTemplate general queries Debug
call :test KeSetEventIrql WDMTestTemplate general queries\experimental Debug
call :test KeSetEventPageable WDMTestTemplate general queries Debug
call :test UnicodeStringFreed WDMTestTemplate general queries\experimental NTIFS

exit /b 0

:test
echo %0 %1 {
rd /s /q working\%1 >NUL 2>&1
robocopy /e %2 working\%1\
robocopy /e ..\%3\%4\%1\ working\%1\driver\

cd working\%1

echo building
msbuild /t:rebuild /p:platform=x64 /p:Configuration=%5


@REM the "..\..\TestDB\%1" in the command below specifies a location for the database we want to create. The %1 will correspond to the 
@REM first argument of the calls above, for example, PendingStatusError for the first call.
echo creating_database
mkdir ..\..\TestDB
codeql database create -l=cpp -c "msbuild /p:Platform=x64;Configuration=%5 /t:rebuild" "..\..\TestDB\%1" 

@REM Similar to the case above, the %1 corresponds to PendingStatusError
cd ..\..
echo analysing_database
mkdir "AnalysisFiles\Test Samples"
codeql database analyze "TestDB\%1" --format=sarifv2.1.0 --output="AnalysisFiles\Test Samples\%1.sarif" "..\%3\%4\%1\*.ql" 


echo comparing analysis result with expected result
sarif diff -o "diff\%1.sarif" "..\%3\%4\%1\%1.sarif" "AnalysisFiles\Test Samples\%1.sarif"

echo %0 %1 }
