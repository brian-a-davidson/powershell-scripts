get-childitem d:\NSE_Files\* -include *.nse | ? {$_.lastwritetime -gt "2015-06-21 12:00:00 AM" -AND $_.lastwritetime -lt "2015-06-21 4:00:00 AM"}  | move-item -destination d:\Keep -verbose