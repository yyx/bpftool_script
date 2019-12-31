#!/bin/bash
workdir=$(dirname $(readlink -f $0))
init_centos()
{
        kernel=$(uname -r)
        release=$(echo $kernel|awk -F"el" '{print $2}'|awk -F"." '{print $1}')

        mkdir -p /tmp/kernel-devel  && cd /tmp/kernel-devel

        for i in $(seq 0 10);do
                version=$release.$i
                wget ftp.scientificlinux.org/linux/scientific/$version/x86_64/updates/security/kernel-devel-$kernel.rpm
                if  [ $? -eq "0" ];then
                        echo "get package"
                        break
                fi
                wget ftp.scientificlinux.org/linux/scientific/$version/x86_64/updates/fastbugs/kernel-devel-$kernel.rpm
                if  [ $? -eq "0" ];then
                        echo "get package"
                        break
                fi
        done

        apt install rpm2cpio cpio -y
        rpm2cpio kernel-devel-$(uname -r).rpm |cpio -div
        mkdir -p /lib/modules/$(uname -r) 
        ln -s /tmp/kernel-devel/usr/src/kernels/$(uname -r)/ /lib/modules/$(uname -r)/build
        cd $workdir
}

init_ubuntu()
{
        kernel=$(uname -r)
        all=$(echo $kernel|awk -F"-generic" '{print $1}')
        wget http://security.ubuntu.com/ubuntu/pool/main/l/linux/
        deb1=$(grep linux-headers-$all index.html |grep all|awk '{print $6}'|awk -F"\"" '{print $2}')
        deb2=$(grep linux-headers-$kernel index.html |grep amd64|awk '{print $6}'|awk -F"\"" '{print $2}')
        wget http://security.ubuntu.com/ubuntu/pool/main/l/linux/$deb1
        wget http://security.ubuntu.com/ubuntu/pool/main/l/linux/$deb2
        dpkg --force-all  -i $deb1
        dpkg --force-all  -i $deb2
        rm -rf index.html*
        rm -rf linux-headers*
}

init_centos
init_ubuntu
