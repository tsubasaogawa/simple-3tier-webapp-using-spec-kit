# Research: GitHub Actions を用いた CI/CD 基盤の構築

## 1. Cloud Provider Selection

-   **Task**: "Research cloud provider for hosting a Python (FastAPI) application in a containerized environment."
-   **Decision**: AWS (Amazon Web Services)
-   **Rationale**:
    -   **Existing Infrastructure**: The project already uses Terraform for infrastructure management, and there are existing Terraform files for AWS services (VPC, ECS, DynamoDB). Leveraging the existing setup reduces complexity and effort.
    -   **Managed Services**: AWS offers a rich set of managed services like ECS (Elastic Container Service) and ECR (Elastic Container Registry) that are well-suited for containerized applications and integrate seamlessly.
    -   **Scalability & Reliability**: AWS provides a robust, scalable, and reliable infrastructure, which is ideal for a 3-tier web application.
-   **Alternatives considered**:
    -   **Google Cloud Platform (GCP)**: A strong competitor with services like Cloud Run and GKE. However, it would require creating new Terraform configurations from scratch.
    -   **Microsoft Azure**: Offers Azure App Service and AKS. Similar to GCP, it would require a new set of infrastructure configurations.

## 2. Container Registry Selection

-   **Task**: "Research container registry for storing Docker images."
-   **Decision**: Amazon ECR (Elastic Container Registry)
-   **Rationale**:
    -   **Integration with AWS**: As the chosen cloud provider is AWS, using ECR is the natural choice. It offers tight integration with ECS, IAM for security, and other AWS services.
    -   **Security**: ECR provides vulnerability scanning for container images, enhancing the security of the CI/CD pipeline.
    -   **Private Repositories**: It allows for private repositories, ensuring that the application's container images are not publicly accessible.
-   **Alternatives considered**:
    -   **Docker Hub**: A popular choice, but for a private project, it requires a paid plan. Integration with AWS IAM is less direct than ECR.
    -   **Google Container Registry (GCR)**: Best suited for projects running on GCP.

## 3. Linting Tool Selection

-   **Task**: "Research Python linting tool for the project."
-   **Decision**: Ruff
-   **Rationale**:
    -   **Performance**: Ruff is written in Rust and is significantly faster than traditional Python linters like Flake8 and Pylint. This speed is beneficial for a fast CI/CD pipeline.
    -   **All-in-one Tool**: It combines the functionality of multiple tools (linter, formatter, import sorter) into a single binary, simplifying configuration and dependencies. It is a modern replacement for tools like Flake8, isort, and black.
    -   **Compatibility**: It is compatible with existing Flake8 configurations, making migration easier if needed.
-   **Alternatives considered**:
    -   **Flake8**: A widely used and respected linter, but it is slower than Ruff and requires plugins for additional functionality (like import sorting).
    -   **Pylint**: Very powerful and configurable, but can be slow and often requires significant configuration to avoid being overly verbose.
