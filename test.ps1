#need automation to move visual studio subscriptions to agency space based on visual studio name, or offer type, and filter agency based off UPN owner
$rootmgs = @()
    $rootmgs += '3f781cf3-3792-477b-abf5-ff27250dd659'
    $rootmgs += 'aa3f6932-fa7c-47b4-a0ce-a598cad161cf'
    $rootmgs += 'b4f51418-b269-49a2-935a-fa54bf584fc8'
    $rootmgs += '28b0d013-46bc-4a64-8d86-1c8a31cf590d'
    $rootmgs += 'e495954f-d235-478c-8b23-e7b80fb0db3c'
$rootmgs += '860f660b-1578-45aa-8e77-aa9b68a0c0dd'
$rootmgs += '776738eb-4f9b-444f-bc33-4dd4e8e1a9b5'
$rootmgs += 'ed20e773-9774-43f4-9113-0bc00d2cbf78'
$rootmgs += '658e63e8-8d39-499c-8f48-13adc9452f4c'
$rootmgs += 'a276ba90-5ec5-4241-baf6-ec133094cae9'

$subproperties = @()
    $subproperties += 'SubName,SubID,SubMG,BillingAcountID,accountAdminNotificationEmailAddress'
install-module az.resourcegraph -force
#connect-azaccount -identity
foreach ($rootmg in $rootmgs){
    $rootmg
try {
$subs = Search-AzGraph -Query "ResourceContainers | where type =~ 'microsoft.resources/subscriptions'" -ManagementGroup $rootmg
ForEach ($Subscription in $subs){
    $submg = $subscription.properties.managementGroupAncestorsChain.name[0]

    $subinfo = az billing property show --subscription $subscription.subscriptionid | ConvertFrom-Json
    #$subbillingid = $subinfo | select billingaccountid
    #$subbillingadmin = $subinfo | select accountAdminNotificationEmailAddress
    if (($subinfo.billingAccountId) -notlike $null){
    $subproperties += ($Subscription.name) + ',' + ($Subscription.subscriptionId) + ',' + $submg + ',' + ($subinfo.billingAccountId.replace('/providers/Microsoft.Billing/billingAccounts/','')) + ',' + ($subinfo.accountAdminNotificationEmailAddress)
    }
    if (($subinfo.billingAccountId) -like $null){
        $subproperties += ($Subscription.name) + ',' + ($Subscription.subscriptionId) + ',' + $submg + ',' + 'No AccountID' + ',' + ($subinfo.accountAdminNotificationEmailAddress)
    }
}
} catch {}
} 
