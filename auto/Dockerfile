FROM docker.iwanna.xyz:5000/cshuo/coreos_manager:v2

RUN sudo apt-get install python-ldap && pip install django-auth-ldap

ADD init.sh /opt/

ADD nap /opt/nap

ADD nap/nap /usr/local/bin/

ENTRYPOINT ["/opt/init.sh"]
