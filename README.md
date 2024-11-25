# Kubernetes Configuration with Jenkins Pipeline

## 🛈 Overview

This repo contains [Kubernetes](https://kubernetes.io/) configuration files used for deploying the application to staging and production environments. The configuration is organized into modules for each service, including both front-end and back-end services.

## 🧰 Components

- **Manifests**:
    - `deployment.yaml`: Defines the deployment configurations for the service.
    - `service.yaml`: Specifies the service configuration for exposing the deployment.
    - `secret.yaml`: Contains sensitive data which should be stored as base64 type.
    - `configMap.yaml`: Stores non-confidential data in key-value pairs.
    - `ingress.yaml`: Configures ingress rules for external access to the services.
    - `persistentVolume.yaml`: Defines persistent storage volumes.
    - `kustomization.yaml`: Create variations of K8s resources and configurations for specific use cases.

- **Staging Environment**
    - A K8s cluster set up for staging environment using Terraform & Ansible with kubeadm tool. I already have a repo that sets up the cluster like the architecture below 👉 [Here](https://github.com/NT114-O21-DACN-DevOps/class-management-terraform-ansible)

<br>

<p align="center">
    <img src="./images/stag-environment.png" alt="Stag Environment"></img>
</p>

- **Production Environment**
    - A K8s cluster set up for production environment using [**AWS EKS**](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html) service. You can follow this link to create your own cluster: [Set up to use Amazon EKS
](https://docs.aws.amazon.com/eks/latest/userguide/setting-up.html)

<br>

<p align="center">
    <img src="./images/prod-environment.png" alt="Prod Environment"></img>
</p>

## 🚀 Getting Started

### Prerequisites

- **Kubernetes clusters**: Ensure you have a K8s clusters set up for staging and production environments.
- `kubectl`: Install and configure `kubectl` to interact with your K8s cluster.<br>
&rarr; you need to configure the config file in `.kube` folder after installing `kubectl` tool. Follow the instructions [here](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/ "kubectl install").
- **Jenkins**: Set up Jenkins for CI/CD pipelines to deploy the application to K8s clusters.
- **SonarQube**: Configure SonarQube for code quality analysis in the CI/CD pipeline.
- **Trivy**: Integrate Trivy for scanning Docker images for vulnerabilities.

### Setup manual

1. **Clone the repository**:

```bash
git clone https://github.com/NT114-O21-DACN-DevOps/class-management-k8s-config.git
cd class-management-k8s-config
```

2. **Apply the manifests**
- Because of using `kustomization` file, you only need to apply all of the config files with **1** command:

```bash
kubectl apply -k .
```

### Setup with Jenkins Pipeline

1. **Prepare Jenkins Pipeline**
- Add the necessary credentials for accessing the K8s clusters, GitHub repository, SonarQube, and other services.
<p align="center">
    <img src="./images/credentials.png" alt="Prod Environment"></img>
</p>
- Add SonarQube server in Jenkins configuration.
<p align="center">
    <img src="images/sonarqube-config.png" alt="Prod Environment"></img>
</p>
- Add SonarQube scanner in Jenkins configuration.
<p align="center">
    <img src="./images/sonarqube-scanner.png" alt="Prod Environment"></img>
</p>

2. **Create a new pipeline in Jenkins**
- Create a new pipeline and configure the pipeline script to deploy the application to the K8s clusters.
- You can use the `Jenkinsfile` in this repository as a reference for the pipeline script.
<p align="center">
    <img src="./images/jenkins-pipeline-config.png" alt="Jenkins Pipeline">
</p>

3. **Run the Jenkins Pipeline**
- Run the Jenkins pipeline to deploy the application to the staging and production environments.
<p align="center">
    <img src="./images/jenkins-pipeline-run.png" alt="Jenkins Pipeline"></img>
</p>

## Notes

- Ensure that the `configMap.yaml` and `secret.yaml` files contain appropriate configurations and sensitive data for each environment.
- Update `ingress.yaml` with the correct rules for routing external traffic to your services.
- Review the `persistentVolume.yaml` to configure persistent storage as required by your application.
