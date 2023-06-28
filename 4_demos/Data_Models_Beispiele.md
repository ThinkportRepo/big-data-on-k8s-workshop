# Daten Model Beispiele

Definitionen zur Verwendung im Modeling Tool https://dbdiagram.io/

## Sternschema

```

Table orders_fact {
  id integer [primary key]
  product_id integer
  customer_id integer
  date timestamp
  quatitiy integer
  price double
}

Table customers_dim {
  id integer [primary key]
  name varchar
  address varchar
  phone varchar
}

Table products_dim {
  id integer [primary key]
  name varchar
  category varchar
  description text
}


Ref: customers_dim.id < orders_fact.customer_id
Ref: products_dim.id < orders_fact.product_id

```

## Galaxy Schema

```

Table orders_fact {
  id integer [primary key]
  product_id integer
  customer_id integer
  date timestamp
  quatitiy integer
  price double
}

Table customers_dim {
  id integer [primary key]
  name varchar
  address varchar
  phone varchar
}

Table products_dim {
  id integer [primary key]
  name varchar
  description text
  category varchar
}

Table purchase_fact {
  id integer [primary key]
  product_id int
  supplier_id int
  price double
}

Table suppliers_dim {
  id integer [primary key]
  name varchar
  adress varchar
  phone varchar
}


Ref: customers_dim.id < orders_fact.customer_id
Ref: products_dim.id < orders_fact.product_id
Ref: products_dim.id < purchase_fact.product_id
Ref: suppliers_dim.id < purchase_fact.supplier_id



```

## Snowflake

Erweiterung durch Normalisierung

```
Table orders_fact {
  id integer [primary key]
  product_id integer
  customer_id integer
  date timestamp
  quatitiy integer
  price double
}

Table customers_dim {
  id integer [primary key]
  name varchar
  address varchar
  phone_id varchar
}

Table products_dim {
  id integer [primary key]
  name varchar
  description text
  category varchar
}

Ref: customers_dim.id < orders_fact.customer_id
Ref: products_dim.id < orders_fact.product_id


Table phone_dim {
  id integer [primary key]
  type varchar
  country_code varchar
  number varchar
}
Ref: phone_dim.id < customers_dim.phone_id


```

und erweitert

````


Table purchase_fact {
  id integer [primary key]
  product_id int
  supplier_id int
  price double
}

Table suppliers_dim {
  id integer [primary key]
  name varchar
  adress varchar
  phone varchar
}


Ref: products_dim.id < purchase_fact.product_id
Ref: suppliers_dim.id < purchase_fact.supplier_id
Ref: phone_dim.id < suppliers_dim.phone

```

## 3NF Ausnormalisiert
Maximale ausnormalisierung um mögliche Redundanzen zu minimieren

Table orders {
  id integer [primary key]
  product_id integer
  customer_id integer
  date timestamp
  quatitiy integer
  price double
}

Table customers {
  id integer [primary key]
  name varchar
  address varchar
  phone_id varchar
}

Table products {
  id integer [primary key]
  name varchar
  description text
}

Table phone {
  id integer [primary key]
  type varchar
  country_code varchar
  number varchar
}

Table countries {
  id integer [primary key]
  name varchar
  prefix varchar
}

Table countries {
  id integer [primary key]
  name varchar
  prefix varchar
}



Ref: customers.id < orders.customer_id
Ref: products.id < orders.product_id
Ref: phone.id < customers.phone_id
Ref: countries.id < phone.id


#############################################################
# Galaxy Schema


Table orders {
  id integer [primary key]
  product_id integer
  customer_id integer
  date timestamp
  quatitiy integer
  price double
}

Table customers {
  id integer [primary key]
  name varchar
  address varchar
  mobil varchar
}

Table products {
  id integer [primary key]
  name varchar
  description text
}

Table purchase {
  id integer [primary key]
  product_id int
  supplier_id int
  price double
}

Table suppliers {
  id integer [primary key]
  name varchar
  adress varchar
  phone varchar
}


Ref: customers.id < orders.customer_id
Ref: products.id < orders.product_id
Ref: products.id < purchase.product_id
Ref: suppliers.id < purchase.supplier_id


####################################
Data Vault
````
