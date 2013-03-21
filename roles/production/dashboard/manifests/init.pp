class dashboard {
  class { 'dashboard_dev':
    repo_branch => 'class_parameters_pr',
    repo_owner  => 'fhrbek',
  }
  include 'mysql::client'
  include 'mysql::server'
}
