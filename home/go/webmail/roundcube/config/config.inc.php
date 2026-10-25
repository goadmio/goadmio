<?php
$config = [];
$config['db_dsnw'] = 'mysql://roundcube:Fszm55vOH7x0iPKM@localhost/roundcube';
$config['default_host'] = 'localhost';
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';
$config['smtp_server'] = 'localhost';
$config['smtp_port'] = 587;
$config['support_url'] = '';
$config['product_name'] = 'Roundcube Webmail';
$config['des_key'] = 'rcmail-!24ByteDESkey*Str';
$config['plugins'] = ['archive','zipdownload',];
$config['skin'] = 'elastic';
$config['drafts_mbox'] = 'Drafts';
$config['junk_mbox'] = 'Junk';
$config['sent_mbox'] = 'Sent';
$config['trash_mbox'] = 'Trash';
$config['create_default_folders'] = true;
include "/usr/local/goadmio/home/go/webmail/brevo.php";
