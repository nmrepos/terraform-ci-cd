# Terraform CI/CD

Infrastructure as code for AWS, deployed automatically with GitHub Actions.

This project uses Terraform to create EC2 instances on AWS. A GitHub
Actions pipeline checks, plans and applies the Terraform code every time
changes are pushed to the main branch, so the infrastructure always matches
what is in the repository.


## Features

- Defines AWS EC2 instances as code with Terraform
- Number of instances controlled by a variable
- Automated pipeline with GitHub Actions
- Runs terraform validate and terraform plan on every push and pull request
- Applies changes automatically when code is pushed to main
- Includes a destroy job to tear the infrastructure down
- Can also be started by hand from the Actions tab
- AWS credentials kept in GitHub secrets, not in the code


## Tech Stack

    Infrastructure as code   Terraform 1.3.5
    Cloud provider           AWS (EC2), region us-east-1
    CI/CD                    GitHub Actions


## Project Structure

    main.tf                       AWS provider and the EC2 instance resource
    variable.tf                   Input variables (core_count, thread_count)
    .github/workflows/cd.yml      GitHub Actions pipeline
    README.md                     Project documentation


## Infrastructure

main.tf creates the following on AWS:

    Provider          AWS, region us-east-1
    Resource          aws_instance.example
    AMI               ami-0f214d1b3d031dc53
    Instance type     t2.micro
    Instance count    value of the core_count variable
    Tag               Name = ExampleInstance

Variables in variable.tf:

    core_count      number    How many EC2 instances to create
    thread_count    number    Defined for future use, not used by main.tf yet


## CI/CD Pipeline

The workflow in .github/workflows/cd.yml runs on:

- every push to main
- every pull request to main
- a manual run (workflow_dispatch)

It has two jobs.

Terraform job:

1. Check out the repository
2. Install Terraform 1.3.5
3. terraform init
4. terraform validate
5. terraform plan with core_count=1 and thread_count=2
6. terraform apply, only on a push to main

Terraform Destroy job:

1. Check out the repository
2. Install Terraform 1.3.5
3. terraform init
4. terraform destroy with the same variables


## Getting Started

### Prerequisites

- An AWS account with permission to manage EC2
- An AWS access key and secret key
- Terraform 1.3.5 or later (for running locally)

### Set up the pipeline

1. Fork or clone this repository.
2. In GitHub, open Settings, then Secrets and variables, then Actions, and
   add these repository secrets:

       AWS_ACCESS_KEY_ID        your AWS access key
       AWS_SECRET_ACCESS_KEY    your AWS secret key

3. Push a change to main. The pipeline plans and applies the Terraform code.

### Run locally

    export AWS_ACCESS_KEY_ID=<your-access-key>
    export AWS_SECRET_ACCESS_KEY=<your-secret-key>

    terraform init
    terraform plan  -var="core_count=1" -var="thread_count=2"
    terraform apply -var="core_count=1" -var="thread_count=2"

To remove everything that was created:

    terraform destroy -var="core_count=1" -var="thread_count=2"


## Notes and Next Steps

- The destroy job has no condition, so it runs on every pipeline run
  alongside the apply job. Restrict it to manual runs if the instances
  should stay up.
- Terraform state is stored on the pipeline runner and is lost after each
  run. Adding a remote backend, such as an S3 bucket, lets later runs track
  and destroy the instances created by earlier runs.
- AMI IDs are specific to a region. Update the AMI in main.tf if you change
  the region.
- Planned: use thread_count for the instance CPU options, and add outputs
  such as the public IP address of each instance.
