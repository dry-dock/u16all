FROM drydock/u16:{{%TAG%}}

ADD . /u16all

RUN /u16all/install.sh && rm -rf /tmp && mkdir /tmp && chmod 1777 /tmp
