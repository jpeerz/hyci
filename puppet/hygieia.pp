# based on https://github.com/capitalone/Hygieia/blob/gh-pages/pages/hygieia/setup.md
$admin_pwd       = 'admin'
$hygieia_owner   = 'ubuntu'
$hygieia_release = 'Hygieia-2.0.4'

    file { "/opt/mongodb_admin.js":
        ensure  => file,
        backup  => true,
        content  => "db.createUser({user: 'super', pwd: '$admin_pwd',roles: [ { role: 'userAdminAnyDatabase', db: 'admin' } ]})"
    }
    exec{"setup_mongo_admin":
        command => 'mongo < /opt/mongodb_admin.js',
        require => File['/opt/mongodb_admin.js']
    }
    file { "/opt/mongodb_dashboarddb.js":
        ensure  => file,
        backup  => true,
        content  => "use dashboarddb
db.createUser({user: 'dashboarduser',pwd: '$admin_pwd',roles: [{role: 'readWrite', db: 'dashboarddb'}]})"
    }
    exec{"setup_hygieia_admin":
        command => 'mongo < /opt/mongodb_dashboarddb.js',
        require => File['/opt/mongodb_dashboarddb.js']
    }
    








exec {"download_hygieia_code":
    command => "git clone https://github.com/capitalone/Hygieia /opt/Hygieia && git checkout $hygieia_release && chown ubuntu:ubuntu -R /opt/Hygieia",
    creates => '/opt/Hygieia'
}
file {"/opt/Hygieia":
    ensure => directory,
    owner   => "$hygieia_owner",
    group   => "$hygieia_owner"
}
exec {"mvn_hygieia_firstrun":
    
    command => "cd /opt/Hygieia && mvn -Dmaven.test.skip=true -Dlicense.skip=true clean install package",
    creates => '/opt/Hygieia'
}


