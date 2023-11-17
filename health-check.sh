# In the original repository we'll just print the result of status checks,
# without committing. This avoids generating several commits that would make
# later upstream merges messy for anyone who forked us.
commit=true
# ---------
KEYSARRAY=()
URLSARRAY=()
urlsConfig="./urls.cfg"
servicesConfig="./urls_services.cfg"

echo "Reading $urlsConfig"
while read -r line
do
    echo " $line"
    IFS='=' read -ra TOKENS <<< "$line"
    KEYSARRAY+=(${TOKENS[0]})
    URLSARRAY+=(${TOKENS[1]})
done < "$urlsConfig"

echo "Reading $servicesConfig"
while read -r line
do
    echo " $line"
    IFS='=' read -ra TOKENS <<< "$line"
    KEYSARRAY+=(${TOKENS[0]})
    URLSARRAY+=(${TOKENS[1]})
done < "$servicesConfig"

echo "***********************"
echo "Starting health checks with ${#KEYSARRAY[@]} configs:"

# ---------
if [[ $commit == true ]]
then
  git config --global user.name 'duc nguyen'
  git config --global user.email 'duc.nguyen@spiraledge.com'
  git add -A --force logs/
  git commit -am '[Automated] Update Health Check Logs'
  git push
fi
