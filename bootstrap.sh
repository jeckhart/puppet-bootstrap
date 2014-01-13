#!/bin/sh

get_dist_script () {
  echo $( python << EOFSCRIPT
import platform
my_os = platform.system().lower()
if my_os == 'darwin':
  print('max_os_x.sh')
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

sudo -n -v > /dev/null 2>&1
ret=$?
if [ $ret != 0 ]; then
  echo "This script must be run as root."
  echo "Usage:"
  echo "  sudo bootstrap.sh"
  exit $ret
fi

dist=`get_dist_script`

script=`mktemp`
wget --output-document=${script} --output-file=/dev/null "https://raw.github.com/jeckhart/puppet-bootstrap/master/$dist"
chmod +x $script

sudo -n $script
ret=$?
if [ $ret = 0 ]; then
  echo "bootstrap was successful"
  rm -f $script
fi
exit $ret
