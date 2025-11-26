# CI/CD Pipeline Project with GitHub Actions and AWS ECS

Welcome to my **CI/CD Pipeline Project**! In this project, I will demonstrate how I implemented a fully automated CI/CD pipeline for a containerized Node.js microservice using **GitHub Actions**, **Docker**, and **AWS ECS** (Elastic Container Service). 

This README will guide you through the project structure, how it works, and how to set it up on your local machine or cloud environment.

## 🚀 **Project Overview**

The goal of this project is to automate the process of Continuous Integration and Continuous Deployment (CI/CD) using the tools and technologies I’ve learned along my **DevOps journey**.

**Key Features**:
- **Continuous Integration (CI)** using **GitHub Actions**.
- **Docker** for containerization.
- **AWS ECS** for deploying and scaling the application.
- **Zero Downtime Deployment** through ECS rolling updates.

---

## 🔧 **Technologies Used**
- **GitHub Actions**: Automating the CI/CD pipeline.
- **Docker**: Containerizing the application for portability and scalability.
- **AWS ECS**: Deploying and managing the application in the cloud.
- **Amazon ECR**: Storing and managing Docker images.

---

## 📦 **Project Structure**

Here’s an overview of the project’s structure:

├── .github/
│ └── workflows/
│ └── deploy.yml # GitHub Actions workflow file
├── Dockerfile # Docker configuration for building the app image
├── .dockerignore # Ignored files for Docker build
├── index.js # Application entry point (Node.js app)
├── package.json # Project dependencies and scripts
├── .gitignore # Git ignored files
└── README.md # Project documentation

---

🔄 CI/CD Pipeline Overview
The CI/CD pipeline is fully automated using GitHub Actions. Below is the breakdown of how the pipeline works:

Continuous Integration (CI) Steps:
Push Code to GitHub 💻: Push your changes to the GitHub repository to trigger the pipeline.

Trigger CI Workflow ⚡: The pipeline is automatically triggered when you push code to the main branch.

Build Docker Image 🐳: The pipeline builds the Docker image for the application.

Run Tests 🔍: Automated tests are run to verify the functionality of the code.

Push Docker Image to ECR/Docker Hub 🏞️: Once the tests pass, the Docker image is pushed to a container registry (ECR or Docker Hub).

Continuous Deployment (CD) Steps:
Pull Docker Image for Deployment 🔄: The pipeline pulls the Docker image from the container registry.

Deploy to AWS ECS 🖥️: The app is deployed to AWS ECS, where it’s hosted and managed in the cloud.

Zero Downtime Deployment 🔄✅: The deployment uses ECS rolling updates to ensure zero downtime for users.

⚙️ How the CI/CD Works with GitHub Actions
The entire process is automated with GitHub Actions. Here’s the GitHub Actions workflow file (.github/workflows/deploy.yml), which contains the full pipeline configuration:

```yaml

name: CI/CD Pipeline to AWS ECR/ECS

# Workflow triggers
on:
  # Run when changes are pushed to the main branch
  push:
    branches:
      - main
  # Allows manual runs from the GitHub UI
  workflow_dispatch:

# Environment variables used throughout the workflow
env:
  AWS_REGION: ${{ secrets.AWS_REGION }}
  ECR_REPOSITORY: ${{ secrets.ECR_REPOSITORY }}

jobs:
  build-and-push:
    name: Build and Push Docker Image to ECR
    runs-on: ubuntu-latest

    # Define outputs to be used by the next job (deploy)
    outputs:
      image_uri: ${{ steps.image.outputs.image_uri }}

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      # 1. Configuration of AWS credentials using GitHub Secrets
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      # 2. Log in to the Amazon ECR registry
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      # 3. Build, Tag, and Push the Docker Image
      - name: Build, Tag, and Push Docker Image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          # Use commit SHA for unique versioning
          IMAGE_TAG: ${{ github.sha }} 
        run: |
          # Build the image using the ECR registry URI and repository name
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:latest .

          # Push both the specific tag and the latest tag to ECR
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest

      # 4. Define the output image URI
      - name: Define image URI output
        id: image
        run: echo "image_uri=$(echo ${{ steps.login-ecr.outputs.registry }}/${{ env.ECR_REPOSITORY }}:${{ github.sha }})" >> $GITHUB_OUTPUT

  deploy:
    name: Deploy to AWS ECS
    runs-on: ubuntu-latest
    # This job waits for the build-and-push job to successfully complete
    needs: build-and-push 

    steps:
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      # Deploy to ECS Service using the aws-actions/amazon-ecs-deploy-task-definition Action
      - name: Deploy to ECS Service
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          # Cluster and Service names from GitHub Secrets
          cluster: ${{ secrets.ECS_CLUSTER }}
          service: ${{ secrets.ECS_SERVICE }}

          # Task definition family name from GitHub Secrets
          task-definition: ${{ secrets.ECS_TASK_DEFINITION }}

          # The container name used in your Task Definition
          container-name: cicd-app-container 

          # The image URI built in the previous job
          image: ${{ needs.build-and-push.outputs.image_uri }}

```     
🌍 Deployment on AWS ECS
Once the CI/CD pipeline is successfully executed, the application is deployed to AWS ECS (Elastic Container Service). AWS ECS handles the orchestration and scaling of the application container.
---
