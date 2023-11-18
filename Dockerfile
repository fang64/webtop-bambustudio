FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntujammy

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Bambu Studio version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="fang64"

# prevent Ubuntu's firefox stub from being installed
COPY /root/etc/apt/preferences.d/firefox-no-snap /etc/apt/preferences.d/firefox-no-snap

RUN \
  echo "**** install packages ****" && \
  add-apt-repository -y ppa:mozillateam/ppa && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    libfuse2 \
    wget \
    unzip \
    firefox \
    mousepad \
    xfce4-terminal \
    xfce4 \
    xubuntu-default-settings \
    xubuntu-icon-theme && \
  apt-get install libwebkit2gtk-4.0-37 gstreamer1.0-plugins-bad gstreamer1.0-libav -y && \
  echo "**** Install Orca Slicer ****" && \
  curl -s -L https://api.github.com/repos/SoftFever/OrcaSlicer/releases/latest | grep -wo "https.*Linux.*AppImage" | wget -qi- -O /opt/OrcaSlicer.AppImage && \
  chmod +x /opt/OrcaSlicer.AppImage && \
  cd /opt && \
  ./OrcaSlicer.AppImage --appimage-extract && \
  mv /opt/squashfs-root /opt/orcaslicer && \
  cp /opt/orcaslicer/OrcaSlicer.desktop /usr/share/applications && \
  sed -i 's/Exec=AppRun/Exec=\/opt\/orcaslicer\/AppRun/' /usr/share/applications/OrcaSlicer.desktop && \
  chmod 755 /usr/share/applications/OrcaSlicer.desktop && \
  rm /opt/OrcaSlicer.AppImage && \
  echo "**** Install Bambu Studio ****" && \
  curl -s -L https://api.github.com/repos/bambulab/BambuStudio/releases/latest | grep -wo "https.*ubuntu.*AppImage" | wget -qi- -O /opt/BambuStudio.AppImage && \
  chmod +x /opt/BambuStudio.AppImage && \
  cd /opt && \
  ./BambuStudio.AppImage --appimage-extract && \
  mv /opt/squashfs-root /opt/bambustudio && \
  cp /opt/bambustudio/BambuStudio.desktop /usr/share/applications && \
  sed -i 's/Exec=AppRun/Exec=\/opt\/bambustudio\/AppRun/' /usr/share/applications/BambuStudio.desktop && \
  chmod 755 /usr/share/applications/BambuStudio.desktop && \
  rm /opt/BambuStudio.AppImage && \
  echo "**** xfce tweaks ****" && \
  rm -f \
    /etc/xdg/autostart/xscreensaver.desktop && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config
