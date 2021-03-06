class memcached(
  $package_ensure  = 'present',
  $logfile         = '/var/log/memcached.log',
  $max_memory      = false,
  $item_size       = false,
  $lock_memory     = false,
  $listen_ip       = '0.0.0.0',
  $tcp_port        = 11211,
  $udp_port        = 11211,
  $user            = $::memcached::params::user,
  $max_connections = '8192',
  $verbosity       = undef,
  $unix_socket     = undef,
  $install_dev     = false,
  $processorcount  = $::processorcount
) inherits memcached::params {

  if $package_ensure == 'absent' {
    $service_ensure = 'stopped'
  } else {
    $service_ensure = 'running'
  }

  package { $memcached::params::package_name:
    ensure => $package_ensure,
  }

  if $install_dev {
    package { $memcached::params::dev_package_name:
      ensure  => $package_ensure,
      require => Package[$memcached::params::package_name]
    }
  }


  # if $unix_socket {
  #   $socket_path = dirname("$unix_socket")
  #   exec { "exec mkdir -p ${socket_path}":
  #     command => "mkdir -p ${socket_path}",
  #     onlyif  => "test ! -d ${socket_path}",
  #   }
  #   file {"$unix_socket":
  #     ensure  => present,
  #     owner   => $user,
  #     mode    => 0755,
  #     require => Exec["exec mkdir -p ${socket_path}"]
  #   }
  # }

  file { $memcached::params::config_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($memcached::params::config_tmpl),
    require => Package[$memcached::params::package_name],
  }

  service { $memcached::params::service_name:
    ensure     => $service_ensure,
    enable     => true,
    hasrestart => true,
    hasstatus  => $memcached::params::service_hasstatus,
    subscribe  => File[$memcached::params::config_file],
  }
}
