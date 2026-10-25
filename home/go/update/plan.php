<?php

SQL("DELETE FROM Plan");

// HDD
$PlanName="DE-VPS XS";
$DiskType="SATA HDD";
$DiskSpace="3000";
$Cores="1";
$Memory="1";
$Rate="100";
$Price="10";
$InStock="1";
$Location="EU (Germany)";
$Sql = "INSERT INTO Plan (PlanName,DiskType,Location,DiskSpace,Cores,Memory,Rate,Price,InStock) VALUES ('$PlanName','$DiskType','$Location','$DiskSpace','$Cores','$Memory','$Rate','$Price','$InStock')";
SQL($Sql);

$PlanName="DE-VPS S";
$DiskType="SATA HDD";
$DiskSpace="4000";
$Cores="2";
$Memory="2";
$Rate="250";
$Price="15";
$InStock="1";
$Location="EU (Germany)";
$Sql = "INSERT INTO Plan (PlanName,DiskType,Location,DiskSpace,Cores,Memory,Rate,Price,InStock) VALUES ('$PlanName','$DiskType','$Location','$DiskSpace','$Cores','$Memory','$Rate','$Price','$InStock')";
SQL($Sql);

$PlanName="DE-VPS M";
$DiskType="SATA HDD";
$DiskSpace="6000";
$Cores="3";
$Memory="4";
$Rate="500";
$Price="25";
$InStock="1";
$Location="EU (Germany)";
$Sql = "INSERT INTO Plan (PlanName,DiskType,Location,DiskSpace,Cores,Memory,Rate,Price,InStock) VALUES ('$PlanName','$DiskType','$Location','$DiskSpace','$Cores','$Memory','$Rate','$Price','$InStock')";
SQL($Sql);

$PlanName="DE-VPS X";
$DiskType="SATA HDD";
$DiskSpace="10000";
$Cores="4";
$Memory="6";
$Rate="1000";
$Price="40";
$InStock="1";
$Location="EU (Germany)";
$Sql = "INSERT INTO Plan (PlanName,DiskType,Location,DiskSpace,Cores,Memory,Rate,Price,InStock) VALUES ('$PlanName','$DiskType','$Location','$DiskSpace','$Cores','$Memory','$Rate','$Price','$InStock')";
SQL($Sql);

$PlanName="DE-VPS XL";
$DiskType="SATA HDD";
$DiskSpace="20000";
$Cores="5";
$Memory="8";
$Rate="1000";
$Price="50";
$InStock="1";
$Location="EU (Germany)";
$Sql = "INSERT INTO Plan (PlanName,DiskType,Location,DiskSpace,Cores,Memory,Rate,Price,InStock) VALUES ('$PlanName','$DiskType','$Location','$DiskSpace','$Cores','$Memory','$Rate','$Price','$InStock')";
SQL($Sql);

$PlanName="DE-VPS XXL";
$DiskType="SATA HDD";
$DiskSpace="25000";
$Cores="6";
$Memory="16";
$Rate="1000";
$Price="75";
$InStock="1";
$Location="EU (Germany)";
$Sql = "INSERT INTO Plan (PlanName,DiskType,Location,DiskSpace,Cores,Memory,Rate,Price,InStock) VALUES ('$PlanName','$DiskType','$Location','$DiskSpace','$Cores','$Memory','$Rate','$Price','$InStock')";
SQL($Sql);

// NVMe SSD
$PlanName="DE-VPS-NVM XS";
$DiskType="NVMe SSD";
$DiskSpace="50";
$Cores="1";
$Memory="1";
$Rate="100";
$Price="5.99";
$InStock="1";
$Location="EU (Germany)";
$Sql = "INSERT INTO Plan (PlanName,DiskType,Location,DiskSpace,Cores,Memory,Rate,Price,InStock) VALUES ('$PlanName','$DiskType','$Location','$DiskSpace','$Cores','$Memory','$Rate','$Price','$InStock')";
SQL($Sql);

$PlanName="DE-VPS-NVME S";
$DiskType="NVMe SSD";
$DiskSpace="100";
$Cores="2";
$Memory="2";
$Rate="250";
$Price="10.99";
$InStock="1";
$Location="EU (Germany)";
$Sql = "INSERT INTO Plan (PlanName,DiskType,Location,DiskSpace,Cores,Memory,Rate,Price,InStock) VALUES ('$PlanName','$DiskType','$Location','$DiskSpace','$Cores','$Memory','$Rate','$Price','$InStock')";
SQL($Sql);

$PlanName="DE-VPS-NVME M";
$DiskType="NVMe SSD";
$DiskSpace="250";
$Cores="4";
$Memory="4";
$Rate="500";
$Price="15.99";
$InStock="1";
$Location="EU (Germany)";
$Sql = "INSERT INTO Plan (PlanName,DiskType,Location,DiskSpace,Cores,Memory,Rate,Price,InStock) VALUES ('$PlanName','$DiskType','$Location','$DiskSpace','$Cores','$Memory','$Rate','$Price','$InStock')";
SQL($Sql);

$PlanName="DE-VPS-NVME X";
$DiskType="NVMe SSD";
$DiskSpace="500";
$Cores="6";
$Memory="8";
$Rate="1000";
$Price="24.99";
$InStock="1";
$Location="EU (Germany)";
$Sql = "INSERT INTO Plan (PlanName,DiskType,Location,DiskSpace,Cores,Memory,Rate,Price,InStock) VALUES ('$PlanName','$DiskType','$Location','$DiskSpace','$Cores','$Memory','$Rate','$Price','$InStock')";
SQL($Sql);

$PlanName="DE-VPS-NVME XL";
$DiskType="NVMe SSD";
$DiskSpace="800";
$Cores="8";
$Memory="16";
$Rate="1000";
$Price="39.99";
$InStock="1";
$Location="EU (Germany)";
$Sql = "INSERT INTO Plan (PlanName,DiskType,Location,DiskSpace,Cores,Memory,Rate,Price,InStock) VALUES ('$PlanName','$DiskType','$Location','$DiskSpace','$Cores','$Memory','$Rate','$Price','$InStock')";
SQL($Sql);

$PlanName="DE-VPS-NVME XXL";
$DiskType="NVMe SSD";
$DiskSpace="1000";
$Cores="12";
$Memory="32";
$Rate="1000";
$Price="59.99";
$InStock="1";
$Location="EU (Germany)";
$Sql = "INSERT INTO Plan (PlanName,DiskType,Location,DiskSpace,Cores,Memory,Rate,Price,InStock) VALUES ('$PlanName','$DiskType','$Location','$DiskSpace','$Cores','$Memory','$Rate','$Price','$InStock')";
SQL($Sql);

?>