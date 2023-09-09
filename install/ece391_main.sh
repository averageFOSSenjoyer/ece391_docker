#!/bin/bash
set -e

script_dir=${HOME}/ece391
qemu_dir=${HOME}/qemu
image_dir=$IMAGE_DIR
share_dir=${script_dir}/smb_share
work_dir=${share_dir}/work
kernel_path=${work_dir}/source/linux-2.6.22.5/bzImage

install_qemu_v1_5() {
    echo "[*] Installing QEMU"

    echo "[*] Downloading QEMU"
    curl -L "https://download.qemu.org/qemu-1.5.0.tar.bz2" -o "/tmp/qemu-1.5.0.tar.bz2"
    tar xfj "/tmp/qemu-1.5.0.tar.bz2" -C "/tmp"

    # Work around ancient QEMU bug
    # https://bugzilla.redhat.com/show_bug.cgi?id=969955
    echo "[*] Patching QEMU -- removing libfdt_env.h"
    rm "/tmp/qemu-1.5.0/include/libfdt_env.h"

    # Workaround for newer Perl versions
    echo "[*] Patching QEMU -- modifying texi2pod.pl"
    sed -i 's/@strong{(.*)}/@strong\\{$1\\}/g' "/tmp/qemu-1.5.0/scripts/texi2pod.pl"
    (
        # Need to cd into the directory or else make fails
        # Run this in a subshell so we return to our old directory after
        cd "/tmp/qemu-1.5.0"
        echo "[*] Compiling QEMU (this may take a few minutes)"

        # Another weird workaround
        export ARFLAGS="rv"
        export TERM=xterm

        # Only compile for i386 arch to speed up compile time
        # Output directory will be in ${qemu_dir}
        # Make sure we're using python2 for systems like Arch where python points to python3
        
        if [[ $(uname -m) == "x86_64" ]]
        then
            ./configure --target-list=i386-softmmu --prefix="${qemu_dir}" --python=python2
        else
            ./configure --target-list=i386-softmmu --prefix="${qemu_dir}" --python=python2 --enable-tcg-interpreter
        fi

        make -j 8

        echo "[*] Installing QEMU"
        make install
    )
}

install_qemu_v2() {
    echo "[*] Installing QEMU"

    echo "[*] Downloading QEMU"
    curl -L "https://download.qemu.org/qemu-2.0.0.tar.bz2" -o "/tmp/qemu-2.0.0.tar.bz2"
    tar xfj "/tmp/qemu-2.0.0.tar.bz2" -C "/tmp"

    # Need to cd into the directory or else make fails
    # Run this in a subshell so we return to our old directory after
    cd "/tmp/qemu-2.0.0"
    echo "[*] Compiling QEMU (this may take a few minutes)"

    # Another weird workaround
    export ARFLAGS="rv"
    export TERM=xterm

    # Only compile for i386 arch to speed up compile time
    # Output directory will be in ${qemu_dir}
    # Make sure we're using python2 for systems like Arch where python points to python3
    ./configure --target-list=i386-softmmu --prefix="${qemu_dir}" --python=python2
    
    make -j 8

    echo "[*] Installing QEMU"
    make install
}

create_qcow() {
    echo "[*] Creating qcow files"
    mkdir -p "${image_dir}"

    echo "[*] Creating test.qcow"
    "${qemu_dir}/bin/qemu-img" create -b "${image_dir}/ece391.qcow" -f qcow2 "${image_dir}/devel.qcow" >/dev/null

    echo "[*] Creating test.qcow"
    "${qemu_dir}/bin/qemu-img" create -b "${image_dir}/ece391.qcow" -f qcow2 "${image_dir}/test.qcow" >/dev/null
}

create_shortcuts() {
    echo "[*] Creating shortcuts"
    mkdir -p "${script_dir}"

    tee "${script_dir}/devel" >/dev/null <<EOF
#!/bin/bash
params=()
for i in \$@;
do
    params+=("\$i")
done
"${qemu_dir}/bin/qemu-system-i386" -hda "${image_dir}/devel.qcow" -m 512 -name devel -k en-us -redir tcp:2022::22 \${params[@]}
EOF

    tee "${script_dir}/test_debug" >/dev/null <<EOF
#!/bin/bash
params=()
for i in \$@;
do
    params+=("\$i")
done
"${qemu_dir}/bin/qemu-system-i386" -hda "${image_dir}/test.qcow" -m 512 -name test -gdb tcp:127.0.0.1:1234 -redir tcp:2023::22 -kernel "${kernel_path}" -S -k en-us \${params[@]}
EOF

    tee "${script_dir}/test_nodebug" >/dev/null <<EOF
#!/bin/bash
params=()
for i in \$@;
do
    params+=("\$i")
done
"${qemu_dir}/bin/qemu-system-i386" -hda "${image_dir}/test.qcow" -m 512 -name test -gdb tcp:127.0.0.1:1234 -redir tcp:2024::22 -kernel "${kernel_path}" -k en-us \${params[@]}
EOF

    echo "[*] Making desktop shortcuts executable"
    chmod a+x "${script_dir}"/devel "${script_dir}"/test_debug "${script_dir}"/test_nodebug
    mkdir ${HOME}/Desktop/
    ln -s ${script_dir}/devel ${HOME}/Desktop/
    ln -s ${script_dir}/test_debug ${HOME}/Desktop/
    ln -s ${script_dir}/test_nodebug ${HOME}/Desktop/
}

config_samba() {
    echo "[*] Setting up Samba"
    mkdir -p ${share_dir}

    # Username must be same as Linux username for some reason
    echo "[*] Creating Samba user"
    smb_user="user"

    (echo "ece391"; echo "ece391") | sudo smbpasswd -a ${smb_user}

    echo "[*] Adding new Samba config"
    sudo tee -a "/etc/samba/smb.conf" >/dev/null <<EOF
### BEGIN ECE391 CONFIG ###
[ece391_share]
  path = "${share_dir}"
  valid users = ${smb_user}
  create mask = 0755
  read only = no

[global]
  ntlm auth = yes
  min protocol = NT1
### END ECE391 CONFIG ###
EOF

    ln -s ${share_dir}/work ${HOME}/Desktop/WORK_FOLDER
    ln -s ${share_dir}/work ${HOME}/WORK_FOLDER
}

config_ssh() { 
    mkdir ~/.ssh 
    touch ~/.ssh/config
    sudo tee -a ~/.ssh/config >/dev/null <<EOF
Host 391devel
	Ciphers 3des-cbc
	KexAlgorithms +diffie-hellman-group1-sha1
	HostKeyAlgorithms=+ssh-dss
	HostName localhost
	Port 2022
	User user

Host 391testdbug
	Ciphers 3des-cbc
	KexAlgorithms +diffie-hellman-group1-sha1
	HostKeyAlgorithms=+ssh-dss
	HostName localhost
	Port 2023
	User user

Host 391testndbug
	Ciphers 3des-cbc
	KexAlgorithms +diffie-hellman-group1-sha1
	HostKeyAlgorithms=+ssh-dss
	HostName localhost
	Port 2024
	User user
EOF

    sudo chmod 700 ~/.ssh
    sudo chmod 600 ~/.ssh/*
}

# if [[ $(uname -m) == "x86_64" ]]
# then
#     echo "Compiling for x86"
#     install_qemu_v1_5
# else
#     echo "Compiling for arm"
#     install_qemu_v2
# fi

install_qemu_v1_5
create_qcow
create_shortcuts
config_samba
config_ssh
