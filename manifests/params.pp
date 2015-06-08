class python::params (
  $install_dir       = '/opt/python27',
  $source_url        = 'http://python.org/ftp/python',
  $version           = '2.7.6',
  $package_base_name = 'Python',
  $path              = '/bin:/sbin:/usr/bin:/usr/sbin/:/usr/local/bin:/usr/loca/sbin',
  ){
  $packages = [ 'zlib-devel', 'bzip2-devel', 'openssl-devel', 'ncurses-devel', 'sqlite-devel', 'readline-devel', 'tk-devel', 'gdbm-devel', 'libpcap-devel', 'xz-devel', 'make', 'gcc']

  file { $install_dir :
    ensure => directory,
  }
  package { $packages:
    ensure => installed,
    before => File["$install_dir"],
  }
}