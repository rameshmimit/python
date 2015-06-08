# Class: python
#
# This module manages python
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
# include python
# or
# class { python:
#   install_dir => '/opt/',
#   version     => '2.7.6',
# }
#
class python (
  $install_dir       = $python::params::install_dir,
  $source_url        = $python::params::source_url,
  $version           = $python::params::version,
  $package_base_name = $python::params::package_base_name,
  $path              = $python::params::path,

) inherits python::params {
  ##Download Python
  exec { 'download_python':
    cwd     => $install_dir,
    path    => $path,
    unless  => "test [ ! '/usr/local/bin/python' -eq $version ]",
    command => "wget $source_url/$version/$package_base_name-$version.tar.xz -O $package_base_name-$version.tar.xz",
    creates => "$install_dir/$package_base_name-$version.tar.xz",
    require => File[$install_dir],
    }

  exec { 'extract_python':
    cwd     => "$install_dir",
    unless  => "test [ ! '/usr/local/bin/python' -eq $version ]",
    path    =>  $path,
    command => 'tar xf $package_base_name-$version.tar.xz',
    creates => "$install_dir/$package_base_name-$version.tar.xz/setup.py",
    require => Exec['download_python'],
    }

  exec { 'configure_python':
    cwd     => "$install_dir/$package_base_name-$version",
    unless  => "test [ ! '/usr/local/bin/python' -eq $version ]",
    path    => "$install_dir/$package_base_name-$version:/bin:/usr/bin",
    command => './configure --prefix=/usr/local --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"',
    creates => "$install_dir/$package_base_name-$version/pyconfig.h",
    require => Exec['extract_python'],
  }

  exec { 'make_python':
    cwd     => "$install_dir/$package_base_name-$version",
    path    =>  $path,
    unless  => "test [ ! '/usr/local/bin/python' -eq $version ]",
    command => 'make',
    timeout => '600',
    creates => "$install_dir/$package_base_name-$version/python",
    require => Exec['configure_python'],
    }

  exec { 'install_python':
    cwd => "$install_dir/$package_base_name-$version",
    path => $path,
    onlyif => "test [ ! '/usr/local/bin/python' -eq $version ]",
    command => 'make install',
    timeout => 600,
    require => Exec['make_python'],
  }

  exec { 'symlink_python':
    path    =>  $path,
    unless  => "test [ ! '/usr/local/bin/python' -eq $version ]",
    command => 'ln -s /usr/local/bin/python2.7 /usr/bin/python27',
    creates => '/usr/bin/python27',
    require => Exec['install_python'],
  }

  exec {'install_pip':
    cwd     => $install_dir,
    path    =>  $path,
    unless  => "test [ ! '/usr/local/bin/python' -eq $version ]",
    command => 'wget https://bootstrap.pypa.io/get-pip.py && python27 get-pip.py',
    creates => '/usr/local/bin/pip',
    require =>  Exec['symlink_python'],
  }

  exec { 'symlink_pip':
    path    =>  $path,
    onlyif  => "test [ '/usr/local/bin/python' -eq $version ]",
    unless  => '/bin/ls /usr/bin/python-pip | /bin/grep ""',
    command => 'ln -s /usr/local/bin/pip /usr/bin/python27-pip',
    creates => '/usr/bin/python27-pip',
    require =>  Exec['install_pip'],
  }
}


