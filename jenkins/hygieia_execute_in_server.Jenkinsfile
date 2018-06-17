node {

    git url: 'https://github.com/jpeerz/hyci.git', branch: "master"
    
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
                name: 'SSH_KEY_NAME',
                defaultValue: 'webadmin',
                description: 'AWS ec2 instance key pair'
            )
        ])
    ])
    
    stage('Connect and Run') {
        
    }
}

