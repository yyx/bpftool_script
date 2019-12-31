centos=$(grep -i centos /etc/os-release)
ubuntu=$(grep -i ubuntu /etc/os-release)

init_centos()
{
kernel=$(uname -r)
release=$(echo $kernel|awk -F"el" '{print $2}'|awk -F"." '{print $1}')

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
dpkg dpkg --force-all  -i $deb1
dpkg dpkg --force-all  -i $deb2
}


if [ -n $centos ];then
init_centos
fi

if [ -n $ubuntu ];then
init_ubuntu
fi
