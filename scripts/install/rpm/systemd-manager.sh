# SYSTEMD-MANAGER - GUI Interface For SystemD
# A graphical tool for managing systemd settings

## Installing on CentOS 7
```
# Install general software building tools
sudo yum install gcc gcc-c++ kernel-devel
# Install dependencies for systemd-manager
sudo yum install cargo glib2-devel cairo cairo-devel dbus-devel pango pango-devel atk atk-devel gdk-pixbuf2-devel gtk3-devel
# Git clone, make, & install
git clone https://github.com/mmstick/systemd-manager && cd systemd-manager && make && sudo make install
```
