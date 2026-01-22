$ClusterName = "nextime-cluster"
$Region = "us-east-1"

Write-Output "==== 1. Listando Node Groups do cluster ===="
$NodeGroups = (aws eks list-nodegroups --cluster-name $ClusterName --region $Region | ConvertFrom-Json).nodegroups

if ($NodeGroups.Count -gt 0) {
    Write-Output "==== 2. Deletando Node Groups ===="
    foreach ($NG in $NodeGroups) {
        Write-Output "Deletando Node Group: $NG"
        aws eks delete-nodegroup --cluster-name $ClusterName --nodegroup-name $NG --region $Region
    }

    Write-Output "Aguardando Node Groups serem deletados..."
    foreach ($NG in $NodeGroups) {
        aws eks wait nodegroup-deleted --cluster-name $ClusterName --nodegroup-name $NG --region $Region
    }
} else {
    Write-Output "Nenhum Node Group encontrado"
}

Write-Output "==== 3. Deletando Load Balancers criados pelo cluster ===="
$LBs = (aws elbv2 describe-load-balancers --region $Region | ConvertFrom-Json).LoadBalancers | Where-Object { $_.DNSName -like "*$ClusterName*" }

foreach ($LB in $LBs) {
    Write-Output "Deletando Load Balancer: $($LB.LoadBalancerArn)"
    aws elbv2 delete-load-balancer --load-balancer-arn $LB.LoadBalancerArn --region $Region
}

Write-Output "==== 4. Deletando Security Groups do cluster ===="
$SGs = (aws ec2 describe-security-groups --filters "Name=tag:eks:cluster-name,Values=$ClusterName" --region $Region | ConvertFrom-Json).SecurityGroups

foreach ($SG in $SGs) {
    $SGId = $SG.GroupId
    Write-Output "Liberando ENIs associadas ao SG $SGId..."
    $ENIs = (aws ec2 describe-network-interfaces --filters "Name=group-id,Values=$SGId" --region $Region | ConvertFrom-Json).NetworkInterfaces
    foreach ($ENI in $ENIs) {
        $AttachId = $ENI.Attachment.AttachmentId
        if ($AttachId) {
            Write-Output "Desanexando ENI $($ENI.NetworkInterfaceId)"
            aws ec2 detach-network-interface --attachment-id $AttachId --force --region $Region
        }
    }

    Write-Output "Deletando SG $SGId"
    try {
        aws ec2 delete-security-group --group-id $SGId --region $Region
    } catch {
        Write-Output "Não foi possível deletar SG $SGId ainda"
    }
}

Write-Output "==== 5. Deletando o Cluster EKS ===="
aws eks delete-cluster --name $ClusterName --region $Region
Write-Output "Aguardando cluster ser deletado..."
aws eks wait cluster-deleted --name $ClusterName --region $Region

Write-Output "==== Tudo deletado com sucesso ===="
