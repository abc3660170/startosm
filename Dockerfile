FROM abc3660170/fonts:latest

RUN touch /var/log/1.txt
COPY run.sh /
ENTRYPOINT ["/run.sh"]
CMD []