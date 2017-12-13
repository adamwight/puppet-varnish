# == Class: varnish::params
#

class varnish::params {

  # set Varnish conf location based on OS
  $conf_file_path = $::operatingsystem ? {
    /(?i:Centos|RedHat|OracleLinux)/  => '/etc/sysconfig/varnish',
    /(?i:FreeBSD)/                    => '/etc/rc.conf.d/varnishd',
    default                           => '/etc/default/varnish',
  }

  $service_name = $::operatingsystem ? {
    /(?i:FreeBSD)/  => 'varnishd',
    default         => 'varnish',
  }

  $package_name = $::operatingsystem ? {
    /(?i:FreeBSD)/  => 'varnish4',
    default         => 'varnish',
  }

  # FIXME: bare FBSD overrides
  $default_version = '4.1'
  # TODO: $group = 'wheel'
  $systemd = false
  $systemd_conf_path = undef
  $systemd_ncsa_conf_path = undef
}
