import boto3

ec2_client = boto3.client('ec2', region_name = "eu-west-2")

available_vpcs = ec2_client.describe_vpcs()
vpcs = available_vpcs["Vpcs"]

for vpc in vpcs:
    print(vpc["VpcId"])
    vpc_state = vpc["CidrBlockAssociationSet"]
    for state in vpc_state:
        print(state["CidrBlockState"])
        print(state["CidrBlock"])