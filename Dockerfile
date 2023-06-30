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
    libwebkit2gtk-4.0-37 \
    firefox \
    mousepad \
    xfce4-terminal \
    xfce4 \
    xubuntu-default-settings \
    xubuntu-icon-theme && \
  echo "**** Install Orca Slicer ****" && \
  wget https://github.com/SoftFever/OrcaSlicer/releases/download/v1.6.3/OrcaSlicer_V1.6.3_Linux.zip -O /tmp/Orca.zip && \
  unzip /tmp/Orca.zip -d /opt/ && \
  chmod +x /opt/OrcaSlicer_ubu64.AppImage && \
  cd /opt && \
  ./OrcaSlicer_ubu64.AppImage --appimage-extract && \
  mv /opt/squashfs-root /opt/orcaslicer && \
  cp /opt/orcaslicer/OrcaSlicer.desktop /usr/share/applications && \
  sed -i 's/Exec=AppRun/Exec=\/opt\/orcaslicer\/AppRun/' /usr/share/applications/OrcaSlicer.desktop && \
  chmod 755 /usr/share/applications/OrcaSlicer.desktop && \
  echo "**** Install Bambu Studio ****" && \
  wget https://github.com/bambulab/BambuStudio/releases/download/v01.06.02.04/Bambu_Studio_linux_ubuntu_v01.06.02.04-20230427094209.AppImage -O /opt/BambuStudio.AppImage && \
  chmod +x /opt/BambuStudio.AppImage && \
  cd /opt && \
  ./BambuStudio.AppImage --appimage-extract && \
  mv /opt/squashfs-root /opt/bambustudio && \
  cp /opt/bambustudio/BambuStudio.desktop /usr/share/applications && \
  sed -i 's/Exec=AppRun/Exec=\/opt\/bambustudio\/AppRun/' /usr/share/applications/BambuStudio.desktop && \
  chmod 755 /usr/share/applications/BambuStudio.desktop && \
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
