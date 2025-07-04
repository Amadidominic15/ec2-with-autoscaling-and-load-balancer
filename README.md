# Setup AWS Application Load Balancer with Auto Scaling Group using Terraform
In this project, an auto scaling group was used to provision ec2 instances, the auto scaling group always ensures that instances are always active, if any instance is unhealthy it removes it and creates another instance, it also add or remove instances depending on incoming traffic to maintain a balanced load on the instances.
The load balancer is provisioned in the public subnet with internet gateway to allow communication with the internet, the LB is also used to receive incoming traffic and distributes them to the instances.
For securuty the instances are provisioned in the private subnet and nat gateway attached to them, to allow them communicate with the internet for downloading packages and updating.
security group is opened on port 80 as our application will be runnig on port 80.

## Cloud technology used and resources created
cloud: Amazon Web Services (AWS)
resources: vpc, internet gateteway, nat gateway, subnets(private and public), security groups, elastic ip and route tables
