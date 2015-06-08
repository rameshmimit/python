class python::install {
  include python::params
  package { $::python::params::$dependency_packages:
		ensure => installed,
	}
	exec { 'get_python':
		cwd     => '/tmp/',
		path    => $::python::params::path,
		onlyif  => 'python -c "exec(\'import sys\\nif sys.version_info >= (2, 7): sys.exit(0)\')"',
		command => "wget $::python::params::python_source_url/$::python::params::version/Python-$::python::params::version.tar.xz -O Python-$::python::params::version.tar.xz",
		creates => "/tmp/Python-$::python::params::version.tar.xz",
		require => Packages[$::python::params::dependency_packages],
	}

	exec { 'extract_python':
		cwd     => $python::params::install_dir,
		onlyif  => 'python -c "exec(\'import sys\\nif sys.version_info >= (2, 7): sys.exit(0)\')"',
		path    =>	$::python::params::path, 
		command => "tar xf Python-$::python::params::version.tar.xz /tmp/Python-$::python::params::version.tar.xz",
		creates => "$python::params::install_dir/Python-$::python::params::version/setup.py",
		require => Exec['get_python'],
	}

	exec { 'configure_python':
		cwd     => "/opt/Python-$::python::params::version",
		onlyif  => 'python -c "exec(\'import sys\\nif sys.version_info >= (2, 7): sys.exit(0)\')"',
		path    => "$python::params::install_dir/Python-$::python::params::version:/bin:/usr/bin",
    command => "./configure --prefix=$python::params::prefix_dir --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"",
		creates => "$::python::params::install_dir/Python-$::python::params::version/pyconfig.h",
		require => Exec['extract_python'],
	}

	exec {"make python":
		cwd => '/opt/python27/Python-2.7.6',
		path =>	"/bin:/usr/bin",
		onlyif => 'python -c "exec(\'import sys\\nif sys.version_info >= (2, 7): sys.exit(0)\')"',
		command => 'make',
		timeout => 600,
		creates => '/opt/python27/Python-2.7.6/python',
		require => Exec["configure python"],
		}

	exec {"install python":
	    cwd => '/opt/python27/Python-2.7.6',
	    path => "/bin:/usr/bin",
		onlyif => 'python -c "exec(\'import sys\\nif sys.version_info >= (2, 7): sys.exit(0)\')"',
	    command => 'make install',
		timeout => 600,
	    require => Exec["make python"],
	    }

	exec {"ln python":
		path =>	"/bin:/usr/bin",
		onlyif => 'python -c "exec(\'import sys\\nif sys.version_info >= (2, 7): sys.exit(0)\')"',
		command => 'ln -s /usr/local/bin/python2.7 /usr/bin/python27',
		creates => '/usr/bin/python27',
		require => Exec["install python"],
		}

	exec {"install pip":
		cwd => '/opt/python27',
		path =>	"/bin:/usr/bin",
		onlyif => 'python -c "exec(\'import sys\\nif sys.version_info >= (2, 7): sys.exit(0)\')"',
		command => 'wget https://bootstrap.pypa.io/get-pip.py && python27 get-pip.py',
		creates => '/usr/local/bin/pip',
		require =>  Exec["ln python"],
		}

	exec { 'ln pip':
		path =>	"/bin:/usr/bin",
		onlyif => 'python -c "exec(\'import sys\\nif sys.version_info >= (2, 7): sys.exit(0)\')"',
		unless  => '/bin/ls /usr/bin/python-pip | /bin/grep ""',
		command => 'ln -s /usr/local/bin/pip /usr/bin/python-pip',
		creates => '/usr/bin/python-pip',
		require =>  Exec["install pip"],
		}

	exec { 'ln pip2':
		path =>	"/bin:/usr/bin",
		onlyif => 'python -c "exec(\'import sys\\nif sys.version_info >= (2, 7): sys.exit(0)\')"',
		unless  => '/bin/ls /usr/bin/python-pip | /bin/grep ""',
		command => 'ln -s /usr/local/bin/pip /usr/bin/pip',
		creates => '/usr/bin/pip',
		require =>  Exec["install pip"],
		}
}