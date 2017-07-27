# Metasploit-Framework Docker Image With Postgres Support

This Docker image will be updated about once a month.  

Usage:
```bash
docker run -it -P peakkk/metasploit:with-db
```

Then the container will automatically expose 4 ports for reverse connections.
These ports are `80`, `8080`, `443` and `4444`.

For a long-term running container, it is recommended to use the following command instead. It provides the abilities to configure, customize and upgrade.  
```bash
docker run -it -P peakkk/metasploit:with-db bash
```
