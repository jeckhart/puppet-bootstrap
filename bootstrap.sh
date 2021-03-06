#!/bin/sh

get_dist_script () {
  echo $( python << EOFSCRIPT
import platform
my_os = platform.system().lower()
if my_os == 'darwin':
  print('mac_os_x.sh')
elif my_os == 'linux':
  dist,ver,_ = map(str.lower,getattr(platform,'linux_distribution',getattr(platform,'dist',lambda:('','','')))())
  if dist == 'ubuntu' or dist == 'linuxmint' or dist == '"elementary os"':
    print('ubuntu.sh')
  elif dist == 'debian':
    print('debian.sh')
  elif dist == 'centos':
    print('centos_%s_x.sh' % (ver[0]))
  elif dist == 'arch':
    print('arch.sh')
  else:
    print('UNSUPPORTED_LINUX_' + dist)
elif my_os == 'windows':
  print('windows.ps1')
else:
  print('UNSUPPORTED_PLATFORM_' + my_os)
EOFSCRIPT
)
}


if [ "x`id -u`" != "x0" ]; then
  echo "This script must be run as root."
  echo "Usage:"
  echo "  sudo bootstrap.sh"
  exit 1
fi

dist=`get_dist_script`

script=`mktemp -t tmp.XXXXXXXXXX`
if ( which curl > /dev/null ); then
  curl -L --output "${script}" "https://raw.github.com/jeckhart/puppet-bootstrap/master/$dist"
else
  wget --output-document="${script}" --output-file=/dev/null "https://raw.github.com/jeckhart/puppet-bootstrap/master/$dist"
fi
chmod +x "$script"

$script
ret=$?
if [ $ret = 0 ]; then
  echo "bootstrap was successful"
  rm -f $script
fi
exit $ret
