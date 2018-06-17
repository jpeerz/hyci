node ('docker-one') {

    checkout scm: [$class: 'GitSCM', userRemoteConfigs: [[url: 'https://github.com/amazonexplorer/Hygieia.git']], branches: [[name: 'refs/tags/Hygieia-2.0.4']]], poll: false
    
    properties([
        buildDiscarder(
            logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '3', numToKeepStr: '3')
        ), 
        disableConcurrentBuilds(), 
        pipelineTriggers([])
    ])
    
    stage('Prepare Environment'){
        sh "rm -rf .py_env results"
        sh "virtualenv .py_env"
        sh "mkdir results"
        sh ". .py_env/bin/activate && pip2 install -r orcid/requirements.txt"
    }

    stage('Clean OrcidiD'){
        def cleanup_orcid_record = false
        try {
            timeout(time:20,unit:'SECONDS'){
                cleanup_orcid_record = input message: 'Would you like to clean up orcid record before continue ?', 
                                                  ok: 'Clean',
                                          parameters: [booleanParam(defaultValue: false, description: '', name: 'Clean ?')]
            }
        } catch(err){
            echo err.toString()
        }
        if (cleanup_orcid_record) {
            echo "Removing activities from orcid record [$orcid_id]"
            sh ". .py_env/bin/activate && pytest -v -r fEx orcid/api_read_delete.py"
        } else {
            echo "Continuing with existing record content."
        }
    }
}
