#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

OS=$(</usr/local/goadmio/linux/os.db)
VERSION=$(</usr/local/goadmio/linux/version.db)

sudo mkdir -p /usr/local/goadmio/template/default
sudo mkdir -p /usr/local/goadmio/template/publish

# Generate default web page page
echo "<title>Coming Soon</title><style>.Outer {display: table;height: 100%;width: 100%;}.Middle {display: table-cell;vertical-align: middle;}.Inner {margin-left: auto;margin-right: auto; width: 80%;padding:20px;border: 1px solid #CCCCCC;-moz-border-radius: 8px;-webkit-border-radius: 8px;border-radius: 8px;text-align:center;box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-webkit-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);-moz-box-shadow: 0px 0px 10px rgba(100, 100, 100, 1);font-weight:normal;FONT-SIZE: 17px; COLOR: #000000;font-family:Helvetica Neue,Helvetica,Arial;line-height:30px}</style><div class='Outer'><div class='Middle'><div class='Inner'><svg height='100' width='100'><circle cx='50' cy='50' r='31' stroke='#679b08' stroke-width='9.5' fill='none' /><circle cx='50' cy='50' r='6' stroke='#679b08' stroke-width='1' fill='#679b08' /><line x1='50' y1='50' x2='35' y2='50' style='stroke:#679b08;stroke-width:6' /><line x1='65' y1='35' x2='50' y2='50' style='stroke:#679b08;stroke-width:6' /><path d='M59 65 L83 65 L75 87 Z' fill='#679b08' /><rect width='20' height='9' x='70' y='56' style='fill:#eee;stroke-width:0;' /></svg><br>Future home of something quite cool.<br>If you're the site owner, <a href='/go'>log in</a> to launch this site<br>If you are a visitor, check back soon.</div></div></div>" | sudo tee /usr/local/goadmio/template/default/index.html >/dev/null

# Generate account unpublished page
echo "<?php echo \$_SERVER['HTTP_HOST']; ?>" | sudo tee /usr/local/goadmio/template/publish/index.php >/dev/null

sudo /go/welcome
