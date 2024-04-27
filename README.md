# IIOT Recipe Database
- This is a Preliminary work in progress, I will probably delete this when the full stack is functional. Publishing this repo because there were a few requests to see the code.
- The intent of this project is to learn patterns for incorporating Transactional Data in an event driven IIOT Architecture.

### Quick Notes
- **Node Red Backend**, this holds the current iteration of the API and services that interact with the Postgres Database.
- **Node Red Frontend**, this is planned as the UI to interact with the API Endpoints.
- **pg-uns-bridge**, this is a first pass at a service to listin to Notify Events from Postgres and Publish the event to the MQTT Broker.
- **postgres**, this is what it sounds like... A postgres database.
- **broker-standalone**, this is the MQTT Broker, Mosquitto to be precise.

### API Documentation
- Work in progress, see comments in the Node Red Flows for endpoints.
- Create, Update, and Delete Functions can also be triggered by publishing to the appropriate topics.
- See below for an Example of a Recipe JSON object that is used to create a new recipe:

```json
{
	"outputMaterial_id": 6,
	"equipmentType": "Mixer",
	"material": [
		{
			"id": 1,
			"quantity": 0.5
		},
		{
			"id": 2,
			"quantity": 0.3
		}
	],
	"parameters": [
		{
			"id": 1,
			"quantity": 0.5
		},
		{
			"id": 2,
			"quantity": 0.3
		}
	]
}
```

### Work In Progress...
Again, this is a work in progress. Not everything has been fully tested so if it actually works that is a bonus.
