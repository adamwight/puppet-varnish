# == Class: varnish::service
#
# Enables/Disables Varnish service
#
# === Parameters
#
# start - 'yes' or 'no' to start varnishd at boot
#          default value: 'yes'
#
# === Examples
#
# make sure Varnish is running
# class {'varnish::service':}
#
# disable Varnish
# class {'varnish::service':
#   start => 'no',
# }

class varnish::service (
  $start                  = 'yes',
  $enable                 = true,
  $systemd                = $varnish::params::systemd,
  $systemd_conf_path      = $varnish::params::systemd_conf_path,
  $vcl_reload_script      = $varnish::params::vcl_reload_script,
) inherits varnish::params {

  # include install
  include ::varnish::install

  # set state
  $service_state = $start ? {
    'no'    => stopped,
    default => running,
  }

  # varnish service
  $reload_cmd = $::osfamily ? {
    'debian'    => '/etc/init.d/varnish reload',
    'redhat'    => '/sbin/service varnish reload',
    'FreeBSD'   => '/usr/sbin/service varnishd reload',
    default     => undef,
  }

  service {'varnishd':
    ensure  => $service_state,
    enable  => $enable,
    restart => $reload_cmd,
    require => Package[$::varnish::install::package_name],
  }

  $restart_command = $::osfamily ? {
    'debian'    => '/etc/init.d/varnish restart',
    'redhat'    => '/sbin/service varnish restart',
    'FreeBSD'   => '/usr/sbin/service varnishd restart',
    default     => undef,
  }

  exec { 'restart-varnish':
    command     => $restart_command,
    refreshonly => true,
    before      => Service['varnishd'],
    require     => Package[$::varnish::install::package_name],
  }

  if $systemd {
    include ::varnish::systemd

    file {  $systemd_conf_path :
      ensure  => file,
      content => template('varnish/varnish.service.erb'),
      notify  => Exec['Reload systemd'],
      before  => [Service['varnishd'], Exec['restart-varnish']],
      require => Package[$::varnish::install::package_name],
    }
  }
}
