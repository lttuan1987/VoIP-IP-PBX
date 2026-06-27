#cp fail2ban/jail.d/* /etc/fail2ban/jail.d/
#cp fail2ban/filter.d/* /etc/fail2ban/filter.d/
sudo apt update
sudo apt install fail2ban -y

cp fail2ban/jail.d/freeswitch-register.local /etc/fail2ban/jail.d/
cp fail2ban/filter.d/freeswitch-register.conf /etc/fail2ban/filter.d/
systemctl restart fail2ban
systemctl status fail2ban

sleep 3
fail2ban-client status