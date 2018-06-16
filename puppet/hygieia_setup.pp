Exec {
    path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}
# based on https://github.com/capitalone/Hygieia/blob/gh-pages/pages/hygieia/setup.md
$admin_pwd       = 'admin'
$hygieia_owner   = 'ubuntu'
$hygieia_home    = '/home/ubuntu/workspace/HygieiaBuild'
file { "$hygieia_home/dashboard.properties":
    ensure  => file,
    backup  => true,
    content => "
dbname=dashboarddb
dbusername=dashboarduser
dbpassword=$admin_pwd
dbhost=localhost
dbport=27017
dbreplicaset=false
dbhostport=localhost:27017
server.contextPath=/api
server.port=8080"
}
file { "$hygieia_home/mongodb_admin.js":
    ensure  => file,
    backup  => true,
    content => "db.createUser({user: 'super', pwd: '$admin_pwd',roles: [ { role: 'userAdminAnyDatabase', db: 'admin' } ]})"
}
exec{"setup_mongo_admin":
    command => "mongo < $hygieia_home/mongodb_admin.js",
    require => File["$hygieia_home/mongodb_admin.js"]
}
file { "$hygieia_home/mongodb_dashboarddb.js":
    ensure  => file,
    backup  => true,
    content => "use dashboarddb;db.createUser({user: 'dashboarduser',pwd: '$admin_pwd',roles: [{role: 'readWrite', db: 'dashboarddb'}]})"
}
exec{"setup_hygieia_admin":
    command => "mongo < $hygieia_home/mongodb_dashboarddb.js",
    require => File["$hygieia_home/mongodb_dashboarddb.js"]
}
