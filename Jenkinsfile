pipeline {
    agent any
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Select the environment to deploy to')
        string(name: 'AWS_REGION', defaultValue: 'eu-west-2', description: 'AWS region for deployment and backend')
        string(name: 'PROJECT_NAME', defaultValue: 'docker', description: 'Project name')
        string(name: 'DEFAULT_ROUTE', defaultValue: '0.0.0.0/0', description: 'Default route CIDR')
        string(name: 'VPC_CIDR', defaultValue: '172.16.0.0/16', description: 'VPC CIDR block')
        string(name: 'MY_IP', defaultValue: '105.113.52.90/32', description: 'Your IP address for security group')
        string(name: 'PORTNUMBER', defaultValue: '["80", "81", "22"]', description: 'List of ports for security group')
        string(name: 'EC2_INSTANCE_TYPE', defaultValue: 't2.micro', description: 'EC2 instance type')
        string(name: 'DELETE_WINDOWS', defaultValue: '7', description: 'KMS key deletion window in days')
        string(name: 'KEY_ROTATION_DAYS', defaultValue: '365', description: 'KMS key rotation period in days')
        string(name: 'TF_BACKEND_BUCKET', defaultValue: 'infrabucket-iacgitops', description: 'S3 bucket for Terraform state')
        string(name: 'TF_BACKEND_KEY', defaultValue: "module/state.tfstate", description: 'Terraform state key name')
        booleanParam(name: 'TF_BACKEND_ENCRYPT', defaultValue: true, description: 'Enable encryption for Terraform state')
        booleanParam(name: 'TF_LOCKFILE', defaultValue: true, description: 'Enable encryption for Terraform state')
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Terraform action to perform')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'tf_module/cicd-jenkins', url: 'https://github.com/seunayolu/terraform-files.git'
            }
        }
        stage('Generate tfvars') {
            steps {
                script {
                    writeFile file: 'variables.tfvars', text: """
                        aws_region = "${params.AWS_REGION}"
                        project_name = "${params.PROJECT_NAME}"
                        environment = "${params.ENVIRONMENT}"
                        default-route = "${params.DEFAULT_ROUTE}"
                        vpc_cidr = "${params.VPC_CIDR}"
                        my_ip = "${params.MY_IP}"
                        portnumber = ${params.PORTNUMBER}
                        ec2_instance_type = "${params.EC2_INSTANCE_TYPE}"
                        delete_windows = ${params.DELETE_WINDOWS}
                        key_rotation_days = ${params.KEY_ROTATION_DAYS}
                    """
                }
            }
        }
        stage('Terraform Init') {
            steps {
                script {
                    try {
                        sh """
                            terraform init \
                                -backend-config="bucket=${params.TF_BACKEND_BUCKET}" \
                                -backend-config="key=${params.ENVIRONMENT}-${params.TF_BACKEND_KEY}" \
                                -backend-config="region=${params.AWS_REGION}" \
                                -backend-config="use_lockfile=${params.TF_LOCKFILE}" \
                                -backend-config="encrypt=${params.TF_BACKEND_ENCRYPT}"
                        """
                    } catch (Exception e) {
                        echo "Error during terraform init: ${e.getMessage()}"
                        error "Terraform init failed. Check backend configuration or IAM role permissions."
                    }
                }
            }
        }
        stage('Terraform Workspace') {
            steps {
                script {
                    sh """
                        terraform workspace select ${params.ENVIRONMENT} || terraform workspace new ${params.ENVIRONMENT}
                    """
                }
            }
        }
        stage('Terraform Plan') {
            when {
                expression { params.ACTION == 'apply'}
            }
            steps {
                sh "terraform plan -var-file=variables.tfvars -out=tfplan"
            }
        }
        stage('Approval for Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                input message: "Approve Terraform apply for ${params.ENVIRONMENT} environment?", ok: 'Apply'
            }
        }
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh 'terraform apply tfplan'
            }
        }
        stage('Archive Keypair') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    archiveArtifacts artifacts: "modules/keypair/${params.ENVIRONMENT}-${params.PROJECT_NAME}.pem", allowEmptyArchive: false
                }
            }
        }
        stage('Approval for Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                input message: "Approve Terraform destroy for ${params.ENVIRONMENT} environment?", ok: 'Destroy'
            }
        }
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                sh "terraform destroy -var-file=variables.tfvars -auto-approve"
            }
        }
    }
    post {
        always {
            cleanWs() // Clean workspace after pipeline execution
        }
        success {
            echo "Terraform ${params.ACTION} completed successfully for ${params.ENVIRONMENT} environment."
        }
        failure {
            echo "Pipeline failed. Please check the logs."
        }
    }
}