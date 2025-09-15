
## Postgres config

username: shan
password: postgres
host: localhost
port: 5432
db_name: lecturedb

## Create schema 

```sql
CREATE SCHEMA IF NOT EXISTS books_exchange; 
SET search_path TO books_exchange;
```

Select code block and use cmd EE
After CREATE is successfully executed, go to PGAdmin and refresh
Check if tables is created in PGAdmin