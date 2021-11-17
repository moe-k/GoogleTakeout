#image and video formats
$ImgFormats = @("*.jpg", "*.jpeg", "*.png", "*.webp", "*.bmp", "*.tif", "*.tiff", "*.svg", "*.heic")
$VidFormats = @("*.mp4", "*.gif", "*.mov", "*.webm", "*.avi", "*.wmv", "*.rm", "*.mpg", "*.mpe", "*.mpeg", "*.m4v")

#setup for simulation by default
[bool] $SimulateMove = $true

#clear the console
clear

#check what to move videos or images
$ImgOrVid = Read-Host "To move images input 'img' (without quotes). To Move Videos input 'vid' (without quotes), press enter when done."
$ImgOrVid = $ImgOrVid.ToLower()

#only proceed if img or vid was input
if($ImgOrVid -eq "img" -or $ImgOrVid -eq "vid"){
    
    #get source and destination paths for the move
    $SourcePath = Read-Host "Please provide source path (starting folder) to search for images or videos. Note, this path (folder) and all folders under it will be searched."
    Write-Host ""
    Write-Host "You input: SourcePath = $SourcePath."
    Write-Host ""
    write-host "If this is NOT correct, press CTRL+C to exit the script then re-excute the script and give the correct SourcePath."
    Write-Host ""
    Write-Host "Hit ENTER to continue."
    Read-Host

    $DestinationPath = Read-Host "please provide destination path to move the files to."
    Write-Host ""
    Write-Host "DestinationPath = $DestinationPath"
    Write-Host ""
    write-host "If this is NOT correct, press CTRL+C to exit the script then re-excute the script and give the correct DestinationPath."
    Write-Host ""
    Write-Host "Hit ENTER to continue."
    Read-Host

    #check that paths are not blank, in later code check that the paths are valid
    if($SourcePath -eq $null -or $SourcePath -eq "" -or $DestinationPath-eq $null -or $DestinationPath -eq ""){
      Write-Host "Please input a valid path for the source/destination path. Exiting script, please re-execute the script and try again."
      exit
    }

    #check if user wants to do a simulated move or an actual move
    Write-Host "Would you like to simulate a move (eg test run) or do an actual move?"
    Write-Host ""
    $SimulationOrNot = Read-host "For simulation input 'simulation' (without quotes). To do an actual move of your images and videos, input 'actual' (without quotes), then press enter."

    #check to see if it will be a simulation or actual move
    #this will be used later to figure out which command to run
    if($SimulationOrNot -eq "simulation"){
         $SimulateMove = $true
    }elseif($SimulationOrNot -eq "actual"){
         $SimulateMove = $false
    }else{
         Write-Host "You input an incorrect option. Exiting script, please re-run the script and try again."
         exit
    }

    #check if paths are valid
    $SourcePathExists = test-path $SourcePath
    $DestinationPathExists = test-path $DestinationPath

    if($SourcePathExists -and $DestinationPathExists){
        
        #for image
        if ($ImgOrVid -eq "img") 
        {
            try{
                    #start logging into script directory
                    Start-Transcript -Path "$PSScriptRoot\$(get-date -format 'MM-dd-yyyy \HourHH\minm\sec\ss').txt" -Force 

                    #get all images
                    $Contents = Get-ChildItem -Path $SourcePath -Recurse -Include $ImgFormats

                    #run through images and move them or simulate a move
                    foreach($Item in $Contents)
                    {
                             if($SimulateMove){
                                 Move-Item -path $Item.FullName -Destination $DestinationPath -WhatIf
                             }
                             else{                         
                                  Move-Item -path $Item.FullName -Destination $DestinationPath
                             }
                        
                        Write-Host "Moving From:" $item.FullName
                        #fix for '$DestinationPath "\" $item.PSChildName' since this was appending back the fullpath 
                        $MovedToDestinationPath = $DestinationPath + "\" + $item.PSChildName
                        Write-Host "Moving to:" $MovedToDestinationPath
                        Write-Host 'Time logged: '(get-date -format 'MM-dd-yyyy \HourHH\minm\sec\ss')
                        Write-Host ""

                        #progressbar
                        [int]$currentItem = [array]::indexof($Contents,$Item)
                        Write-Progress -Activity "Moving files" -Status "Currently Moving - $($Item.Name) - File $($currentItem) of $($Contents.Count - 1) 
	                    $([math]::round((($currentItem + 1)/$Contents.Count),2) * 100)% " -PercentComplete $([float](($currentItem + 1)/$Contents.Count) * 100)
                        Start-Sleep -Milliseconds 100
                    }
                    #stop logging
                    Stop-Transcript
                    Invoke-Item $DestinationPath
               }
               catch{
                        $ErrorMessage = $_.Exception.Message
                        $FailedItem = $_.Exception.ItemName
                        Write-Host "Error occured: $ErrorMessage"
                        Write-Host "Excepton: $FailedItem"
               }
               finally{
                        Stop-Transcript
               }
        }

        #for video
        if ($ImgOrVid -eq "vid") 
        {
            try{
                    Start-Transcript -Path "$PSScriptRoot\$(get-date -format 'MM-dd-yyyy \HourHH\minm\sec\ss').txt" -Force 

                    $Contents = Get-ChildItem -Path $SourcePath -Recurse -Include $VidFormats

                    foreach($Item in $Contents)
                    {
                             if($SimulateMove){
                                 Move-Item -path $Item.FullName -Destination $DestinationPath -WhatIf
                             }
                             else{
                                  Move-Item -path $Item.FullName -Destination $DestinationPath
                             }
   
                        Write-Host "Moving From:" $item.FullName
                        #fix for '$DestinationPath "\" $item.PSChildName' since this was appending back the fullpath 
                        $MovedToDestinationPath = $DestinationPath + "\" + $item.PSChildName
                        Write-Host "Moving to:" $MovedToDestinationPath
                        Write-Host 'Time logged: '(get-date -format 'MM-dd-yyyy \HourHH\minm\sec\ss')
                        Write-Host ""

                        [int]$currentItem = [array]::indexof($Contents,$Item)
                        Write-Progress -Activity "Moving files" -Status "Currently Moving - $($Item.Name) - File $($currentItem) of $($Contents.Count - 1) 
	                    $([math]::round((($currentItem + 1)/$Contents.Count),2) * 100)% " -PercentComplete $([float](($currentItem + 1)/$Contents.Count) * 100)
                        Start-Sleep -Milliseconds 100
                    }
                    Stop-Transcript
                }
                catch{ 
                        $ErrorMessage = $_.Exception.Message
                        $FailedItem = $_.Exception.ItemName
                        Write-Host "Error occured: $ErrorMessage"
                        Write-Host "Excepton: $FailedItem"

                }
                finally{
                       Stop-Transcript
                }
        }
    }else{
         Write-Host "Either the sourcepath or desntination path you provided does not exist. Exititing script, please re-execute the script and try again."
         exit
    }
}
else{
   Write-Host "You need to input 'img' for image or 'vid' for video. Exititing script, please re-execute the script and try again."
   exit
}