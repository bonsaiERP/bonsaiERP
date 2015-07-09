# Hstore

To create hsore type in the database one must assing to a schema

```sql
CREATE EXTENSION hstore WITH SCHEMA public;
```

Once the extension is added to add a column to any table one must add
this way


```sql
ALTER TABLE my_table ADD COLUMN schema_name.hstore_column public.hstore;
```

To update hstore columns one can

```sql
UPDATE tale_name SET hstore = HSTORE('key', 'val')
-- With concatenation

UPDATE tale_name SET hstore = HSTORE('key', 'val') ||
HSTORE('key2', 'val2')
```
