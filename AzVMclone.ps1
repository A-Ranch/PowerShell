# Replace the Subscription ID matching to your Azure subscription
Select-AzSubscription -SubscriptionId '7xx23xxx-5874-7da5-b65c-a37b4e78ff23'

# Assign Resource Group name where the snapshots have been created.
$RGName ='Clone-Demo-Shell'

# Assign snapshot name of the OS disk (provided on creating snapshot) to a variable
$OSSnapshotName = 'DBSRV2019-OSDISK-SnapShot'

# Assign a Managed OS Disk name to a variable
$OSDiskName = 'DBSRV2019-OSDISK-Managed_Disk-Shell'

# Choose between Standard_LRS and Premium_LRS
$StorageType = 'Standard_LRS'

# Get the value of Geo location from the snapshot and assign the value to GeoLocation variable
$GeoLocation = 'westus'

# Retrieve the values of snapshot for the OS Snapshot
$OSSnapshot = Get-AzSnapshot -ResourceGroupName $RGName -SnapshotName $OSSnapshotName 

# Create a configurable OS disk object from the details of storage type Geo Location and snapshot ID 
$OSDiskConfig = New-AzDiskConfig -AccountType $StorageType -Location $GeoLocation -CreateOption Copy -SourceResourceId $OSSnapshot.Id

# Create a Managed OS Disk from the OS disk Configuration
$OSDisk = New-AzDisk -Disk $OSdiskConfig -ResourceGroupName $RGName -DiskName $OSDiskName

# Assign snapshot name of the data disk that has been provided on creating snapshot
$DatasnapshotName = 'DBSRV2019-DataDisk-Snapshot'

# Assign a Managed Data Disk name to a variable
$DatadiskName = 'DBSRV2019-DataDisk-ManagedDisk-Shell'

# Retrieve the values of snapshot for the Data Snapshot
$DataSnapshot = Get-AzSnapshot -ResourceGroupName $RGName -SnapshotName $DatasnapshotName 

# Create a configurable data disk object from the details of storage type Geo Location and snapshot ID
$DatadiskConfig = New-AzDiskConfig -AccountType $StorageType -Location $geolocation -CreateOption Copy -SourceResourceId $DataSnapshot.Id

# Create a Managed Data Disk from the data disk Configuration
$Datadisk = New-AzDisk -Disk $DatadiskConfig -ResourceGroupName $RGName -DiskName $DataDiskName

# Assign the value of virtual network name to VNetName variable (replace the name with the one that your virtual network name)
$VNetName = 'Demo-vnet'

# Assign a variable as the Identity of the VM 
$VMIdentity = 'DBSRV2019-Clone-Shell'

# Assign VM size ( for more VM sizes run Get-AzureRmVmSize with location name)
$VMSize = 'Standard_D4s_v3'

# Create a public IP and assign static IP address
$pip = New-AzPublicIpAddress -Name "ClonepublicIP$(Get-Random)" -ResourceGroupName $RGName -Location $GeoLocation -AllocationMethod Static

# Create an inbound network security group rule for port 3389
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name CloneNetworkSecurityGroupRuleRDP  -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow

# Create a network security group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $RGName -Location $geolocation -Name CloneNetworkSecurityGroup -SecurityRules $nsgRuleRDP

# The VNET assigned to the clone VM has to be same as Source VM resource Group
$RGNameVnet ='Demo'

# Retrieve the Virtual network details with the Virtual network residing resource group
$vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $RGNameVnet

# Create a Network Interface Card
$nic = New-AzNetworkInterface -Name CloneNic -ResourceGroupName $RGName -Location $GeoLocation -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create and assign the value to Virtual machine varriable with the VM identity and VM size
$VirtualMachine = New-AzVMConfig -VMName $VMIdentity -VMSize $VMSize

# Attach Data Disk to the confirguration with the datadisk.id from the data disk maanged disk
$VirtualMachine = Add-AzVMDataDisk -VM $VirtualMachine -Name $dataDiskName -ManagedDiskId $datadisk.id -Lun "0" -CreateOption "Attach"

# Attach OS Disk to the confirguration with the osdisk.id from the OS managed disk and type of operating system on the snapshot
$VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -ManagedDiskId $osdisk.Id -CreateOption Attach -Windows

# Add virtual network interface using the NIC ID and assign the value to $VirtualMachine 
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $nic.Id

# Create the virtual machine with above details and Managed Disks
New-AzVM -VM $VirtualMachine -ResourceGroupName $RGName -Location $GeoLocation