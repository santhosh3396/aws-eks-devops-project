pipeline {

    agent any

    environment {
        AWS_REGION     = 'ap-south-1'
        ECR_REPO       = 'flask-app'
        ACCOUNT_ID     = credentials('aws-account-id')
        ECR_REGISTRY   = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_TAG       = "${BUILD_NUMBER}"
    }

    stages {

        stage('Git Clone') {
            steps {
                checkout scm
                echo "Branch: ${GIT_BRANCH}"
                echo "Commit: ${GIT_COMMIT}"
            }
        }

        stage('Docker Build') {
            steps {
                sh """
                    docker build -t ${ECR_REPO}:${IMAGE_TAG} ./app
                    docker tag ${ECR_REPO}:${IMAGE_TAG} ${ECR_REPO}:latest
                """
            }
        }

        stage('ECR Login') {
            steps {
                sh """
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REGISTRY}
                """
            }
        }

        stage('Docker Push to ECR') {
            steps {
                sh """
                    docker tag ${ECR_REPO}:${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}
                    docker tag ${ECR_REPO}:latest ${ECR_REGISTRY}/${ECR_REPO}:latest
                    docker push ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}
                    docker push ${ECR_REGISTRY}/${ECR_REPO}:latest
                """
            }
        }

        stage('Update Kubeconfig') {
            steps {
                sh """
                    aws eks update-kubeconfig \
                    --region ${AWS_REGION} \
                    --name devops-eks
                """
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
                    sed -i 's|ACCOUNT_ID|${ACCOUNT_ID}|g' kubernetes/deployment.yaml
                    kubectl apply -f kubernetes/deployment.yaml
                    kubectl apply -f kubernetes/service.yaml
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                sh """
                    kubectl rollout status deployment/flask-app
                    kubectl get pods
                    kubectl get svc flask-service
                """
            }
        }
    }

    post {
        success {
            echo "✅ Deployment Successful - Build #${BUILD_NUMBER}"
        }
        failure {
            echo "❌ Deployment Failed - Build #${BUILD_NUMBER}"
        }
        always {
            sh 'docker system prune -f'
        }
    }
}
