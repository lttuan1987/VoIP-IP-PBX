# cp ./freeswitch/conf/vanilla/autoload_configs/acl.conf.xml /usr/local/freeswitch/conf/autoload_configs/acl.conf.xml
cp ./freeswitch/conf/vanilla/autoload_configs/modules.conf.xml /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml
# cp ./freeswitch/conf/vanilla/autoload_configs/apn.conf.xml /usr/local/freeswitch/conf/autoload_configs/apn.conf.xml
# cp ./freeswitch/conf/vanilla/autoload_configs/logfile.conf.xml /usr/local/freeswitch/conf/autoload_configs/logfile.conf.xml
cp ./freeswitch/conf/vanilla/autoload_configs/xml_curl.conf.xml /usr/local/freeswitch/conf/autoload_configs/xml_curl.conf.xml
cp ./freeswitch/conf/vanilla/autoload_configs/switch.conf.xml /usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
cp -r ./freeswitch/conf/vanilla/directory/* /usr/local/freeswitch/conf/directory
cp -r ./freeswitch/conf/vanilla/dialplan/* /usr/local/freeswitch/conf/dialplan
cp -r ./freeswitch/conf/vanilla/sip_profiles/* /usr/local/freeswitch/conf/sip_profiles
cp ./freeswitch/conf/vanilla/vars.xml /usr/local/freeswitch/conf/vars.xml
cp ./freeswitch/scripts/exp_channel_uuid.lua /usr/local/freeswitch/scripts/exp_channel_uuid.lua
cp ./freeswitch/scripts/push_apn.lua /usr/local/freeswitch/scripts/push_apn.lua
# cp ./freeswitch/tls/tls.pem /usr/local/freeswitch/tls/tls.pem

fs_cli -x "reloadxml"
fs_cli -x "reload mod_sofia"
fs_cli -x "reload mod_xml_curl"

echo "✅ Waiting ..."
sleep 10

fs_cli -x "sofia profile internal restart"
fs_cli -x "sofia profile external restart"
fs_cli -x "sofia status"

# sleep 5

# systemctl restart freeswitch
# systemctl status freeswitch