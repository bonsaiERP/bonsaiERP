# Main backup

     sudo -s
     su - postgres
     cd /tmp
     pg_dump bonsai_prod | gzip > bonsai_prod-DATE.gz
