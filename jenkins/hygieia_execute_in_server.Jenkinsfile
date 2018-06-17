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
            ),
            string(
                name: 'INSTANCE_IP',
                defaultValue: '127.0.0.1',
                description: 'AWS ec2 instance IP'
            ),
            string(
                name: 'REMOTE_COMMAND',
                defaultValue: 'sh /home/ubuntu/hyci/jenkins/hygieia_setup_and_run.sh /home/ubuntu/hygieia Hygieia-2.0.4',
                description: 'remote command'
            )
        ])
    ])
    
    stage('Connect and Run') {
        //echo remotebash("ip addr")
        sh "ssh -i ~/.ssh/${SSH_KEY_NAME}.pem -o StrictHostKeyChecking=no ubuntu@${INSTANCE_IP} '$REMOTE_COMMAND'"
    }
}

def remotebash(cmd) {
    return sh(script: '/bin/bash', cmd: "ssh -i ~/.ssh/${SSH_KEY_NAME}.pem -o StrictHostKeyChecking=no ubuntu@${INSTANCE_IP} '$cmd'", returnStdout: true)
}
