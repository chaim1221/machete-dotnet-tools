brew update

if [[ $? -ne 0 ]] ; then
  echo you must install brew
  exit 1
fi

pwsh --version

if [[ $? -ne 0 ]] ; then
  brew cask install powershell
else 
  brew update
  brew cask upgrade powershell
fi
