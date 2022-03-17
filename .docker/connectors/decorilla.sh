#!/bin/bash
# Parameters for Logstash:
# Source: Database Server
export jdbc_connection_string="jdbc:mysql://localhost:3306/decorilla_staging?useSSL=true&user=root&password=root&sessionVariables=group_concat_max_len=99999999&sessionVariables=group_concat_max_len=99999999,sort_buffer_size=1048576";
export jdbc_user="root";
export jdbc_password="root";
export jdbc_driver_library="/home/gerardo/mysql-connector-java-8.0.28/mysql-connector-java-8.0.28.jar";
export jdbc_driver_class="com.mysql.cj.jdbc.Driver";
# Destination: Elastic Search server
export elasticsearch_hosts="localhost:9200";
export collection_index="decorilla-collection";
export vendors_index="decorilla-vendors";
export colours_index="decorilla-colours";
export artstyles_index="decorilla-artstyles";
export brands_index="decorilla-brands";
# Start the script!
echo "$(date) Disabling the Decorilla Collection..."
/var/www/html/staging/protected/yiic disabledc;
#echo "$(date) Executing daily importers..."
#/var/www/html/staging/protected/yiic dailyimporters --verbose=1;
echo "$(date) Executing daily post import..."
/var/www/html/staging/protected/yiic dailypostimport --verbose=1;
echo "$(date) Updating Elastic Search collection index settings..."
curl -X PUT "localhost:9200/decorilla-collection/_settings?pretty" -H 'Content-Type: application/json' -d' { "index" : { "refresh_interval" : "30s", "number_of_replicas" : "0", "blocks.read_only_allow_delete" : "false" } }';
echo "$(date) Creating Elastic Search collection index..."
/usr/share/logstash/bin/logstash -f /var/www/html/staging/protected/config/logstash/decorilla-collection.conf --log.level=error --path.data=/home/luke/decorilla-collection$(date +%Y%m%d_%H%M%S);
/var/www/html/staging/protected/yiic slackimportersmessage --logstashIndex=decorilla-collection;
echo "$(date) Creating Elastic Search vendors index..."
/usr/share/logstash/bin/logstash -f /var/www/html/staging/protected/config/logstash/decorilla-vendors.conf --log.level=error --path.data=/home/luke/decorilla-vendors$(date +%Y%m%d_%H%M%S);
/var/www/html/staging/protected/yiic slackimportersmessage --logstashIndex=decorilla-vendors;
echo "$(date) Creating Elastic Search colours index..."
/usr/share/logstash/bin/logstash -f /var/www/html/staging/protected/config/logstash/decorilla-colours.conf --log.level=error --path.data=/home/luke/decorilla-colours$(date +%Y%m%d_%H%M%S);
/var/www/html/staging/protected/yiic slackimportersmessage --logstashIndex=decorilla-colours;
echo "$(date) Creating Elastic Search artstyles index..."
/usr/share/logstash/bin/logstash -f /var/www/html/staging/protected/config/logstash/decorilla-artstyles.conf --log.level=error --path.data=/home/luke/decorilla-artstyles$(date +%Y%m%d_%H%M%S);
/var/www/html/staging/protected/yiic slackimportersmessage --logstashIndex=decorilla-artstyles;
echo "$(date) Creating Elastic Search brands index..."
/usr/share/logstash/bin/logstash -f /var/www/html/staging/protected/config/logstash/decorilla-brands.conf --log.level=error --path.data=/home/luke/decorilla-brands$(date +%Y%m%d_%H%M%S);
/var/www/html/staging/protected/yiic slackimportersmessage --logstashIndex=decorilla-brands;
echo "$(date) Enabling the Decorilla Collection..."
/var/www/html/staging/protected/yiic enabledc;
rm -rf /home/luke/*decorilla*;
