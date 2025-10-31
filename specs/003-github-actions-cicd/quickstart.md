# Quickstart: CI/CD Pipeline with GitHub Actions

This document provides a guide for developers on how to use the new CI/CD pipeline.

## Overview

The CI/CD pipeline is built using GitHub Actions and automates the process of testing, building, and deploying the application. The pipeline is divided into two main workflows:

1.  **Continuous Integration (CI)**: Triggered on every push to a feature branch.
2.  **Continuous Deployment (CD)**: Triggered on every merge to the `main` branch.

## CI Workflow

-   **Trigger**: `git push` to any branch except `main`.
-   **Jobs**:
    1.  **Lint**: Runs `ruff` to check the Python code for style and quality issues.
    2.  **Test**: Runs `pytest` to execute the unit tests.
-   **Outcome**: Provides feedback on the code quality of the pushed commit. A failed workflow indicates that the code does not meet the quality standards and should be fixed before creating a pull request.

## CD Workflow

-   **Trigger**: Merge to the `main` branch.
-   **Jobs**:
    1.  **Build and Push Image**:
        -   Builds a Docker image of the application.
        -   Tags the image with the Git commit SHA.
        -   Pushes the image to the Amazon ECR repository.
    2.  **Deploy to Staging**:
        -   Uses Terraform to apply the infrastructure changes.
        -   Updates the Amazon ECS service to use the newly pushed Docker image.
-   **Outcome**: Deploys the new version of the application to the staging environment.

## How to Use

1.  **Create a feature branch**:
    ```bash
    git checkout -b feature/my-new-feature
    ```
2.  **Make your changes and commit them**:
    ```bash
    git commit -am "feat: add my new feature"
    ```
3.  **Push your branch to GitHub**:
    ```bash
    git push origin feature/my-new-feature
    ```
    -   This will trigger the **CI workflow**. Check the "Actions" tab in the GitHub repository to see the results.
4.  **Create a Pull Request**:
    -   Once the CI workflow passes and your feature is ready, create a pull request to merge your branch into `main`.
5.  **Merge the Pull Request**:
    -   After the pull request is reviewed and approved, merge it.
    -   This will trigger the **CD workflow**, which will deploy your changes to the staging environment.

## Monitoring

-   The status of all workflows can be monitored from the **"Actions"** tab in the GitHub repository.
-   Deployment status in the staging environment can be checked from the AWS Management Console for Amazon ECS.
