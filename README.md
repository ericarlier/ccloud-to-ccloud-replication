# ccloud-to-ccloud-replication
Terraform deploy of Confluent Replicator for CCloud to CCloud data replication

Developed using https://github.com/confluentinc/ccloud-tools as a basis

**Currently only GCP deployment available** (AWS and Azure to come up, contibutions welcome ;-)

## Pre-requisites
1. Two Confluent Cloud Clusters Up and Running. Destination cluster is expected to run on GCP. Replicator will be deployed in same region as destination cluster
2. *Be Mindful that if you use VPC Peering for your cluster(s), replicator will have to be deployed in a location where it has access to both source and destination clusters. Therefore, these scripts would need to be modified to adjust networking requirements*
3. Outside of evaluation purposes, you need a license to use Confluent Replicator in production 
4. A GCP Project and Sufficient access rights to create the resources by the terraform plan

## Customizing it :

### Mandatory Steps
1. `cd terraform/gcp`
2. `cp cloud.auto.tfvars.example cloud.auto.tfvars`
3. Edit the `cloud.auto.tfvars` file and insert your GCP project information and service account credential file (cf https://cloud.google.com/iam/docs/creating-managing-service-account-keys)
4. `cp ccloud.auto.tfvars.example ccloud.auto.tfvars`
5. Edit the `cloud.auto.tfvars` file and insert your Confluent Cloud Source and Destination clusters urls and credentials
6. Create a password file `terraform/utils/connect.password`, and insert online with your own Kafka Connect REST API user and password in this form : `user:password`

### Optional Steps
1. File `terraform/gcp/variables.tf` : you may customize number of replicator instances to deploy, as well as, confluent version to use
2. File `terraform/util/kafka-replicator-config-template.json` : you may customize here some replicator configurations, like the white or black list of topics to replicate

## Running it
1. `cd terraform/gcp`
2. `terraform init`
3. `terraform plan`
4. `terraform apply`
5. if terraform applied successfully, you shall see a new sub-directory `load`: `cd load`
6. You may need to wait a few minutes for the full infrastructure to be really up and then `./loadReplicator.sh` -> This script will load the replicator config through the Kafka Connect REST API
