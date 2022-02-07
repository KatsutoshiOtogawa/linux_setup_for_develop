vagrant up --provider virtualbox
vagrant snapshot save init
vagrant ssh -c "
  cd /vagrant_data
  provision.sh
"

# vagrant ssh -c "
#   sudo subscription-manager remove --all
# "
