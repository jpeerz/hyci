#!/bin/bash
if [ $# -lt 2 ];then
    echo "Usage:\n\t$0 bash ./hygieia_setup_and_run.sh /home/ubuntu/workspace/HygieiaBuild Hygieia-2.0.4\n"
    exit 0
fi
HYGIEIA_HOME="$1"
HYGIEIA_RELEASE="$2"
if [ ! -d "${HYGIEIA_HOME}" ];then
    echo "Hygieia code not found in workspace"
    exit 1
fi
cat > ${HYGIEIA_HOME}/mongodb_admin.js <<EOT
db.createUser({
    user: "super",
    pwd: "admin",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
})
EOT
mongo admin < ${HYGIEIA_HOME}/mongodb_admin.js
cat > ${HYGIEIA_HOME}/mongodb_dashboarddb.js <<EOT
use dashboarddb
db.createUser(
    {
        user: "dashboarduser",
        pwd: "admin",
        roles: [
        {
            role: "readWrite", db: "dashboarddb"}
        ]
    })
db.logs.insert({state: "user_setup_done"});   
EOT
mongo < ${HYGIEIA_HOME}/mongodb_dashboarddb.js
cat > ${HYGIEIA_HOME}/dashboard.properties <<EOT
dbname=dashboarddb
dbusername=dashboarduser
dbpassword=admin
dbhost=localhost
dbport=27017
dbreplicaset=false
dbhostport=localhost:27017
server.contextPath=/api
server.port=8080
EOT
## build and start service
cd ${HYGIEIA_HOME}/
git checkout $HYGIEIA_RELEASE
cd ${HYGIEIA_HOME}/UI
npm install && bower install
cd ${HYGIEIA_HOME}/ && mvn -Dmaven.test.skip=true -Dlicense.skip=true clean install package
cd ${HYGIEIA_HOME}/api/target/ && java -jar api.jar --spring.config.location=/opt/dashboard.properties -Djasypt.encryptor.password=nj3zqxtLpDtTYpBbcrk303kvwexeYddF 2>&1 > ~/Hygieia.api.log &
cd ${HYGIEIA_HOME}/UI && gulp serve  2>&1 > ~/Hygieia.ui.log &
