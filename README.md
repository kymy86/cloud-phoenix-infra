# Cloud Phoenix Kata infrastructure ![version][version-badge]
[version-badge]: https://img.shields.io/badge/version-1.0-blue.svg

In this repo you can find the solution to the **Phoenix Application Problem**. To fully address the requirements outlined in the problem, I created two repositories:

1. [The first one](https://github.com/kymy86/cloud-phoenix-kata) is a fork of the original [Cloud Phoenix Kata](https://github.com/claranet-coast/cloud-phoenix-kata) repository. I've integrated the source code with two files:

    - `Dockerfile` to containerized the application. The Docker image has a **node:8-alpine** as base image and has been installed [chamber](https://github.com/segmentio/chamber) to inject the SSM parameter store secrets as environment variables. The image can receive as optional arguments the **chamber version** and the **node_env** variable (for building an image with only the production dependencies)
    - `.dockerignore` to ignore some files and folders during the image building process.

2. The second one is the present repository, where you can find the scripts to provision the infrastructure.

## Contents

- [Set-up instructions](setup.md)
- [Architecture](architecture.md)
- [CI/CD Pipeline](pipeline.md)

## How did I deal with the problem requirements?

1. [x] Automate the creation of the infrastructure and the setup of the application.

        I used Terraform as IaaC tool

2. [x] Recover from crashes. Implement an autorestart mechanism.

        The app has been dockerized and the container is orchestrated by ECS that ensures that the exact number of containers are running every moment.

3. [x] Backup the logs and database with a rotation of 7 days
    
        All database instances volumes are backup every 24H with a 7 days retention by using the Snapshot Lifecycle Policy service. The CloudWatch logs have a rentention option of 7 days.

4. [x] Notify any CPU peak

        The CPU peaks are notified through a CloudWatch alarm. I considered a peak, every CPU usage above 50% in one minute.

5. [x] Implements a CI/CD pipeline for the code

        The CI/CD pipeline has been implemented through CodePipeline. The pipeline is triggered by a push on the master branch, the docker image is built by a CodeBuild project and in the end, the new image is deployed in the ECS cluster.

6. [x] Scale when the number of requests is greater than 10 req /sec

        The scaling actions in the ECS cluster is driven by the ALB RequestCountPerTarget metric that indicates the average number of requests receveid by the target in a minute (the minimum granularity allowed by the CloudWatch metric)
        