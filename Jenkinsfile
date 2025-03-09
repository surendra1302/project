pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = "us-east-1"
//        PRIVATE_KEY_FILE      = "${env.WORKSPACE}/.ssh/my-aws-key.pem"
        PRIVATE_KEY_FILE      = "/var/lib/jenkins/workspace/first_job3/.ssh/my-aws-key.pem"
        INVENTORY_FILE        = "inventory.ini"
    }

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Apply automatically?')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Destroy infrastructure?')
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    sh 'rm -rf terraform && git clone https://github.com/surendra1302/project.git terraform'
                }
            }
        }

        stage('Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Plan') {
            when {
                not { equals expected: true, actual: params.destroy }
            }
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Approval') {
            when {
                not { equals expected: true, actual: params.autoApprove }
                not { equals expected: true, actual: params.destroy }
            }
            steps {
                script {
                    def plan = readFile 'terraform/tfplan'
                    input message: "Approve Terraform Plan?", parameters: [text(name: 'Plan', description: 'Terraform Plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply') {
            when {
                not { equals expected: true, actual: params.destroy }
            }
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                    sh 'terraform output -raw public_ip > public_ip.txt'
                }
            }
        }

        stage('Ansible Configuration') {
            when {
                not { equals expected: true, actual: params.destroy }
            }
            steps {
                script {
                    //sh 'terraform init -reconfigure'
                    sh 'echo "your_password" | sudo -S su'
                    def ec2_public_ip = sh(script: "cd terraform && terraform output -raw public_ip", returnStdout: true).trim()

                    writeFile file: "${INVENTORY_FILE}", text: """
                    [web]
                    ${ec2_public_ip} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=${PRIVATE_KEY_FILE}
                    """

                    sh """
                    cat ${INVENTORY_FILE}  # Debugging step to verify the inventory file
                    ansible-playbook -i ${INVENTORY_FILE} ansible/playbook.yml
                    """
                }
            }
        }

        stage('Destroy') {
            when {
                equals expected: true, actual: params.destroy
            }
            steps {
                dir('terraform') {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }

    post {
        success {
            echo "Infrastructure Deployed & Configured Successfully!"
        }
        failure {
            echo "Pipeline Failed!"
        }
    }
}
