#!/bin/bash

# HYGIEIA_HOME='/home/ubuntu/workspace/HygieiaBuild'
HYGIEIA_HOME="$1"

cat > ${HYGIEIA_HOME}/mongodb_admin.js <<EOT
db.createUser({
    user: "super",
    pwd: "admin",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
})
EOT
mongo < ${HYGIEIA_HOME}/mongodb_admin.js
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
## service
cd ${HYGIEIA_HOME}/api/target/ && java -jar api.jar --spring.config.location=/opt/dashboard.properties -Djasypt.encryptor.password=nj3zqxtLpDtTYpBbcrk303kvwexeYddF 2>&1 > ~/Hygieia.api.log &
cd ${HYGIEIA_HOME}/UI && gulp serve  2>&1 > ~/Hygieia.ui.log &
