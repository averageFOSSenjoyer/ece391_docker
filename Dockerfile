FROM debian:11

ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901

EXPOSE $NO_VNC_PORT

### Envrionment config
ENV HOME=/home/user \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/home/user/install \
    NO_VNC_HOME=/home/user/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1600x900 \
    VNC_PW=ece391 \
    VNC_VIEW_ONLY=false \
    SSH_PORT=37391 \
    ECE391_DIR=/home/user/ece391 \ 
    IMAGE_DIR=/home/user/ece391/images_DO_NOT_TOUCH

WORKDIR $HOME

### Add all install scripts for further steps
ADD ./install/ $INST_SCRIPTS/

### install 391 dependencies
RUN $INST_SCRIPTS/ece391_dependencies.sh

### creating user
RUN $INST_SCRIPTS/create_users.sh

### Install some common tools
RUN $INST_SCRIPTS/tools.sh
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN $INST_SCRIPTS/tigervnc.sh
RUN $INST_SCRIPTS/no_vnc.sh

### Install xfce UI
RUN $INST_SCRIPTS/xfce_ui.sh
ADD ./xfce/ $HOME/

### configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD ./scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

USER user

WORKDIR $IMAGE_DIR
ADD ./ece391.qcow $IMAGE_DIR

WORKDIR $ECE391_DIR

### install 391 dev environment
RUN $INST_SCRIPTS/ece391_main.sh

ADD ./work $ECE391_DIR/smb_share/work
RUN $INST_SCRIPTS/work_dir_perm.sh
ADD ./tux_emulator_linux $HOME/Desktop/tux_emulator

WORKDIR $HOME

ENTRYPOINT ["/dockerstartup/startup.sh"]
CMD ["--wait"]
