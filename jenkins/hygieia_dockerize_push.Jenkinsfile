node ("build"){
   
    properties([
        buildDiscarder(
            logRotator(
                artifactDaysToKeepStr: '',
                artifactNumToKeepStr: '',
                daysToKeepStr: '3',
                numToKeepStr: '3'
            )
        ), 
        disableConcurrentBuilds(), 
        pipelineTriggers([]),
        parameters([
            string(
                name: 'HYGIEIA_RELEASE',
                defaultValue: 'Hygieia-2.0.4',
                description: 'Release tag to dockerize and save in registry'
            ),
            string(
                name: 'DOCKER_REGISTRY',
                defaultValue: 'http://34.215.221.237:5000',
                description: 'Server waiting docker push'
            )
        ])
    ])
    
    stage('Checkout Lastest'){
        //checkout scm: [$class: 'GitSCM', userRemoteConfigs: [[url: 'https://github.com/jpeerz-hygieia/Hygieia.git']], branches: [[name: "refs/tags/${HYGIEIA_RELEASE}"]]], poll: false
        git url: 'https://github.com/jpeerz-hygieia/Hygieia.git', branch: "master"
        try {
            do_maven("clean install package")
        } catch(Exception err) {
            echo "Building hygieia container failed: $err"
            throw err
        }
    }
    
    stage('Rebuild Containers') {
        try {
            do_maven("docker:build --fail-never -Dmaven.test.skip=true -Dlicense.skip=true")
        } catch(Exception err) {
            echo "Building hygieia container failed: $err"
            throw err
        }
    }
    
    stage('Publish New Version') {
        try {
            docker.withRegistry("$DOCKER_REGISTRY"){
                api = docker.image('hygieia-api')
                api.push("${HYGIEIA_RELEASE}")
                ui = docker.image('hygieia-ui')
                ui.push("${HYGIEIA_RELEASE}")
            }
        } catch(Exception err) {
            echo "Uploading container failed: $err"
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