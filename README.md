# IIOT Recipe Database
- This is a Preliminary work in progress, I will probably delete this when the full stack is functional. Publishing this repo because there were a few requests to see the code.
- The intent of this project is to learn patterns for incorporating Transactional Data in an event driven IIOT Architecture.

### Quick Notes
- **Node Red Backend**, this holds the current iteration of the API and services that interact with the Postgres Database. You will need to update the username and password for the Broker and the database connections in Node Red.
- **Node Red Frontend**, this is planned as the UI to interact with the API Endpoints.
- **pg-uns-bridge**, this is a first pass at a service to listin to Notify Events from Postgres and Publish the event to the MQTT Broker.
- **postgres**, this is what it sounds like... A postgres database.
- **broker-standalone**, this is the MQTT Broker, Mosquitto to be precise.

### API Documentation
- Work in progress, see comments in the Node Red Flows for endpoints.
- Create, Update, and Delete Functions can also be triggered by publishing to the appropriate topics.
- See below for an Example of a Recipe JSON object that is used to create a new recipe:
- Try publishing the JSON Recipe to the topic `Recipe/Create`.

```json
{
    "outputMaterial_id": 1,
    "equipmentType": "Mixer",
    "material": [
        {
            "id": 1,
            "name": "Flour",
            "quantity": "0.50",
            "uom": "kg",
            "numberFormat": "#,##0.0"
        },
        {
            "id": 2,
            "name": "Water",
            "quantity": "0.30",
            "uom": "liters",
            "numberFormat": "#,##0.0"
        },
        {
            "id": 3,
            "name": "Yeast",
            "quantity": "0.01",
            "uom": "grams",
            "numberFormat": "#,##0.0"
        },
        {
            "id": 4,
            "name": "Salt",
            "quantity": "0.01",
            "uom": "grams",
            "numberFormat": "#,##0.0"
        },
        {
            "id": 5,
            "name": "Sugar",
            "quantity": "0.02",
            "uom": "grams",
            "numberFormat": "#,##0.0"
        }
    ],
    "parameters": [
        {
            "id": 1,
            "name": "Batch Size",
            "quantity": "1.00",
            "uom": "lbs",
            "numberFormat": "#,##0"
        },
        {
            "id": 2,
            "name": "Mixing Time",
            "quantity": "15.00",
            "uom": "minutes",
            "numberFormat": "#,##0"
        },
        {
            "id": 3,
            "name": "Mixing Speed",
            "quantity": "60.00",
            "uom": "rpm",
            "numberFormat": "#"
        },
        {
            "id": 4,
            "name": "Proof Time",
            "quantity": "30.00",
            "uom": "minutes",
            "numberFormat": "#,##0"
        }
    ]
}
```

### Work In Progress...
Again, this is a work in progress. Not everything has been fully tested so if it actually works that is a bonus.
