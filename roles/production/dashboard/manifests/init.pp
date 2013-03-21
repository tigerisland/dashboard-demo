class dashboard {
  class { 'dashboard_dev':
    repo_branch => 'class_parameter_pr',
    repo_owner  => 'fhrbek',
  }
  include 'mysql::client'
  include 'mysql::server'
}
