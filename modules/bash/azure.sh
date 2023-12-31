#!/bin/bash

azure_blob_upload() {
  local source_file_name=$1
  local destination_file_name=$2
  local subfolder=$3
  local account_name=$4
  local account_key=$5
  local container_name=$6

  az storage blob upload \
    --file $source_file_name \
    --name ${subfolder}/${destination_file_name} \
    --account-name $account_name \
    --account-key $account_key \
    --container-name $container_name
}

azure_vm_ip_address() {
  local resource_group=$1
  local vm_name=$2
  local ip_type=$3

  if [ "$ip_type" == "public" ]; then
    ip_address=$(az vm list-ip-addresses -g $resource_group -n $vm_name --query '[].virtualMachine.network.publicIpAddresses[0].ipAddress' -o tsv)
  elif [ "$ip_type" == "private" ]; then
    ip_address=$(az vm list-ip-addresses  -g $resource_group -n $vm_name --query [].virtualMachine.network.privateIpAddresses[0] -o tsv)
  else
    ip_address="invalid ip type $ip_type"
  fi
  
  echo $ip_address
}

azure_public_ip_address() {
  local resource_group=$1
  local ip_name=$2

  ip_address=$(az network public-ip show -g $resource_group -n $ip_name --query ipAddress -o tsv)
  echo $ip_address
}

azure_vm_run_command() {
  local resource_group=$1
  local vm_name=$2
  local script=$3
  local parameters=$4

  if [ -n "$parameters" ]; then
    parameter_option="--parameters $parameters"
  fi
  az vm run-command invoke -g $resource_group -n $vm_name --command-id RunShellScript --scripts "$script" $parameter_option
}

azure_vmss_run_command() {
  local resource_group=$1
  local vmss_name=$2
  local script=$3
  local parameters=$4

  if [ -n "$parameters" ]; then
    parameter_option="--parameters $parameters"
  fi
  az vmss list-instances -g $resource_group -n $vmss_name --query "[].id" --output tsv | \
  az vmss run-command invoke -g $resource_group -n $vmss_name --ids @- --command-id RunShellScript --scripts "$script" $parameter_option
}

azure_get_vm_info() {
  local resource_group=$1
  local vm_name=$2

  res=$(az vm show --resource-group $resource_group --name $vm_name --query "{id:id, vmId:vmId}" --output json)
  echo $res
}