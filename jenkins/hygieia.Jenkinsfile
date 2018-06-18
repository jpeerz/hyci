node {

    properties([
        buildDiscarder(
            logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '10', numToKeepStr: '20')
        ), 
        disableConcurrentBuilds(), 
        pipelineTriggers([
            [$class: "GitHubPushTrigger"]
        ]),
        parameters([
            string(
                name: 'HYGIEIA_RELEASE',
                defaultValue: 'Hygieia-2.0.4',
                description: 'Release tag to dockerize and save in registry'
            )
        ])
    ])
    
    git url: 'https://github.com/jpeerz-hygieia/Hygieia.git', branch: "master"
    
    stage('Fetch Code and Build') {
        try {
            build([
                job: 'hygieia-build', 
                parameters: [
                    string(name: 'HYGIEIA_RELEASE', value: "$HYGIEIA_RELEASE")
                ], 
                wait: true
            ])
        } catch(Exception err) {
            echo "Deployment Failed: $err"
            throw err
        }
    }
    stage('Fetch Code and Build') {
        try {
            build([
                job: 'hygieia-deploy', 
                parameters: [
                    string(name: 'HYGIEIA_RELEASE', value: "$HYGIEIA_RELEASE")
                ], 
                wait: true
            ])
        } catch(Exception err) {
            echo "Deployment Failed: $err"
            throw err
        }
    }
}