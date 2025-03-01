# n8n-docker-stack

[Under Construction]

A basic docker stack to build a N8N Server Node to automate many task on your computer.

``` mermaid
flowchart TD
    A[N8N] -->|Cache, Memory| B(Redis)
    A[N8N] -->|Persistance, Vector Store| C(PGVector)  
```

AT least compose a server with :
- a N8N service : basic community N8N app for flow automation
- a redis Service  : for caching, building **AI Agent Memory** for example
- a Postgres service : for data persistance on building **AI Vector Stores**.





