<?php

SQL("DELETE FROM Distro");

$File="almalinux-9-go.tar.zst";
$OS="almalinux-9-go";
$Name="GoAdmio (AlmaLinux 9)";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="almalinux-8-cpanel.tar.zst";
$OS="almalinux-8-cpanel";
$Name="WHM/cPanel (AlmaLinux 8)";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="centos-7.tar.zst";
$OS="centos-7";
$Name="CentOS 7 [XLC]";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);


$File="vzdump-qemu-111-2023_08_22-04_32_14.vma.zst";
$OS="centos-7-kvm";
$Name="CentOS 7 [KVM]";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="centos-8.5.tar.zst";
$OS="centos-8";
$Name="CentOS 8";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="centos-stream-9.tar.zst";
$OS="centos-stream-9";
$Name="CentOS Stream 9";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="almalinux-8.tar.zst";
$OS="almalinux-8";
$Name="AlmaLinux 8 [XLC]";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="vzdump-qemu-100-2023_08_27-16_27_07.vma.zst";
$OS="almalinux-8-kvm";
$Name="AlmaLinux 8 [KVM]";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="vzdump-qemu-100-2023_12_25-00_59_07.vma.zst";
$OS="almalinux-8-kvm-gpt";
$Name="AlmaLinux 8 [KVM GPT]";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="almalinux-9.2.tar.zst";
$OS="almalinux-9";
$Name="AlmaLinux 9";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="rockylinux-8.tar.zst";
$OS="rockylinux-8";
$Name="Rocky Linux 8";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="vzdump-qemu-100-2023_08_30-08_09_55.vma.zst";
$OS="rockylinux-8-kvm";
$Name="Rocky Linux 8 [KVM]";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="rockylinux-9.tar.zst";
$OS="rockylinux-9";
$Name="Rocky Linux 9";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="fedora-37.tar.zst";
$OS="fedora-37";
$Name="Fedora 37";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="fedora-38.tar.zst";
$OS="fedora-38";
$Name="Fedora 38";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="vzdump-qemu-100-2023_08_30-03_44_02.vma.zst";
$OS="oraclelinux-8-kvm";
$Name="Oracle Linux 8 [KVM]";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="debian-10.tar.zst";
$OS="debian-10";
$Name="Debian 10";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="debian-11.tar.zst";
$OS="debian-11";
$Name="Debian 11 [LXC]";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="debian-11-xrdp.tar.zst";
$OS="debian-11-xrdp";
$Name="xRDP (Debian 11)";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="vzdump-qemu-100-2023_08_26-17_39_28.vma.zst";
$OS="debian-11-kvm";
$Name="Debian 11 [KVM]";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="debian-12.tar.zst";
$OS="debian-12";
$Name="Debian 12 [LXC]";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);


$File="vzdump-qemu-100-2023_10_03-05_38_22.vma.zst";
$OS="debian-12-kvm";
$Name="Debian 12 [KVM GPT]";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="ubuntu-18.04.tar.zst";
$OS="ubuntu-18.04";
$Name="Ubuntu 18.04";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="ubuntu-20.04.tar.zst";
$OS="ubuntu-20.04";
$Name="Ubuntu 20.04";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="ubuntu-22.04.tar.zst";
$OS="ubuntu-22.04";
$Name="Ubuntu 22.04";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="ubuntu-22.10.tar.zst";
$OS="ubuntu-22.10";
$Name="Ubuntu 22.10";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="ubuntu-23.04.tar.zst";
$OS="ubuntu-23.04";
$Name="Ubuntu 23.04";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="archlinux.tar.zst";
$OS="archlinux";
$Name="Arch Linux";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="opensuse-15.4.tar.zst";
$OS="opensuse-15.4";
$Name="openSUSE 15.4";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="vzdump-qemu-100-2023_09_28-17_33_09.vma.zst";
$OS="vicibox-11";
$Name="ViciBox 11";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="vzdump-qemu-100-2023_08_28-04_48_32.vma.zst";
$OS="nethServer-7-kvm";
$Name="NethServer 7.9 [KVM]";
$Device="SCSI";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="vzdump-qemu-100-2023_09_01-00_27_23.vma.zst";
$OS="windows-server-2016-standard";
$Name="Windows Server 2016 Standard";
$Device="IDE";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="vzdump-qemu-102-2023_10_16-10_02_27.vma.zst";
$OS="windows-server-2019-datacenter";
$Name="Windows Server 2019 Datacenter";
$Device="IDE";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="vzdump-qemu-100-2023_12_08-03_42_07.vma.zst";
$OS="windows-7";
$Name="Windows 7";
$Device="IDE";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);

$File="vzdump-qemu-100-2023_12_09-15_32_24.vma.zst";
$OS="windows-10";
$Name="Windows 10";
$Device="IDE";
$Sql = "INSERT INTO Distro (File,OS,Name,Device) VALUES ('$File','$OS','$Name','$Device')";
SQL($Sql);








?>