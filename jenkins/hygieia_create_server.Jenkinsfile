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
                name: 'EC2_INSTANCE_NAME',
                defaultValue: 'docker-web-15',
                description: 'AWS ec2 instance name'
            )
        ])
    ])
    
    def ec2_instance_id = 'i-x'
    
    stage('Setting up AWS CLI') {
        echo 'done.'
    }
    stage('Creating new EC2') {
        try {
            echo "About to create new EC2 instance [ $EC2_INSTANCE_NAME ]"
            aws "cloudformation create-stack  --stack-name $EC2_INSTANCE_NAME --template-body file://$WORKSPACE/aws/hygieia_web.cf.json --parameters file://$WORKSPACE/aws/hygieia_parameters.cf.json"
        } catch(Exception err) {
            echo "Not able to execute aws commands."
            throw err
        }
    }
    stage('Get server AWS instance ID and IP'){
        sh "sleep 15"
        ec2_instance_id = aws("cloudformation describe-stack-resources --output text --stack-name $EC2_INSTANCE_NAME | grep 'AWS::EC2::Instance' | awk '{print \$3}'")
        echo "AWS::EC2::Instance: $ec2_instance_id"
        ec2_instance_ip = aws("ec2 describe-instances --query 'Reservations[*].Instances[*].PublicIpAddress'  --output text --instance-ids $ec2_instance_id")
        echo "Ready to ssh: $ec2_instance_ip"
    }
}

def aws(cmd){
    return sh(returnStdout: true, script: ". ~/aws_env_py/bin/activate && aws $cmd")
}

