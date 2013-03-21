# Class: dashboard_dev
#
# This module install the puppet-dashboard from git for the review purpose.
#
# Parameters:
# [repo_owner]  - The owner of the repository or its fork; defaults to 'puppetlabs'.
# [repo_branch] - The branch to checkout; defaults to 'master'.
#
# Actions:
#
# Installs everything that's needed to set up the dashboard.
#
# Requires: see Modulefile
#
# Sample Usage:
#
# class { 'dashboard_dev':
#   repo_owner => 'joe',
#   repo_branch => 'performance_optimization',
# }
#
#
class dashboard_dev(
		$repo_owner  = 'puppetlabs',
		$repo_branch = 'master',
	) {

	$puppet_dashboard = 'puppet-dashboard'

	Exec {
		path => [ '/usr/bin', '/bin', ],
	}

        class { 'dashboard_dev::packages': }
        class { 'dashboard_dev::gems': }

        group { 'puppet-dashboard':
                name   => $puppet_dashboard,
                ensure => present,
        }

	user { 'puppet-dashboard':
		name => $puppet_dashboard,
		gid  => $puppet_dashboard,
                require => Group['puppet-dashboard'],
	}

	exec { 'git_clone':
		command => "git clone git://github.com/${repo_owner}/puppet-dashboard.git",
		cwd     => '/opt',
		unless  => "test -d /opt/${puppet_dashboard}",
	}

	exec { 'git_branch':
		command => "git checkout ${repo_branch}",
		cwd     => "/opt/${puppet_dashboard}",
		unless  => "git branch|grep '* ${repo_branch}'",
		require => Exec['git_clone'],
	}

	exec { 'chown_puppet_dashboard':
		command => "chown -R ${puppet_dashboard}:${puppet_dashboard} ${puppet_dashboard}",
		cwd     => '/opt',
		require => [ Exec['git_branch'], User['puppet-dashboard'], ],
	}

	$cmd_create_database      = 'CREATE DATABASE dashboard_production CHARACTER SET utf8'
	$cmd_create_database_user = 'CREATE USER \'dashboard\'@\'localhost\' IDENTIFIED BY \'dashboard\''
	$cmd_grant_privileges     = 'GRANT ALL PRIVILEGES ON dashboard_production.* TO \'dashboard\'@\'localhost\''

	exec { 'init_database':
		command => "mysql -e \"${cmd_create_database};${cmd_create_database_user};${cmd_grant_privileges}\"",
		unless  => 'mysql -e \'show databases\' | grep \'dashboard_production\'',
	}

	file { "/opt/${puppet_dashboard}/config/database.yml":
		ensure => present,
		source  => "puppet:///modules/${module_name}/config/database.yml",
		owner   => $puppet_dashboard,
		group   => $puppet_dashboard,
		mode    => '0644',
		require => Exec['chown_puppet_dashboard'],
	}

	exec { 'migrate_database':
		command => 'rake RAILS_ENV=production db:migrate',
		cwd     => "/opt/${puppet_dashboard}",
		require => [ Class['dashboard_dev::packages'], Class['dashboard_dev::gems'], File["/opt/${puppet_dashboard}/config/database.yml"], Exec['init_database'] ],
	}

	file { '/opt/dashboard_launcher.sh':
		ensure => present,
		source => "puppet:///modules/${module_name}/scripts/launcher.sh",
		mode   => '0755',
	}

	exec { 'launch_dashboard':
		command => '/opt/dashboard_launcher.sh',
		cwd     => "/opt/${puppet_dashboard}",
		unless  => 'netstat -an|grep \' 0 0.0.0.0:3000 \'',
		require => [ File['/opt/dashboard_launcher.sh'], Exec['migrate_database'], ],
	}
}
