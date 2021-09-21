#!/bin/bash

# Made by Fernando "maroto"
# Run anything in the filesystem right before being "mksquashed"
# ISO-NEXT specific cleanup removals and additions (08-2021) @killajoe and @manuel

script_path=$(readlink -f ${0%/*})
work_dir=work

# Adapted from AIS. An excellent bit of code!
arch_chroot(){
    arch-chroot $script_path/${work_dir}/x86_64/airootfs /bin/bash -c "${1}"
}

do_merge(){

arch_chroot "

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
usermod -s /usr/bin/bash root
cp -aT /etc/skel/ /root/
rm /root/xed.dconf
chmod 700 /root
useradd -m -p \"\" -g users -G 'sys,rfkill,wheel' -s /bin/bash liveuser
git clone https://github.com/ringo32/liveuser-lxqt-settings.git
#git clone https://github.com/endeavouros-team/liveuser-desktop-settings.git
cd liveuser-lxqt-settings
rm -R /home/liveuser/.config
cp -R .config /home/liveuser/
chown -R liveuser:liveuser /home/liveuser/.config
cp .xinitrc .xprofile .Xauthority .xscreensaver /home/liveuser/
chown liveuser:liveuser /home/liveuser/.xinitrc
chown liveuser:liveuser /home/liveuser/.xprofile
chown liveuser:liveuser /home/liveuser/.Xauthority
chown liveuser:liveuser /home/liveuser/.xscreensaver
cp -R .local /home/liveuser/
chown -R liveuser:liveuser /home/liveuser/.local
chmod +x /home/liveuser/.local/bin/*
cp user_pkglist.txt /home/liveuser/
chown liveuser:liveuser /home/liveuser/user_pkglist.txt
cp user_commands.bash /home/liveuser/
chown liveuser:liveuser /home/liveuser/user_commands.bash
rm /home/liveuser/.bashrc
cp .bashrc /home/liveuser/
chown liveuser:liveuser /home/liveuser/.bashrc
cp LICENSE /home/liveuser/
cd ..
rm -R liveuser-lxqt-settings
chmod 755 /etc/sudoers.d
mkdir -p /media
chmod 755 /media
chmod 440 /etc/sudoers.d/g_wheel
chown 0 /etc/sudoers.d
chown 0 /etc/sudoers.d/g_wheel
chown root:root /etc/sudoers.d
chown root:root /etc/sudoers.d/g_wheel
chown root:root /etc/sddm.conf
chmod 755 /etc
sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
# sed -i 's/#Server/Server/g' /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf
systemctl enable NetworkManager.service vboxservice.service vmtoolsd.service vmware-vmblock-fuse.service systemd-timesyncd
systemctl set-default multi-user.target

cp -rf /usr/share/mkinitcpio/hook.preset /etc/mkinitcpio.d/linux.preset
sed -i 's?%PKGBASE%?linux?' /etc/mkinitcpio.d/linux.preset

# fetch fallback mirrorlist for offline installs:
wget https://raw.githubusercontent.com/endeavouros-team/EndeavourOS-iso-next/08-2021/mirrorlist
cp mirrorlist /etc/pacman.d/
rm mirrorlist

# now done with recreating pacman keyring inside calamares:
# shellprocess_initialize_pacman
#pacman-key --init
#pacman-key --add /usr/share/pacman/keyrings/endeavouros.gpg && sudo pacman-key --lsign-key 497AF50C92AD2384C56E1ACA003DB8B0CB23504F
#pacman-key --populate
#pacman-key --refresh-keys
#pacman -Syy

# to install locally builded packages on ISO:
#pacman -U --noconfirm /root/calamares_current-3.2.42-1-any.pkg.tar.zst
#rm /root/calamares_current-3.2.42-1-any.pkg.tar.zst
#pacman -U --noconfirm /root/calamares_config_next-2.3-4-any.pkg.tar.zst
#rm /root/calamares_config_next-2.3-4-any.pkg.tar.zst
#rm /var/log/pacman.log

# now done with recreating pacman keyring inside calamares:
# shellprocess_initialize_pacman
#rm -R /etc/pacman.d/gnupg

sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"$|GRUB_CMDLINE_LINUX_DEFAULT=\"\1 nowatchdog\"|' /etc/default/grub
sed -i 's?GRUB_DISTRIBUTOR=.*?GRUB_DISTRIBUTOR=\"EndeavourOS\"?' /etc/default/grub
sed -i 's?\#GRUB_THEME=.*?GRUB_THEME=\/boot\/grub\/themes\/EndeavourOS\/theme.txt?g' /etc/default/grub
sed -i 's?\#GRUB_DISABLE_SUBMENU=y?GRUB_DISABLE_SUBMENU=y?g' /etc/default/grub
echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub

# rm /boot/grub/grub.cfg --> seems mkarchiso is doing this now?

#wget https://raw.githubusercontent.com/endeavouros-team/liveuser-desktop-settings/08-2021/dconf/xed.dconf
#dbus-launch dconf load / < xed.dconf
#sudo -H -u liveuser bash -c 'dbus-launch dconf load / < xed.dconf'
#rm xed.dconf
chmod -R 700 /root
chown root:root -R /root
chown root:root -R /etc/skel
chmod 644 /usr/share/endeavouros/*.png
rm -rf /usr/share/lxqt/themes/frost/lxqt-origami-light.png
ln -s /usr/share/endeavouros/backgrounds/endeavouros-wallpaper.png /usr/share/lxqt/themes/frost/lxqt-origami-light.png
rm -rf /usr/share/sddm/themes/maldives/background.jpg
ln -s  /usr/share/endeavouros/backgrounds/endeavouros)wallpaper.png /usr/share/sddm/themes/maldives/background.jpg
rm -rf /usr/bin/chrooted_cleaner_script.sh
mv /root/chrooted_cleaner_script.sh /usr/bin/
chsh -s /bin/bash"
}

#################################
########## STARTS HERE ##########
#################################

do_merge
