roleName = CustomCloudWatchAgentRoleX
policyName = CustomCloudWatchAgentPolicyX
IamInstanceProfileName = CustomCloudWatchInstanceProfileNameX 
accountId = $(shell aws sts get-caller-identity --query 'Account' --output text)

create-role:
	echo "create role"
	aws iam create-role --role-name $(roleName) --assume-role-policy-document file://trust-policy.json

create-policy:
	echo "create policy"
	aws iam create-policy --policy-name $(policyName)	--policy-document file://cloudwatch-agent-policy.json

attach-role-to-policy:
	echo "attach role to policy"
	aws iam attach-role-policy --role-name $(roleName) --policy-arn arn:aws:iam::$(accountId):policy/$(policyName)

list-instances:
	echo "list instances"
	aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId, Tags[?Key=='Name'].Value | [0]]" --output text

# pass the id together with the comm
attach-role-to-instance:
	echo "attach role to instance"
	aws iam create-instance-profile --instance-profile-name $(IamInstanceProfileName)
	aws iam add-role-to-instance-profile --instance-profile-name $(IamInstanceProfileName) --role-name $(roleName)
	aws ec2 associate-iam-instance-profile --instance-id $(instanceId) --iam-instance-profile Name=$(IamInstanceProfileName)

