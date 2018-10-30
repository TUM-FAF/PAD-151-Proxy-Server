# Proxy server

Get the most funny jokes.

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
