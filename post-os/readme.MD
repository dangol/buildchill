# Post OS Installation Scripts

Before using the following steps are required:
- Scripts assume being run from a share called \\remin\shares\psql
- This is handled by the variable "$INPATH", there are multiple references to this.

### helpers\data.ps1
- requires a list of usernames (comma seperated) e.g. bob,sue,sally
- the users password 
- the DB server password

### helpers\psql.options
- superpassword= needs to be set

### helpers\psql.psql
- CREATE USER "chgGameCzar" WITH PASSWORD 'passwd'; < passwords need to be set
- CREATE USER "chgHmsCzar" WITH PASSWORD 'passwd'; < passwords need to be set
