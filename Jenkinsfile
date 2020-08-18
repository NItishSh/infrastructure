pipeline {
    agent any
    environment{
        majorversion='0'
        minorversion='0'
        patchnumber='0'
        releasetype=""
        version="v${majorversion}.${minorversion}.${patchnumber}"
        version_long="v${majorversion}.${minorversion}.${patchnumber}-${releasetype}.${BUILD_NUMBER}"
    }
    stages {
        stage('clone code') {
            steps {
                sh 'git clone https://github.com/spring-projects/spring-petclinic.git'
            }
        }
        stage ('unit test'){
            steps{
                sh 'unit test place holder'
            }
        }
        stage ('integration tests'){
            steps{
                sh 'integration test  place holder'
            }
        }
        stage ('code analysis'){
            steps{
                sh 'code analysis place holder'
            }
        }

        stage ('package java app'){
            steps{
                sh 'cd spring-petclinic && ./mvnw package'
            }
        }

        stage('docker image'){
            // agent any
            steps{
                sh 'docker build .'
            }
        }

        stage('tag the image'){
            // agent any
            steps{
                sh "docker tag -t ${version}"
            }
        }
        stage('push to docker registry'){
            // agent any
            steps{
                sh "dokcer push csnitsh/spring-petclinic:${version}"
            }
        }

        stage('deploy petclinic'){
            // agent any
            steps{
                // hope the job is using ec2-user.
                // permission has to be set for /home/ec2-user/.ansible/petclinic/playbook-petclinic.yaml and /home/ec2-user/.ansible/hosts
                sh "ansible-playbook /home/ec2-user/.ansible/petclinic/playbook-petclinic.yaml -i /home/ec2-user/.ansible/hosts --extra-vars \"petclinic_version=${version}\""
            }
        }
    }
}