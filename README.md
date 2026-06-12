# AWS EKS DevOps Project

End-to-End CI/CD pipeline deploying a containerized Flask application to Amazon EKS using Terraform, Jenkins, Docker, and ECR.

## Architecture

```
Developer → GitHub
               ↓
           Jenkins CI/CD
               ↓
         Docker Build & Test
               ↓
         Amazon ECR (Image Registry)
               ↓
         Amazon EKS (Kubernetes Cluster)
               ↓
         LoadBalancer Service
               ↓
             Users
```

## Technologies Used

| Tool | Purpose |
|------|---------|
| AWS EKS | Managed Kubernetes cluster |
| AWS ECR | Container image registry |
| Terraform | Infrastructure as Code |
| Jenkins | CI/CD pipeline |
| Docker | Containerization |
| Kubernetes | Container orchestration |
| Flask | Sample Python application |
| GitHub | Source code management |

## Repository Structure

```
aws-eks-devops-project/
├── app/
│   ├── app.py              # Flask application
│   ├── requirements.txt    # Python dependencies
│   └── Dockerfile          # Container image definition
├── terraform/
│   ├── provider.tf         # AWS provider + S3 backend
│   ├── variables.tf        # Input variables
│   ├── vpc.tf              # VPC, subnets, routing
│   ├── eks.tf              # EKS cluster + ECR repo
│   └── outputs.tf          # Output values
├── kubernetes/
│   ├── deployment.yaml     # K8s deployment with probes
│   └── service.yaml        # LoadBalancer service
├── Jenkinsfile             # CI/CD pipeline definition
└── README.md
```

## Pipeline Flow

1. Developer pushes code to GitHub
2. Jenkins detects change and triggers pipeline
3. Docker builds the Flask app image
4. Image is tagged with build number and pushed to ECR
5. Jenkins updates kubeconfig for EKS
6. kubectl applies deployment and service manifests
7. Rollout status verified — pods confirmed running

## Infrastructure Setup

```bash
cd terraform

terraform init
terraform plan
terraform apply
```

## Deploy Application Manually

```bash
# Configure kubectl
aws eks update-kubeconfig --region ap-south-1 --name devops-eks

# Deploy
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

# Verify
kubectl get pods
kubectl get svc flask-service
kubectl rollout status deployment/flask-app
```

## Key Concepts Demonstrated

- Infrastructure as Code with Terraform (VPC, EKS, ECR)
- Multi-stage Jenkins pipeline with post-build actions
- Docker best practices (non-root user, layer caching, pinned versions)
- Kubernetes rolling updates with zero downtime
- Liveness and Readiness probes for self-healing
- Resource requests and limits
- AWS ECR image scanning on push
- Build-number-based image tagging
