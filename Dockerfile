FROM abc3660170/fonts:latest
RUN yum install postgis24_95 postgis24_95-client -y
RUN yum install ogr_fdw95 -y
RUN yum install pgrouting_95 -y
COPY run.sh /
ENTRYPOINT ["/run.sh"]
CMD []