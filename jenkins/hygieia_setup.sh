#!/bin/bash
HYGIEIA_HOME='/home/ubuntu/workspace/HygieiaBuild'

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
