#! /bin/bash
VAR=$1

case $VAR in
       	"iot_frmwrk")
	       	Wants="Wants=mosquitto.service avahi-daemon.service"
		After="After=mosquitto.service avahi-daemon.service network.target"
		RestartSec="RestartSec=2"
		#ExecStartPre=/bin/bash -c '/bin/echo iot_frmwrk_start $(date) >> /medha_gateway/crash.txt'
		;;
      	"zwave_app")
	      	Wants="Wants=zipgateway.service iot_frmwrk.service"
	       	After="After=network.target zipgateway.service iot_frmwrk.service"
		RestartSec="RestartSec=2"
		#ExecStartPre1="ExecStartPre=/usr/bin/sudo /usr/sbin/service zipgateway restart"
		#ExecStartPre2="ExecStartPre=/bin/sleep 10"

	       	;;
	"firmware_update_arm")
		After="After=network.target"
		RestartSec="RestartSec=2"
		;;
	"checking_firmware")
		After="After=network.target"
		RestartSec="RestartSec=120"
		;;	
       	*)
		echo -e "bash beaglebone_script.sh iot_frmwrk zwave_app"
		exit 1
		;;
esac


file1="/usr/sbin/$1.sh"
echo "#! /bin/bash
cd /medha_gateway
./$1" > $file1
cat $file1

sudo chmod +x $file1

file2="/etc/systemd/system/$1.service"
echo "[Unit]
Description=A description for your $1 service goes here
$Wants
$After

[Service]
Type=simple
$ExecStartPre1
$ExecStartPre2
ExecStart=/bin/bash /usr/sbin/$1.sh
Restart=always
$RestartSec

[Install]
WantedBy=multi-user.target" > $file2
cat $file2

sleep 2s
sudo systemctl daemon-reload
sleep 2s
sudo systemctl enable $1.service
sleep 2s
sudo systemctl start $1.service
