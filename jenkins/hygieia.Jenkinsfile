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
                name: 'HYGIEIA_BRANCH',
                defaultValue: 'master',
                description: 'Trigger CI with different branch.'
            ),
            string(
                name: 'HYGIEIA_RELEASE',
                defaultValue: 'latest',
                description: 'Release tag to dockerize and save in registry'
            )
        ])
    ])
    
    git url: 'https://github.com/jpeerz-hygieia/Hygieia.git', branch: params.HYGIEIA_BRANCH
    
    stage('Fetch Code and Build') {
        try {
            build([
                job: 'hygieia-build', 
                parameters: [
                    string(name: 'HYGIEIA_BRANCH', value: params.HYGIEIA_BRANCH),
                    string(name: 'HYGIEIA_RELEASE', value: params.HYGIEIA_RELEASE)
                ], 
                wait: true
            ])
        } catch(Exception err) {
            echo "Deployment Failed: $err"
            throw err
        }
    }
    stage('Containerize in Server') {
        try {
            build([
                job: 'hygieia-deploy', 
                parameters: [
                    string(name: 'HYGIEIA_RELEASE', value: params.HYGIEIA_RELEASE)
                ], 
                wait: true
            ])
        } catch(Exception err) {
            echo "Deployment Failed: $err"
            throw err
        }
    }
}
