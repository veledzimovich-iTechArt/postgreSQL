# /usr/bin/bash

dropdb shop_sql
createdb -U postgres shop_sql
psql -U postgres -p 5432 -d shop_sql -f shop/shop_init.sql
psql -U postgres -p 5432 -d shop_sql -f shop/shop_roles.sql
psql -U postgres -p 5432 -d shop_sql -f shop/shop_index_populate.sql
psql -U postgres -p 5432 -d shop_sql -f shop/shop_index_select.sql
psql -U postgres -p 5432 -d shop_sql -f shop/shop_index_init.sql
wait
psql -U postgres -p 5432 -d shop_sql -f shop/shop_index_select.sql
