export PGPASSWORD=demo123
pg_dump --schema=pulic --schema=common --host=localhost --username=demo --schema-only bonsai_dev
export PGPASSWORD=''
