#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

sudo rm -f /var/lib/sqlite/filter.db
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "CREATE TABLE IF NOT EXISTS Filter (FilterID INTEGER PRIMARY KEY,Type TEXT,Keyword TEXT DEFAULT '',Description TEXT DEFAULT '',UNIQUE(Type,Keyword))"

Type="Header"
Keyword=".*(?i)Make Money"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Get paid"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Double your income"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Cash bonus"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Lottery"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Winner"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Mortgage"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Credit.*Score"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)$$"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Limited Time"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Final warning"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Act now"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Last chance"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Expires today"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Verify your account"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Security alert"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Miracle"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)No risk"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Guaranteed"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Claim your"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)You won"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Congratulations"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Weight loss"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Viagra"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Cialis"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Prescription"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Medication"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Anti-Virus"
Description="Virus alert"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)BANNED FILENAME"
Description="Virus alert"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)detected virus"
Description="Virus alert"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)AntiVirus detected"
Description="Virus alert"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)AntiVirus"
Description="Virus alert"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)HR Benefits"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Document shared with you"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Business Proposal Request"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Your storage is nearly full"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)100% guaranteed"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Limited Time Offer"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)LOAN FUNDING"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)casino"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)Top Deals"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"

Type="Header"
Keyword=".*(?i)ED Treatments"
Description="Spam detected"
sudo sqlite3 -batch -init /root/.sqliterc /var/lib/sqlite/filter.db "INSERT OR IGNORE INTO Filter (Type,Keyword,Description) VALUES ('$Type','$Keyword','$Description')"
