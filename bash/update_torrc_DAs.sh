UTIL_SERVER=$1

# sshpass -p "wordpass" scp -oStrictHostKeyChecking=no tor@${UTIL_SERVER}:~/DAs

scp -i "/home/admin/tor-key" -o StrictHostKeyChecking=no admin@${UTIL_SERVER}:/home/tor/DAs .

FLAG=0
while read p; do
  	
	cat /etc/tor/torrc | grep "${p}"
	if [ $? != 0 ]; then
		echo "Adding line $p"
		echo $p >> /etc/tor/torrc
		$FLAG=1
	fi
done <./DAs

if [ "$FLAG" -eq 1 ]; then
	service tor restart
fi
