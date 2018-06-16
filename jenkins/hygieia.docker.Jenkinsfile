node ('docker-one') {

    checkout scm: [$class: 'GitSCM', userRemoteConfigs: [[url: 'https://github.com/amazonexplorer/Hygieia.git']], branches: [[name: 'refs/tags/Hygieia-2.0.4']]], poll: false
    
    properties([
        buildDiscarder(
            logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '3', numToKeepStr: '3')
        ), 
        disableConcurrentBuilds(), 
        pipelineTriggers([])
    ])
    
    stage('Fetch Code and Build') {
        try {
            docker.image('docker.io/nginx:latest').inside('-v $HOME/.m2:/root/.m2') {
                stage('Build') {
                    sh 'nginx -V'
                }
            }
        } catch(Exception err) {
            echo "Compilation ${env.BRANCH_NAME}#$BUILD_NUMBER FAILED [${JOB_URL}]"
            throw err
        }
    }
}
