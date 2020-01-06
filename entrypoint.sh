#!/bin/bash
/usr/sbin/grafana-server --homepath=/usr/share/grafana --config=/etc/grafana/grafana.ini > /dev/null 2>&1 & 
influxd run > /dev/null 2>&1 & 
bash
