    #!/bin/bash
    function usage()
    {
	echo ""
	echo * Each option is required to operate osdisk swap.
	echo * A rescue VM is required preferably in the same resource 
	echo group
	echo  
	echo * If you don\'t know your disk name, a required option, run the
	echo run the following command:
	echo az disk list -g \[resource group\] --output table;
	echo You can also get the disk name from the portal under disks associated to the vm.
	echo You can also find the disktype information there.
	exit
}
    function selections()
	{
	echo Your selections:
	echo resource group: $rg
	echo snapshotname: $snapshot
	echo disk name: $disk
	echo fixed disk name: $fxdisk
	echo rescue vm: $rescuevm
	echo disktype: $disktype
#
	echo " Do these look correct?:"
	 echo y = Continue, n = Start over & read answer
#	    
	     if [[ $answer == "y" ]]; then 
	     echo Continuing. 
	     sleep .5
	    elif [[ $answer == "n" ]]; then
	          echo Starting over
	  	  sleep 1
		  eval "./os-swapdisk.sh"
	     elif  [[  $answer != "y" || "$answer" != "y" || -z "$answer" ]]; then
	          echo You must select Y or N
	          exit 1
	      fi
}

    function setSubId()
    { echo Setting subscription id....
      az account set -s $SubID
 }	
    
#    function setosdisk()
#    {
	#   echo test
#}
    function troubleshoot()
    { selections
	# az vm stop -g $rg -n $srcvm

	#az snapshot create -n $snapshot -g $rg --source $disk --verbose
	#az snapshot create -n $snapshot -g $rg --source $disk 
	#snapshotId=$(az snapshot show --name $snapshot --resource-group $rg --query [id] -o tsv)
	#$snapshotId
	#az disk create --resource-group $rg --name $fxdisk --sku $disktype  --source $snapshotId
	#az vm disk attach --vm-name $rescuevm -g $rg --disk $fxdisk
	echo In troubleshooting function
}

    function swap()
    {
	selections
	az vm disk detach --vm-name $rescuevm  -g $rg --name $fxdisk  
	diskId=$(az disk list -g $rg -o tsv|grep $fxdisk|awk '{print $3}')
        az vm update --name $srcvm --resource-group $rg --os-disk $diskId
#	echo In swap function
	az vm show -g $rg -n $srcvm -d
}
        # Ask the user for login detail
        clear	
	echo "####################################################"
	echo "# OS Swap Disk script for Bash                     #"
	echo "# This can be used in Azure Cloud Shell and bash.  #"
	echo "#                                                  #"
	echo "# v:0.1                                            #"
	echo "# 2018/5/26                                        #"
	echo "# Press h, help or ? anytime for usage             #"
	echo "####################################################"

	echo resource group:&read rg 
       	   if [[ $rg = "?" || $rg == "help" || $rg == "h"  ]]; then 
	      usage 
	   fi
	#read  rg
	echo source vm: &read srcvm
	    if [[ $srcvm == "?" || $srcvm == "help" || $srcvm == "h"  ]]; then
	       usage
	    fi
#	echo disk name: &read disk
#	    if [[ $disk == "?" || $disk == "help" || $disk == "h"  ]]; then
#	       usage
#	    fi


	echo snapshot name: &read  snapshot
	    if [[ $snapshot == "?" || $snapshot == "help" || $snapshot == "h"  ]]; then
	       usage
	    fi

	echo fxdisk: &read fxdisk
	    if [[ $fxdisk == "?" || $fxdisk == "help" || $fxdisk == "h"  ]]; then
	       usage
	    fi

#	echo disktype: & read disktype
#	    if [[ $disktype == "?" || $rg == "disktype" || $disktype == "h"  ]]; then
#	       usage
#	    fi

	echo rescue vm name: & read  rescuevm
	    if [[ $rescuevm == "?" || $rescuevm == "help" || $rescuevm == "h"  ]]; then
	       usage
	    fi

	
	disk=$(az vm show -g $rg  -n $srcvm  -d|grep -i os|grep name|awk '{split($2,a,"\"");print a[2]}')
	disktype=$(az vm show -g $rg -n $srcvm -d|grep storageAccountType|awk '{split($2,a,"\""); print a[2]}'|tail -1)
#	echo $disk
#	echo $disktype

	echo " Attach disk to rescue vm for toubleshooting or swap broken osdisk with fixed osdisk?:"
	 echo 1 = troubleshoot osdisk, 2 = swap osdisk & read answer
	    
	     if [[ "$answer" = "1" ]]; then 
	        echo troubleshoot
		troubleshoot
	     elif [[ "$answer" = "2" ]]; then
	          echo swap
		  swap
	     elif  [[  "$answer" != "1" || "$answer" != "2" || -z "$answer" ]]; then
	          echo You must select 1 or 2
	          exit
	      fi
