class dashboard_dev::packages {
	package { 'rubygem-rake':
		ensure => present,
	}

	package { 'ruby-devel':
		ensure => present,
	}

	package { 'mysql-devel':
		ensure => present,
	}

	package { 'gcc':
		ensure => present,
	}

	package { 'make':
		ensure => present,
	}
}
