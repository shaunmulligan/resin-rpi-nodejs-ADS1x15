set -o errexit
set -o pipefail

apt-get -q update
#apt-get -y install nano vim.tiny
apt-get install -y nano