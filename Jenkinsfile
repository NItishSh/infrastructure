pipeline {
  agent any
  environment {
      IMAGE = 'csnitsh/spring-petclinic'
      GIT_REPO = 'git@github.com:spring-projects/spring-petclinic.git'
      MAJOR = '0'
      MINOR = '1'
      PATCH = '0'
      RELEASE_TYPE = '-alpha' //alpha|beta|rc
      VERSION = "v${MAJOR}.${MINOR}.${PATCH}${RELEASE_TYPE}.${BRANCH_NAME}.${BUILD_NUMBER}"
      VERSION_UAT="v${MAJOR}.${MINOR}.${PATCH}-beta.${BRANCH_NAME}.${BUILD_NUMBER}"
      VERSION_PROD="v${MAJOR}.${MINOR}.${PATCH}"
      TAGS = ''
  }

  stages {
    stage ('Lint'){
      steps {
        container(name: 'python') {
          sh '''
            pylint-fail-under --fail_under 7 ./**/*.py
          '''
        }        
      }
    }    
    stage('Unit Test') {
      steps {
        container(name: 'python') {
          sh '''
            cd src
            bash unit.sh $JOB_NAME $BRANCH_NAME
          '''
        }
      }
    }    
    stage('Build Image') {
      when {
        expression {
          return env.BRANCH_NAME.startsWith("release") || env.BRANCH_NAME.startsWith('hotfix') || env.BRANCH_NAME.startsWith('development')
        }
      }
      steps {        
        container(name: 'kaniko') {                    
          sh '''          
          if [ -z $GIT_COMMIT ]
          then
            GIT_COMMIT="manual"
          fi
          GIT_BRANCH=$(echo $GIT_BRANCH | cut -d '/' -f2)
          /kaniko/executor --dockerfile `pwd`/Dockerfile --context `pwd` \
          --destination=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE}:latest \
          --destination=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE}:$BUILD_NUMBER \
          --destination=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE}:${GIT_COMMIT:0:7} \
          --destination=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE}:$GIT_BRANCH \
          --destination=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE}:$VERSION \
          --destination=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE}:$VERSION_UAT \
          --cache=true --build-arg tagger_type='ref' 
          '''
        }
      }
    }
    
    stage('DEV') {
      options {
        timeout(time: 10, unit: 'MINUTES')
      }

      when {
        expression {
          return env.BRANCH_NAME.startsWith("release") || env.BRANCH_NAME.startsWith('hotfix') || env.BRANCH_NAME.startsWith('development')
        }
      }
      input {
          message "Deploy to Dev environment?"
          ok "Yes."
          submitter "admin"          
      }
      steps {
        // kubernetesDeploy(configs: "k8sfiles/read-model-files-from-s3.yaml", kubeconfigId: "devkubeconfig")
        // sleep(50)
        // kubernetesDeploy(configs: "k8sfiles/log-level.yaml", kubeconfigId: "devkubeconfig")
        // kubernetesDeploy(configs: "k8sfiles/dev/deployment.yaml", kubeconfigId: "devkubeconfig")
        // kubernetesDeploy(configs: "k8sfiles/service.yaml", kubeconfigId: "devkubeconfig")
        // kubernetesDeploy(configs: "k8sfiles/ingress/dev/art.yaml", kubeconfigId: "devkubeconfig")
        // kubernetesDeploy(configs: "k8sfiles/hpa-cpu.yaml", kubeconfigId: "devkubeconfig")
        // sleep(300)
      }
    }
     
    stage('Test DEV') {
      when {
        expression {
            return env.BRANCH_NAME.startsWith("release") || env.BRANCH_NAME.startsWith('hotfix') || env.BRANCH_NAME.startsWith('development')
        }
      }
      steps {
        container(name: 'python') {
          sh '''
            cd test && bash test-runner.sh $JOB_NAME dev
          '''
        }
      }
      post{
        success {
          sh("git config --global user.email '"+env.GIT_USER_EMAIL+"'")
          sh("git config --global user.name '"+env.GIT_USER_NAME+"'")
          sh("git remote set-url origin "+env.GIT_REPO+"")          
          sshagent(['githubcredentials']) {
            sh("git tag -d "+env.VERSION+" | true")
            sh("git push origin :refs/tags/"+env.VERSION+" | true")
            sh("git tag -a "+env.VERSION+" -m 'Build Deployed to Dev'")
            sh "git push --tags"
          }
          archiveArtifacts artifacts: 'test/*.csv', fingerprint: true, allowEmptyArchive: true
          archiveArtifacts artifacts: 'test/*.log', fingerprint: true, allowEmptyArchive: true
          junit testResults: 'test/*dev_reports.xml', allowEmptyResults: true
        }            
      }
    }
    stage('UAT') {
      options {
        timeout(time: 10, unit: 'MINUTES') 
      }
      when {
        expression {
          return env.BRANCH_NAME.startsWith("release") || env.BRANCH_NAME.startsWith('hotfix')
        }
      }
      input {
          message "Deploy to UAT environment?"
          ok "Yes."
          submitter "admin"          
      }
      steps {
        kubernetesDeploy(configs: "k8sfiles/read-model-files-from-s3-uat.yaml", kubeconfigId: "uatkubeconfig")
        sleep(50)
        kubernetesDeploy(configs: "k8sfiles/log-level.yaml", kubeconfigId: "uatkubeconfig")
        kubernetesDeploy(configs: "k8sfiles/uat/deployment.yaml", kubeconfigId: "uatkubeconfig")
        kubernetesDeploy(configs: "k8sfiles/service.yaml", kubeconfigId: "uatkubeconfig")
        kubernetesDeploy(configs: "k8sfiles/ingress/uat/art.yaml", kubeconfigId: "uatkubeconfig")
        kubernetesDeploy(configs: "k8sfiles/hpa-cpu.yaml", kubeconfigId: "uatkubeconfig")
        sleep(300)
      }
    }
    stage('Test UAT') {
      when {
        expression {
            return env.BRANCH_NAME.startsWith("release") || env.BRANCH_NAME.startsWith('hotfix')
        }
      }
      steps {
        container(name: 'python') {
          sh '''
            cd test && bash test-runner.sh $JOB_NAME uat
          '''
        }
      }
      post{
        success {
          container(name: 'kaniko') {
            sh '''
              echo "FROM  ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE}:${VERSION}" | /kaniko/executor --context `pwd` --dockerfile /dev/stdin --destination ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE}:${VERSION_UAT}
            '''
          }
          sh("git config --global user.email '"+env.GIT_USER_EMAIL+"'")
          sh("git config --global user.name '"+env.GIT_USER_NAME+"'")
          sh("git remote set-url origin "+env.GIT_REPO+"")
          sshagent(['githubcredentials']) {
            sh("git tag -d "+env.VERSION+"")
            sh("git push origin :refs/tags/"+env.VERSION+"")
            sh("git push origin :refs/tags/"+env.VERSION_UAT+"")
            sh("git tag -a "+env.VERSION_UAT+" -m 'Build Deployed to UAT'")
            sh "git push --tags"
          }
          archiveArtifacts artifacts: 'test/*.csv', fingerprint: true, allowEmptyArchive: true
          archiveArtifacts artifacts: 'test/*.log', fingerprint: true, allowEmptyArchive: true
          junit testResults: 'test/*uat_reports.xml', allowEmptyResults: true
        }             
      }
    }
    stage('Production') {
      when {
        expression {
          return env.BRANCH_NAME.startsWith("release") || env.BRANCH_NAME.startsWith('hotfix')
        }
      }
      input {
          message "Deploy to Production environment?"
          ok "Yes."
          submitter "admin"          
      }
      steps {
          kubernetesDeploy(configs: "k8sfiles/read-model-files-from-s3-prod.yaml", kubeconfigId: "prodkubeconfig")
          sleep(50)
          kubernetesDeploy(configs: "k8sfiles/log-level.yaml", kubeconfigId: "prodkubeconfig")
          kubernetesDeploy(configs: "k8sfiles/prod/deployment.yaml", kubeconfigId: "prodkubeconfig")
          kubernetesDeploy(configs: "k8sfiles/service.yaml", kubeconfigId: "prodkubeconfig")
          kubernetesDeploy(configs: "k8sfiles/ingress/prod/art.yaml", kubeconfigId: "prodkubeconfig")
          kubernetesDeploy(configs: "k8sfiles/hpa-cpu.yaml", kubeconfigId: "prodkubeconfig")
          sleep(300)
      }
      post{
        success {
          container(name: 'kaniko') {
            sh '''
              echo "FROM  ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE}:${VERSION_UAT}" | /kaniko/executor --context `pwd` --dockerfile /dev/stdin --destination ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE}:${VERSION_PROD}
            '''
          }
          sh("git config --global user.email '"+env.GIT_USER_EMAIL+"'")
          sh("git config --global user.name '"+env.GIT_USER_NAME+"'")
          sh("git remote set-url origin "+env.GIT_REPO+"")
          sshagent(['githubcredentials']) {
            sh("git tag -d "+env.VERSION_UAT+"")
            sh("git push origin :refs/tags/"+env.VERSION_UAT+"")
            sh("git push origin :refs/tags/"+env.VERSION_PROD+"")
            sh("git tag -a "+env.VERSION_PROD+" -m 'Build Deployed to PROD'")
            sh "git push --tags"
          }
        }             
      }
    }
  }
}