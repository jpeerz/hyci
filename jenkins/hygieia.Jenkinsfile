node ('web') {

    //git url: 'https://github.com/amazonexplorer/Hygieia.git', branch: "master"
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
            do_maven("-Dmaven.test.skip=true -Dlicense.skip=true clean install package")
        } catch(Exception err) {
            echo "Compilation ${env.BRANCH_NAME}#$BUILD_NUMBER FAILED [${JOB_URL}]"
            throw err
        }
    }
}

def do_maven(mvn_task){
    def MAVEN = tool 'MAVEN3'
    try{
        sh "export MAVEN_OPTS='-Xms128m -Xmx128m -XX:+HeapDumpOnOutOfMemoryError'"
        sh "$MAVEN/bin/mvn $mvn_task"
    } catch(Exception err) {
        throw err
    }
}
