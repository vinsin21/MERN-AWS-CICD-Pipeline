# Automated CI/CD Pipeline for a MERN Stack Application on AWS

This project demonstrates a complete, automated CI/CD pipeline for a containerized MERN (MongoDB, Express.js, React, Node.js) stack application. The primary goal is to showcase a practical implementation of modern DevOps practices using **AWS services** and **Docker**.

![Image](https://github.com/user-attachments/assets/093a5876-e53e-48c3-96b4-5497c9eff3b2)

When a developer pushes new code to the GitHub repository, the pipeline automatically builds, tests (optional stage), and deploys the updated application to an **Amazon EC2** instance with zero downtime.

![Image](https://github.com/user-attachments/assets/2851741f-ea10-4545-80ff-d1ef51e33193)

---

## Architecture Diagram

The pipeline follows a logical, event-driven workflow. This visual represents the flow of code from the developer's local machine to a live production environment.



**Workflow:**
1.  **Commit:** A developer commits code changes to a specific branch (e.g., `main`) in the **GitHub** repository.
2.  **Trigger:** The push event triggers **AWS CodePipeline**.
3.  **Build & Containerize:** **AWS CodeBuild** pulls the source code, builds the React and Node.js applications into separate Docker images, and pushes them to **Docker Hub** with a unique tag based on the commit hash.
4.  **Deploy:** **AWS CodeDeploy** is initiated by the pipeline. It pulls the deployment artifacts (including a dynamically updated `docker-compose.yml` file) from the build stage.
5.  **Run on EC2:** The CodeDeploy agent on the **EC2 instance** executes deployment scripts. These scripts use `docker-compose` to pull the new images from Docker Hub and run the updated application containers.

---

## Technologies Used

![Image](https://github.com/user-attachments/assets/fe78fbbe-10ad-45d8-80f9-1209e6e9897f)

* **Application:** MERN Stack (MongoDB, Express.js, React, Node.js)
* **Containerization:** Docker, Docker Compose
* **Cloud Provider:** Amazon Web Services (AWS)
* **CI/CD Services:**
    * **AWS CodePipeline:** The orchestrator for the entire CI/CD workflow.
    * **AWS CodeBuild:** For building source code and creating Docker images.
    * **AWS CodeDeploy:** For automating the deployment of the application to the EC2 instance.
* **Source Control:** GitHub
* **Artifact Repository:** Docker Hub
* **Hosting:** Amazon EC2

---


## Project Structure

```

.
├── docker-compose.yml      \# Defines the multi-container application for deployment.
├── mern/
│   ├── backend/
│   │   ├── Dockerfile      \# Instructions to containerize the Node.js/Express backend.
│   │   └── ...             \# Backend source code.
│   └── frontend/
│       ├── Dockerfile      \# Multi-stage Dockerfile to build and serve the React app with Nginx.
│       └── ...             \# Frontend source code.
├── buildspec.yml           \# Build instructions for AWS CodeBuild.
├── appspec.yml             \# Deployment specifications for AWS CodeDeploy.
└── scripts/
├── before\_install.sh   \# Script to clean the deployment directory and stop old containers.
├── start\_container.sh  \# Script to pull new images and start containers with docker-compose.
└── stop\_container.sh   \# Failsafe script to stop containers.

```
![Image](https://github.com/user-attachments/assets/865cc1bc-8b72-48c9-958d-5af454160518)

---

## Configuration Deep Dive

* **`Dockerfile`**:
    * The **backend** `Dockerfile` creates a Node.js environment, installs dependencies, and runs the server.
    * The **frontend** `Dockerfile` uses a multi-stage build. The first stage builds the React app into static files, and the second stage serves these files using a lightweight Nginx server, creating a small and efficient production image.

* **`docker-compose.yml`**:
    * This file is the blueprint for the multi-container setup on the EC2 instance. It defines three services: `frontend`, `backend`, and `mongodb`.
    * Crucially, the `image` tags are placeholders (e.g., `your-username/mern-client:latest`). The `buildspec.yml` dynamically replaces these with the correct commit-specific tags during the CI process.

* **`buildspec.yml`**:
    * This file orchestrates the entire build process within **CodeBuild**.
    * **`pre_build`**: Logs into Docker Hub using credentials stored securely in AWS Secrets Manager.
    * **`build`**: Builds both the frontend and backend Docker images.
    * **`post_build`**: Pushes the newly built images to Docker Hub. It then uses `sed` to replace the placeholder image tags in `docker-compose.yml` with the new tags, ensuring the correct versions are deployed.

* **`appspec.yml` & `scripts/`**:
    * These files manage the deployment on the EC2 instance via the **CodeDeploy** agent.
    * The `appspec.yml` file defines the sequence of operations (hooks) for a deployment: `ApplicationStop`, `BeforeInstall`, and `ApplicationStart`.
    * Each hook triggers a corresponding shell script in the `/scripts` directory to manage the Docker containers, ensuring a smooth transition from the old version to the new one.
```
