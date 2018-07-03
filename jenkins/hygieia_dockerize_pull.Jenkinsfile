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
                defaultValue: 'latest',
                description: 'Release tag to dockerize and save in registry'
            ),
            string(
                name: 'DOCKER_REGISTRY',
                defaultValue: '34.215.221.237:5000',
                description: 'Server waiting docker push'
            ),
            string(
                name: 'DOCKER_WEB_IP',
                defaultValue: '172.31.31.222',
                description: 'Client Server waiting docker pull'
            )
        ])
    ])
    
    stage('Fetch New Containers') {
        try {
            docker.withRegistry("http://${DOCKER_REGISTRY}"){
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
    
    stage('Clean Previous Release') {
        try {
            build([
                job: 'hygieia-execute-in-server', 
                parameters: [
                    string(name: 'INSTANCE_IP', value: params.DOCKER_WEB_IP),
                    string(name: 'REMOTE_COMMAND', value: 'docker stop mongodb api ui')
                ], 
                wait: true
            ])
        } catch(Exception err) {
            echo "Unable to stop previous containers: $err"
        }
    }
    
    stage('Startup Database') {
        try {
            /*docker.withRegistry("http://${DOCKER_REGISTRY}"){
                mongo_con = docker.image("mongo:latest").run("--name mongodb --rm -p 27017:27017 -v hygieia_data:/data/db")
            }*/
            sh "docker run -d --name mongodb --rm -p 27017:27017 -v hygieia_data:/data/db mongo:latest"
        } catch(Exception err) {
            echo "Deploying database container failed: $err"
            throw err
        }
    }
    
    stage('Run Hygieia') {
        try {
            /*docker.withRegistry("http://${DOCKER_REGISTRY}"){
                api_con   = docker.image("${DOCKER_REGISTRY}/hygieia-api:${HYGIEIA_RELEASE}").run("--name api --rm -p 8080:8080 --link mongodb:mongo -e SPRING_DATA_MONGODB_DATABASE=dashboarddb -e SPRING_DATA_MONGODB_HOST=127.0.0.1 -e SPRING_DATA_MONGODB_USERNAME=dashboarduser -e SPRING_DATA_MONGODB_PASSWORD=admin -v hygieia_logs:/hygieia/logs")
                ui_con    = docker.image("${DOCKER_REGISTRY}/hygieia-ui:${HYGIEIA_RELEASE}").run("--name ui --rm -p 8888:80 --link api -e HYGIEIA_API_PORT=http://api:8080")
            }*/
            sh "docker run -d --name api --rm --link mongodb:mongo -e SPRING_DATA_MONGODB_DATABASE=dashboarddb -e SPRING_DATA_MONGODB_HOST=127.0.0.1 -e SPRING_DATA_MONGODB_USERNAME=dashboarduser -e SPRING_DATA_MONGODB_PASSWORD=admin -p 8080:8080 -v hygieia_logs:/hygieia/logs -dti ${DOCKER_REGISTRY}/hygieia-api:${HYGIEIA_RELEASE}"
            sh 'sleep 10'
            sh "docker run -d --name ui --rm -p 8888:80 --link api -e API_PORT=8080 -e API_HOST=api ${DOCKER_REGISTRY}/hygieia-ui:${HYGIEIA_RELEASE}"
        } catch(Exception err) {
            echo "Deploying hygieia container failed: $err"
            throw err
        }
    }
}
