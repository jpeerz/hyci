node ("deploy"){
   
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
    
    stage('Fetch New Containers') {
        try {
            docker.withRegistry("$DOCKER_REGISTRY"){
                api = docker.image("hygieia-api:${HYGIEIA_RELEASE}")
                api.pull()
                ui = docker.image("hygieia-ui:${HYGIEIA_RELEASE}")
                ui.pull()
            }
        } catch(Exception err) {
            echo "Building hygieia container failed: $err"
            throw err
        }
    }
    
    stage('Run Hygieia') {
        try {
            docker.withRegistry("$DOCKER_REGISTRY"){
                mongo_con = docker.image('mongo:latest').run("--name mongodb --rm -d -p 27017:27017 -v hygieia_data:/data/db")
                api_con = docker.image('hygieia-api:latest').run("--name api --rm -d -p 8080:8080 --link mongodb:mongo -e SPRING_DATA_MONGODB_DATABASE=dashboarddb -e SPRING_DATA_MONGODB_HOST=127.0.0.1 -e SPRING_DATA_MONGODB_USERNAME=dashboarduser -e SPRING_DATA_MONGODB_PASSWORD=admin -v hygieia_logs:/hygieia/logs")
                ui_con = docker.image('hygieia-ui:latest').run("--name ui --rm -d -p 8888:80 --link api")               
            }
        } catch(Exception err) {
            echo "Building hygieia container failed: $err"
            throw err
        }
    }
}
