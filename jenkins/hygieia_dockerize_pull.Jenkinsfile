node ("docker-web"){
   
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
    
    stage('Do in Container') {
        try {
            docker.withRegistry("$DOCKER_REGISTRY"){
                api = docker.image('hygieia-api')
                api.pull()
                ui = docker.image('hygieia-ui')
                ui.pull()
            }
        } catch(Exception err) {
            echo "Building hygieia container failed: $err"
            throw err
        }
    }
}
