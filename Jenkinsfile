pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = "us-east-1"
	private_key_file      = "${env.WORKSPACE}/.ssh/my-aws-key"
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
        }
    }
}

	stage('Ansible Configuration') {
   	    steps {
        	script {
			sh 'terraform init -reconfigure'
            		// Get Terraform output dynamically
            		def publicIp = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()

	                // Print public IP for debugging
            		echo "Public IP: ${publicIp}"

	                // Run Ansible playbook with dynamic inventory
            		sh """
            		 echo "[web]" > inventory.ini
           		 echo "${publicIp} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/var/lib/jenkins/workspace/terraform-ansible/.ssh/my-aws-key.pem" >> inventory.ini
 	                 ansible-playbook -i inventory.ini playbook.yml
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

