node ("docker && registry"){
   
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
            )
        ])
    ])
    
    checkout scm: [$class: 'GitSCM', userRemoteConfigs: [[url: 'https://github.com/jpeerz/Hygieia.git']], branches: [[name: "refs/tags/${HYGIEIA_RELEASE}"]]], poll: false
    
    stage('Checkout') {
        
        try {
            do_maven("docker:build -Dmaven.test.skip=true -Dlicense.skip=true")
        } catch(Exception err) {
            echo "Building hygieia container failed."
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