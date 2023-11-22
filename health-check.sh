# In the original repository we'll just print the result of status checks,
# without committing. This avoids generating several commits that would make
# later upstream merges messy for anyone who forked us.
commit=false
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
mkdir -p logs
for (( index=0; index < ${#KEYSARRAY[@]}; index++))
do
    key="${KEYSARRAY[index]}"
    url="${URLSARRAY[index]}"
    echo " $key=$url"
    for i in 1 2 3 4;
    do
        responseDetails=$(curl --write-out "HTTPCode:%{http_code}" --silent --output /dev/null $url)
        response=$(echo $responseDetails | grep -oP '(?<=HTTPCode:)\d+')
        if [ "$response" -eq 200 ] || [ "$response" -eq 202 ] || [ "$response" -eq 301 ] || [ "$response" -eq 302 ] || [ "$response" -eq 307 ]; then
            result="success"
        else
            result="failed"
            # If failed, append the response details to the result
            result="$result ; $responseDetails"
        fi
        if [ "$result" = "success" ]; then
            break
        fi
        sleep 5
    done

    dateTime=$(date +'%Y-%m-%d %H:%M')
    if [[ $commit == true ]]
    then
        # Echo the result and error details to the log in the same line
        echo "$dateTime, $result" >> "logs/${key}_report.log"
        # By default we keep 2000 last log entries. Feel free to modify this to meet your needs.
        echo "$(tail -2000 logs/${key}_report.log)" > "logs/${key}_report.log"
    else
        echo "$dateTime, $result"
    fi
done
# ---------
if [[ $commit == true ]]
then
  git config --global user.name 'duc nguyen'
  git config --global user.email 'duc.nguyen@spiraledge.com'
  git add -A --force logs/
  git commit -am '[Automated] Update Health Check Logs'
  git push
fi
