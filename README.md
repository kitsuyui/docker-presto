# docker-presto

## server

```console
$ docker build . -t my-presto
$ docker run \
    --name=my-presto-instance \
    -h presto \
    -p 8080:8080 \
    -v $(pwd)/etc:/presto/etc:Z \
    -v $(pwd)/data:/presto/data:Z \
    my-presto
```

## client

```console
$ ./presto-cli --server localhost:8080 --catalog hive --schema default
```

Download from: https://prestodb.io/docs/current/installation/cli.html
