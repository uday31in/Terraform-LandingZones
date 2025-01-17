get-childItem '/Users/uday/git/uday31in/AzOps/sparta-1 (sparta-1)/' -Filter *policydefinitions*.json -Recurse | % {
    $name = $_.Name;
    $policy = get-content $_ | jq '.parameters.input.value | del(.ResourceId, .tenantID, .metadata.createdBy , .metadata.updatedBy)'
    $destination = join-path  "/Users/uday/git/uday31in/Terraform-LandingZones/code/lib/policy_definitions/" -ChildPath ("policy_definition_" + ($($name.ToString() -replace 'microsoft.authorization_policydefinitions-'))).replace(".parameters","").replace("-","_")
    $policy > $destination
}
get-childItem '/Users/uday/git/uday31in/AzOps/sparta-1 (sparta-1)/' -Filter *policySetdefinitions*.json -Recurse | % {
    $name = $_.Name;
    $policySet = get-content $_ | jq '.parameters.input.value | del(.metadata.createdBy, .metadata.updatedBy)' | ConvertFrom-Json
    $destination = join-path  "/Users/uday/git/uday31in/Terraform-LandingZones/code/lib/policy_set_definitions" -ChildPath ("policy_set_definition_" + ($($name.ToString() -replace 'microsoft.authorization_policysetdefinitions-'))).replace(".parameters","").replace("-","_")

    $policySet.properties.policyDefinitions |% {
        $guidPattern = "\b[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12}\b"
        if ($_.policyDefinitionId  -notmatch $guidPattern) {
            Write-Verbose "Custom Policy Definition: $($_.policyDefinitionId)"
            $_.policyDefinitionId = '${root_scope_resource_id}' + $_.policyDefinitionId
        }
    }
    $policySet |  ConvertTo-Json -Depth 100 > $destination
}

get-childItem '/Users/uday/git/uday31in/AzOps/sparta-1 (sparta-1)/' -Filter *policyassignments*.json -Recurse | % {
    $name = $_.Name;
    $policyAssignment = get-content $_ | jq -f ./utility/policyassignment.jq
    $destination = join-path  "/Users/uday/git/uday31in/Terraform-LandingZones/code/lib/policy_asignments" -ChildPath ("policy_assignment_" + ($($name.ToString() -replace 'microsoft.authorization_policyassignments-'))).replace(".parameters","").replace("-","_")
    $($name.ToString() -replace 'microsoft.authorization_')
    $policyAssignment > $destination
}

###### Get Policy

$(Get-ChildItem ./code/lib/policy_definitions -Recurse |% { Get-Content $_ | ConvertFrom-Json}) |% {"$('"'+$_.Name + '",')"}

#### Get Policy Set
$(Get-ChildItem ./code/lib/policy_set_definitions -Recurse |% { Get-Content $_ | ConvertFrom-Json}) |% {"$('"'+$_.Name + '",')"}

### Policy Assignment at platform

Get-ChildItem '/Users/uday/git/uday31in/AzOps/sparta-1 (sparta-1)/sparta-1-platform (sparta-1-platform)' -Filter  *policyassignments*.json |% {
    $assignment = Get-Content $_ | ConvertFrom-Json
    $assignment.parameters.input.value.name
    $assignment.parameters.input.value.properties.parameters
}
### Policy Assignment at Landing Zones
Get-ChildItem '/Users/uday/git/uday31in/AzOps/sparta-1 (sparta-1)/sparta-1-landingzones (sparta-1-landingzones)' -Filter  *policyassignments*.json |% {
    $assignment = Get-Content $_ | ConvertFrom-Json
    $assignment.parameters.input.value.name
    $assignment.parameters.input.value.properties.parameters
}