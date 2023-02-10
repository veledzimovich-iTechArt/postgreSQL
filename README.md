PostgreSQL

Content

- [basic](#basic)
- [example](#example)
- [shop](#shop)

# basic

Download postgres.app

# example

# shop

Execute commands to create DB and run example

```bash
createdb -U postgres shop_sql
psql -U postgres -p 5432 -d shop_sql -f shop_sql.sql
dropdb shop_sql
```
