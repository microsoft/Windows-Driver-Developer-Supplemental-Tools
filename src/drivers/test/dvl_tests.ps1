param(
    [string]$vcxproj_path_clean = ".\hidusbfx2_clean\sys\",
    [string]$vcxproj_path_mustfix = ".\hidusbfx2_mustfix\sys\",
    [string]$vcxproj_name = "hidusbfx2",
    [string]$codeql_path = "C:\codeql-home\codeql\",
    [string]$query_suite = "C:\codeql-home\windows_driver_mustfix.qls",
    [string]$default_platform = "x64",
    [string]$default_configuration = "Release",
    [string]$db_name = "temp_db"
)
$starting_location = Get-Location

$platforms = @("x64", "arm64")
$configurations = @("Debug", "Release")
function Test-DVL {
    param (
        [string]$command_type = "msbuild",
        [string]$test_empty = "false"
    )
    
    foreach ($platform in $platforms) {
        foreach ($configuration in $configurations) {
            if ($test_empty -eq $true) {
                $found_sarif = Test-Path *.sarif -PathType Leaf
                if ($found_sarif -eq $true) {
                    Write-Host "FAIL -- Sarif file found! There should be no sarif file at this point!"
                    exit 1
                }
                $dest = ".\$vcxproj_name.empty.$command_type.$platform.$configuration.DVL.XML"
            }
            else {
                $found_sarif = Test-Path *.sarif -PathType Leaf
                if ($found_sarif -ne $true) {
                    Write-Host "FAIL -- Sarif file not found!"
                    exit 1
                }
                $dest = ".\$vcxproj_name.$command_type.$platform.$configuration.DVL.XML"
            }
            #write-host "test $command_type $platform $configuration empty: $test_empty save to $dest"
            $global:LASTEXITCODE = 1234567891

            if ($command_type -eq "msbuild") {
                $command = "msbuild /target:dvl /p:Platform=$platform /p:Configuration=$configuration"
                $output = Invoke-Expression $command
                if ($LastExitCode -eq 1234567891) {
                    Write-Host "FAIL -- Unexpected error creating DVL with $platform $configuration using $command"
                    exit 1
                }
                
                if ($LastExitCode -ne 0) {
                    if ( $configuration -eq "Release") {
                        Write-Host "FAIL -- Failed to create DVL with $platform $configuration using $command"
                        Write-Host "$LastExitCode -- $output"
                        exit 1
                    }
                    else {
                        #debug
                        #Write-Host "PASS. Failed to create DVL with Debug configuration"     
                    }
                } 
                elseif ($LastExitCode -eq 0 ) {
                    if ($configuration -eq "Release") {
                        #Write-Host "Copying created DVL to $dest"
                        Rename-Item -Path ".\$vcxproj_name.DVL.XML" -NewName $dest
                    }
                    else {
                        #debug 
                        Write-Host "FAIL -- DVL should not be created with Debug configuration. Created DVL with $platform $configuration using $command"
                        exit 1
                    }
                }
                else { 
                    Write-Host "FAIL -- Unexpected error creating DVL with $platform $configuration using $command"
                    Write-Host "$LastExitCode -- $output"
                    exit 1
                }
                Write-Host "PASS -- Test create DVL $configuration-$platform-$command_type"
            }
            $global:LASTEXITCODE = 1234567891
            if ($command_type -eq "dvl") {
                if ($configuration -eq "Release") {

                    $command = "& `"C:\Program Files (x86)\Windows Kits\10\Tools\dvl\Dvl.exe`" /manualCreate $vcxproj_name $platform"
                    $output = Invoke-Expression $command
                    if ($LastExitCode -eq 1234567891) {
                        Write-Host "FAIL -- Unexpected error creating DVL with $platform $configuration using $command"
                        exit 1
                    }
                    if ($LastExitCode -ne 0 ) { 
                        Write-Host "FAIL -- Empty DVL should be created without a sarif file.  $platform using dvl.exe"
                        Write-Host "$output"
                        exit 1
                    }
                    else {
                        #Write-Host "Copying created DVL to $dest"
                        Rename-Item -Path ".\$vcxproj_name.DVL.XML" -NewName $dest
                    }
                    Write-Host "PASS -- Test create DVL $configuration-$platform-$command_type"
                }
            }
        }
       
    }
}

function Test-Driver {
    param (
        [string]$vcxproj_path = $vcxproj_path_clean
    )

    if($vcxproj_path -eq $vcxproj_path_clean) {

    }
    else {
    }

    # Delete any files ending in .sarif
  
    Set-Location -Path $vcxproj_path
    Get-ChildItem -Path ".\" -Filter "*.sarif" -Recurse | Remove-Item -Force
    Get-ChildItem -Path ".\" -Filter "*.DVL.XML" -Recurse | Remove-Item -Force
    # Test DVL with no codeql sarif results
    Test-DVL "msbuild" -test_empty $true
    Test-DVL "dvl" -test_empty $true
    #Test codeql
    Set-Location -Path $starting_location

    $global:LASTEXITCODE = 1234567891

    $command = $codeql_path + "codeql.exe database create $db_name --language=cpp --source-root=`"$vcxproj_path\..\`" --command=`"msbuild /t:Rebuild /p:Configuration=Release /p:Platform=x64`" --overwrite 2>&1"
    $out = Invoke-Expression $command
    $codeql_db_exit_code = $LastExitCode
    if ($LASTEXITCODE -eq 1234567891) {
        Write-Host "FAIL -- Unexpected error creating CodeQL database"
        exit 1
    }
    if ($codeql_db_exit_code -ne 0) {
        Write-Host "Failed to create CodeQL database"
        Write-Host $out
        exit 1
    }
    else {
        Write-Host "PASS -- Test create CodeQL database"
    }
    $sarif_out = "$vcxproj_path/results_$db_name.sarif"
    $global:LASTEXITCODE = 1234567891
    $command = $codeql_path + "codeql.exe database analyze --download $db_name $query_suite --format=sarifv2.1.0 --output=`"$sarif_out`" 2>&1"
    $out = Invoke-Expression $command
    $codeql_analyze_exit_code = $LastExitCode
    if ($LASTEXITCODE -eq 1234567891) {
        Write-Host "FAIL -- Unexpected error creating CodeQL database"
        exit 1
    }
    $found_sarif = Test-Path $sarif_out -PathType Leaf
    if ($found_sarif -ne $true) {
        Write-Host "FAIL -- Sarif file not found after running codeql analyze!"
        exit 1
    }
    if ($codeql_analyze_exit_code -ne 0) {
        Write-Host "Failed to analyze CodeQL database"
        Write-host $out
        exit 1
    }
    else {
        Write-Host "PASS -- Test analyze CodeQL database"
    }

    Set-Location -Path $vcxproj_path

    #Test DVL
    Test-DVL "msbuild" -test_empty $false
    Test-DVL "dvl" -test_emtpy $false
    
    Set-Location -Path $starting_location
}

Write-Host "Testing Clean Driver"
Test-Driver $vcxproj_path_clean
$result_loc = "$starting_location\clean_results\"
New-Item -ItemType Directory -Path $result_loc -Force
Get-ChildItem -Path $vcxproj_path_clean -Include *.sarif,*.DVL.XML -Recurse | Copy-Item -Destination $result_loc
Write-Host "Testing MustFix Driver"
Test-Driver $vcxproj_path_mustfix
$result_loc = "$starting_location\mustfix_results\"
New-Item -ItemType Directory -Path $result_loc -Force
Get-ChildItem -Path $vcxproj_path_clean -Include *.sarif,*.DVL.XML -Recurse | Copy-Item -Destination $result_loc
