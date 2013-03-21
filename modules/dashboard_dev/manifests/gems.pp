class dashboard_dev::gems {
	package { 'rack':
		ensure   => '1.1.6',
		provider => 'gem',
	}

	package { 'mysql':
		ensure   => present,
		provider => 'gem',
		require  => Class['mysql'],
	}

	Class['dashboard_dev::packages'] -> Class['dashboard_dev::gems']
}
