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
                name: 'HYGIEIA_BRANCH',
                defaultValue: 'master',
                description: 'Trigger CI with different branch.'
            ),
            string(
                name: 'HYGIEIA_RELEASE',
                defaultValue: 'latest',
                description: 'Release tag to dockerize and save in registry latest=master'
            ),
            string(
                name: 'DOCKER_REGISTRY',
                defaultValue: '34.215.221.237:5000',
                description: 'Server waiting docker push'
            )
        ])
    ])
    
    stage('Checkout Lastest'){
        git url: 'https://github.com/jpeerz-hygieia/Hygieia.git', branch: params.HYGIEIA_BRANCH
        try {
            do_maven("clean install package -Dmaven.test.skip=true -Dlicense.skip=true")
        } catch(Exception err) {
            echo "Building hygieia container failed: $err"
            throw err
        }
    }
    
    stage('Run Tests'){
        try {
            do_maven("test")
            junit '**/target/surefire-reports/*.xml'
        } catch(Exception err) {
            echo "Some tests failed: $err"
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
            docker.withRegistry("http://$DOCKER_REGISTRY"){
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
