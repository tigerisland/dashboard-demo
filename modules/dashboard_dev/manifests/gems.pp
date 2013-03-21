class dashboard_dev::gems {
	package { 'gem-rack':
		name     => 'rack',
		ensure   => '1.1.6',
		provider => 'gem',
	}

# This conflicts with Package['mysql-client'] in RPM based OSs since the mysql package is also called 'mysql'. However, since it's installed with a different provider, this looks like a puppet bug.
#	package { 'gem-mysql':
#		name     => 'mysql',
#		ensure   => present,
#		provider => 'gem',
#		require  => Class['mysql'],
#	}
#
# This is a workaround for the above described bug:

	exec { 'gem-mysql':
		command => 'gem install mysql',
		unless  => 'gem list mysql|grep \'^mysql \'',
	}

	Class['dashboard_dev::packages'] -> Class['dashboard_dev::gems']
}
