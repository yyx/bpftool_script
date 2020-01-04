#!/bin/bash

workdir=$(dirname $(readlink -f $0))
tmpdir="/tmp/kernel-devel-tmp"

init_centos_new()
{
	local url1="ftp.scientificlinux.org/linux/scientific/"
	local url2_1="/x86_64/updates/security/"
	local url2_2="/x86_64/updates/fastbugs/"
	local url3="kernel-devel-"
        local kernel=$(uname -r)
	local kernel_main=$(echo $kernel|awk -F"-" '{print $1}')
        local release=$(echo $kernel|awk -F"el" '{print $2}'|awk -F"." '{print $1}')
	local version=""

        mkdir -p $tmpdir  && cd $tmpdir

        for i in $(seq 0 10);do
                version=$release.$i
                wget ${url1}${version}${url2_1}${url3}${kernel}.rpm -o ${kernel}.rpm
                if  [ $? -eq "0" ];then
                        echo "get package"
			find=1
                        break
                fi

                wget ${url1}${version}${url2_2}${url3}${kernel}.rpm -o ${kernel}.rpm
                if  [ $? -eq "0" ];then
                        echo "get package"
			find=1
                        break
                fi
        done

	if [ ! -z "$find" ]; then
		echo "get index"
		wget ${url1}${version}${url2_1} -O centos.index
	fi

	new_head_rpm=$(grep $kernel_main centos.index |grep kernel-header|awk '{print $6}' |awk -F"\"" '{print $2}'|tail -n2|head -n1)
	new_devel_rpm=$(echo $new_head_rpm|sed 's/kernel-headers/kernel-devel/g')
	new_version=$(echo $new_head_rpm|sed 's/kernel-headers-//g'|sed 's/.rpm//g')
	if [ -n "$new_head_rpm" -a -n "$new_devel_rpm" -a -n "$new_version" ]; then
		echo $new_head_rpm $new_devel_rpm $new_version
		wget ${url1}${version}${url2_1}${new_head_rpm}
		wget ${url1}${version}${url2_1}${new_devel_rpm}
        	apt install rpm2cpio cpio -y
		cd /
        	rpm2cpio $tmpdir/$new_head_rpm |cpio -div
        	rpm2cpio $tmpdir/$new_devel_rpm |cpio -div
		mkdir -p /lib/modules/$(uname -r)/
		ln -s /usr/src/kernels/$new_version/ /lib/modules/$(uname -r)/build
        	rm -rf $tmpdir
        	cd $workdir
		return 0
	fi
        cd $workdir
        rm -rf $tmpdir
	return 1
}


init_ubuntu()
{
        kernel=$(uname -r)
        all=$(echo $kernel|awk -F"-generic" '{print $1}')

        mkdir -p $tmpdir  && cd $tmpdir

        wget http://security.ubuntu.com/ubuntu/pool/main/l/linux/ -O ubuntu.index
        deb1=$(grep linux-headers-$all ubuntu.index |grep all|awk '{print $6}'|awk -F"\"" '{print $2}')
        deb2=$(grep linux-headers-$kernel ubuntu.index |grep amd64|awk '{print $6}'|awk -F"\"" '{print $2}')
	if [ -n "$deb1" -a -n "$deb2" ]; then
        	wget http://security.ubuntu.com/ubuntu/pool/main/l/linux/$deb1
        	wget http://security.ubuntu.com/ubuntu/pool/main/l/linux/$deb2
        	dpkg --force-all  -i $deb1
        	dpkg --force-all  -i $deb2
		cd $workdir
        	rm -rf $tmpdir
		return 0
	fi
	cd $workdir
        rm -rf $tmpdir
	return 1
}

update_tool()
{
	git clone https://github.com/yyx/skbtracer.git
	cp skbtracer/src/* /root/
}


init_ubuntu || init_centos_new 
update_tool
