PostgreSQL

Content

- [basic](#basic)
- [example](#example)
- [shop](#shop)

# basic

Download postgres.app

# example

# shop

Execute commands to create DB and run examples one by one

```bash
dropdb shop_sql
createdb -U postgres shop_sql
# setup
psql -U postgres -p 5432 -d shop_sql -f shop/shop_init.sql
psql -U postgres -p 5432 -d shop_sql -f shop/shop_roles.sql
psql -U postgres -p 5432 -d shop_sql -f shop/shop_populate.sql
# execute
psql -U shop_admin -p 5432 -d shop_sql -f shop/shop_admin.sql
psql -U whoami -p 5432 -d shop_sql -f shop/shop_customer.sql
```

Execute commands to check performance
```bash
./shop/indexes.sh
```
