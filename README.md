# CI/CD Pipeline Project with GitHub Actions and AWS ECS

Welcome to my **CI/CD Pipeline Project**!  
This project demonstrates a fully automated CI/CD pipeline for a containerized Node.js microservice using **GitHub Actions**, **Docker**, and **AWS ECS** (Elastic Container Service).

This README explains the project structure, how the CI/CD pipeline works, and how to run the application locally.

---

## 🚀 Project Overview

The purpose of this project is to automate the entire process of **Continuous Integration (CI)** and **Continuous Deployment (CD)** using modern DevOps tools and cloud technologies.

### **Key Features**
- Fully automated CI/CD using GitHub Actions  
- Docker containerization  
- Deployment to Amazon ECS  
- Zero-downtime deployments using ECS rolling updates  

---

## 🔧 Technologies Used
- **GitHub Actions** – CI/CD automation  
- **Docker** – Containerization  
- **Amazon ECR** – Docker image storage  
- **Amazon ECS** – Deployment and orchestration  
- **Node.js (Express)** – Microservice application  

---

## 📂 Project Structure

```text
.
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions workflow
├── Dockerfile                  # Docker build file
├── .dockerignore               # Ignore files during Docker build
├── index.js                    # Node.js entry file
├── package.json                # Node.js dependencies
├── .gitignore                  # Git ignore configuration
└── README.md                   # Documentation

```

🛠️ How to Run the Project Locally
Follow these steps to run the application on your machine:

1️⃣ Clone the Repository
```bash

git clone https://github.com/Eng-Mahmoud-Walid/cicd-ecs-project.git
cd cicd-ecs-project

```

2️⃣ Install Dependencies
```bash

npm install

```

3️⃣ Build the Docker Image
```bash

docker build -t cicd-ecs-app .

```

4️⃣ Run the Docker Container
```bash

docker run -p 8080:8080 cicd-ecs-app

```

Your application will be available at:

👉 ``` http://localhost:8080 ```

🔄 CI/CD Pipeline Overview
This project includes a fully automated CI/CD pipeline using GitHub Actions.

🌟 Continuous Integration (CI)
Push code to GitHub → triggers CI

Workflow builds Docker image

Runs tests (placeholder)

Pushes the image to Amazon ECR

---

🌍 Continuous Deployment (CD)
ECS pulls the new image

ECS updates the service

Rolling deployment ensures zero downtime

⚙️ GitHub Actions Workflow (with full comments)

```yaml

name: CI/CD Pipeline to AWS ECR/ECS

# ----------------------------
# Workflow Triggers
# ----------------------------
on:
  push:
    branches:
      - main      # Trigger on push to main branch
  workflow_dispatch:  # Allow manual trigger from GitHub UI

# ----------------------------
# Global Environment Variables
# ----------------------------
env:
  AWS_REGION: ${{ secrets.AWS_REGION }}
  ECR_REPOSITORY: ${{ secrets.ECR_REPOSITORY }}

jobs:

  # ============================
  # JOB 1 — Build & Push Image
  # ============================
  build-and-push:
    name: Build and Push Docker Image to ECR
    runs-on: ubuntu-latest

    outputs:
      image_uri: ${{ steps.image.outputs.image_uri }}   # Pass image URI to next job

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4   # Pull repository code

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}   # AWS IAM Access Key
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2   # Authenticate Docker to ECR

      - name: Build, Tag, and Push Docker Image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}  # Your AWS account registry
          IMAGE_TAG: ${{ github.sha }}    # Unique tag per commit
        run: |
          echo "Building Docker image..."
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:latest .

          echo "Pushing Docker image to ECR..."
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest

      - name: Define image URI output
        id: image
        run: |
          echo "image_uri=${{ steps.login-ecr.outputs.registry }}/${{ env.ECR_REPOSITORY }}:${{ github.sha }}" >> $GITHUB_OUTPUT
          # This passes the final image URI to the deployment job

  # ============================
  # JOB 2 — Deploy to ECS
  # ============================
  deploy:
    name: Deploy to AWS ECS
    runs-on: ubuntu-latest
    needs: build-and-push    # Waits for the build job to finish

    steps:
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Deploy to ECS Service
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          cluster: ${{ secrets.ECS_CLUSTER }}           # ECS Cluster name
          service: ${{ secrets.ECS_SERVICE }}           # ECS Service name
          task-definition: ${{ secrets.ECS_TASK_DEFINITION }}  # Task definition family
          container-name: cicd-app-container            # Container name inside the task definition
          image: ${{ needs.build-and-push.outputs.image_uri }} # New Docker image to deploy

```
<img width="1362" height="764" alt="image" src="https://github.com/user-attachments/assets/69291920-de03-4924-bde6-b206cece097a" />

---
⚠️ About the AWS Credentials Error
Because the AWS credentials used in this project are fake placeholder credentials, the workflow correctly fails with:

"The security token included in the request is invalid."

This is expected.

With real AWS credentials:
✔️ Image will push to ECR
✔️ ECS will deploy successfully
✔️ The full CI/CD pipeline will work end-to-end

<img width="1865" height="1028" alt="image" src="https://github.com/user-attachments/assets/270209f5-3d76-4775-b32e-17cae20937a1" />

<img width="1849" height="1029" alt="image" src="https://github.com/user-attachments/assets/b431eb6c-4d4d-42eb-b579-b25a2b0a4fc8" />

---

🚀 Final Words
Excited to see this CI/CD pipeline in action!
Feel free to fork, clone, explore, and contribute.
More DevOps projects coming soon! 💻🔧
