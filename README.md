# Proxy server

## Working with containers

If you choose to run containers individually, use
```bash
docker build -t <image-name> .
docker --rm -it -p <host-port>:<container-port> <image-name> bash
```

But when your container depends on another one, you could issue `docker-compose up --build` command to build and run them.

When making new changes in the source files the images does *not* sync with them, therefore you're expected to restart the desired service with `docker-compose restart <service-name>`.

If you want to scale up an image e.g. `warehouse` image, you can issue `docker-compose scale <service-name>=<number-of-replicas>`.

## Communication
A client can communicate with servers using the following API:

- `get` `/api/v1/joke/<id>` - get a specific joke

```xml
<joke>
	<joke_id></joke_id>
	<author></author>
	<text></text>
	<joke_rating></joke_rating>
	<extra>
		<!-- some extra stuff here -->
	</extra>
</joke>
```

- `get` `/api/v1/jokes` - get a list of jokes

```xml
<joke_list>
	<joke>
		<!-- joke body -->
	</joke>
	<!-- more jokes -->
</joke_list>
```

- `get` `/api/v1/jokescount` - get the number of jokes

```xml
<joke_number>
	<!-- some number here -->
</joke_number>
```

- `post` `/api/v1/joke` - post a new funny joke

```xml
<joke>
	<text></text>
	<author></author>
	<extra>
		<!-- some extra stuff here -->
	</extra>
</joke>
```
