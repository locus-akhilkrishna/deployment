try {
  node('slave-01'){

    notifyBuild('STARTED')
    def imageId = "registry-intl.cn-hongkong.aliyuncs.com/locusaliyun/interenal-dashboard"
    def dockerUrl = "registry-intl.cn-hongkong.aliyuncs.com"
    def namespace = "developement"
    def GIT_URL = "git@github.com:locus-taxy/locus-internal-dashboard.git"
    def SWAGGER_USER = "artifact-reader"
    def SWAGGER_PASSWORD = "AP5Z7D3RBpLbCQRM8gNizm8yXv1"

    stage('PreCheck') {
      sh '''
  			echo "###################### Checking for environment variables ######################"
  			[ -z $BUCKET  ] && echo "Pass BUCKET name as string parameter" && exit 1;
  			[ -z $GIT_URL ] && echo "Pass GIT_URL as string parameter" && exit 1;
  			echo "########################### Variables Check Success ############################"
  			'''
    }
    stage('Checkout') {
      dir('InternalDashboard')
      {
          git branch: "${BRANCH}", credentialsId: 'github', url: "${GIT_URL}"
      }
      dir('DEPLOYMENT')
      {
          checkout scm
      }
    }
    stage('PreDeploy') {
      docker.image('openjdk:8-jre-stretch').inside("-e USER=${SWAGGER_USER} -e PASSWORD=${SWAGGER_PASSWORD} -v ${WORKSPACE}/InternalDashboard:/InternalDashboard") {
        sh """
            apt-get update
            apt-get install jq -y
            bash /InternalDashboard/generate_swagger_clients.sh"""
      }
    }
    def shortCommit = sh(returnStdout: true, script: "cd InternalDashboard ; git log -n 1 --pretty=format:'%h'").trim()
    stage('Docker Image Build and Push') {
      docker.withRegistry("${dockerUrl}", 'alicloudecr') {
          def internaldashboard = docker.build("${imageId}:${shortCommit}","DEPLOYMENT/Dockerfile")
          internaldashboard.push()
      }
    }
  }
  stage ("UserInput"){
    def userInput
    def user
    try {
        timeout(time:2, unit:'DAYS') {
          userInput = input(
            id: 'Proceed1', message: 'Approve deployment?', parameters: [
            [$class: 'BooleanParameterDefinition', defaultValue: true, description: '', name: 'Approve deployment?']
            ])
        }
    } catch(err) { // input false
        user = err.getCauses()[0].getUser()
        userInput = false
        echo "Aborted by: [${user}]"
    }
  }

  node('slave-01'){
    if(userInput == true){
      stage('Kubernetes Config Creation') {
          sh "sed -i -e 's/NAMESPACE/${namespace}/g' -e 's/IMAGEID/${imageId}/g'  -e 's/TAG/${shortCommit}/g' ./InternalDashboard/internaldashboard.yaml"
      }

      stage ('Deployment')
      {
        withKubeConfig([credentialsId: 'user1']) {
          sh "kubectl get ns ${namespace} || kubectl create ns ${namespace}"
          sh "kubectl --namespace=${namespace} apply -f InternalDashboard/internaldashboard.yaml"
        }
      }
    }
    else {
      currentBuild.result = 'ABORTED'
    }
  }
}
catch (e) {
  currentBuild.result = "FAILED"
  throw e
} finally {
    notifyBuild(currentBuild.result)
}
def notifyBuild(String buildStatus = 'STARTED') {

  buildStatus =  buildStatus ?: 'SUCCESSFUL'
  def colorName = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"

  if (buildStatus == 'STARTED') {
    color = 'YELLOW'
    colorCode = '#FFFF00'
  } else if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else if (buildStatus == 'ABORTED') {
    color = 'GRAY'
    colorCode = '#808080'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  // Send notifications
  slackSend (color: colorCode, message: summary)
}
