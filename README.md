# IIOT Recipe Database - Work In Progress

***!!!*** This repo may be updated or deleted once the project reaches a more complete state. ***!!!***

## Overview
This is a preliminary work in progress. The full stack is still under development, and this repository is made public following requests to view the code. The project is designed to explore patterns for incorporating transactional data into an event-driven IIOT architecture.

### Components
- **Node-RED Backend**: Manages the API and services interacting with the PostgreSQL database. Update the username and password for the broker and database connections within Node-RED.
- **Node-RED Frontend**: Planned as the UI to interact with the API endpoints.
- **pg-uns-bridge**: A service that listens to notify events from PostgreSQL and publishes them to the MQTT broker.
- **PostgreSQL**: The database used for storing all recipe data.
- **broker-standalone**: An MQTT broker, specifically Mosquitto.

### Quick Notes
- **API Documentation**: Still in progress; refer to comments in the Node-RED flows for endpoint details.
- **Operations**: Create, update, and delete functions can be triggered by publishing to the appropriate MQTT topics.

## Example Recipe JSON Object
Below is an example of a Recipe JSON object

```json
{
    "outputMaterial_id": 1,
    "equipmentType": "Mixer",
    "material": [
        {"id": 1, "name": "Flour", "quantity": "0.50", "uom": "kg", "numberFormat": "#,##0.0"},
        {"id": 2, "name": "Water", "quantity": "0.30", "uom": "liters", "numberFormat": "#,##0.0"},
        {"id": 3, "name": "Yeast", "quantity": "0.01", "uom": "grams", "numberFormat": "#,##0.0"},
        {"id": 4, "name": "Salt", "quantity": "0.01", "uom": "grams", "numberFormat": "#,##0.0"},
        {"id": 5, "name": "Sugar", "quantity": "0.02", "uom": "grams", "numberFormat": "#,##0.0"}
    ],
    "parameters": [
        {"id": 1, "name": "Batch Size", "value": "1.00", "uom": "lbs", "numberFormat": "#,##0"},
        {"id": 2, "name": "Mixing Time", "value": "15.00", "uom": "minutes", "numberFormat": "#,##0"},
        {"id": 3, "name": "Mixing Speed", "value": "60.00", "uom": "rpm", "numberFormat": "#"},
        {"id": 4, "name": "Proof Time", "value": "30.00", "uom": "minutes", "numberFormat": "#,##0"}
    ]
}
```

## Disclaimer
This project is a work in progress and has not been fully tested. Functionality may not be fully operational yet.

## MQTT Operations

### General Format
- **Topic Pattern**: `entity/operation`
- **Payload**: JSON formatted string specifying the details necessary for the operation.

### Entity List
- Equipment
- Material
- Parameter
- Recipe

### Operations
- Create
- Update
- Delete

### Create
- **Topic**: `<entity>/create`
- **Payload**: JSON object specific to the entity being created.
- **Example** (Create a new material):
  - **Topic**: `Material/Create`
  - **Payload**:
    ```json
    {
      "name": "New Material",
      "description": "A new material for testing",
      "type": "Raw",
      "uom": "kg",
      "number_format": "#,##0.0"
    }
    ```

### Update
- **Topic**: `<entity>/update`
- **Payload**: JSON object containing the ID of the entity and the properties to be updated.
- **Example** (Update a material):
  - **Topic**: `Material/Update`
  - **Payload**:
    ```json
    {
      "id": 123,
      "name": "Updated Material",
      "description": "An Updated material for testing",
      "type": "Raw",
      "uom": "lbs",
      "number_format": "#,##0.0"
    }
    ```

### Delete
- **Topic**: `<entity>/delete`
- **Payload**: JSON object typically containing the ID of the entity to be deleted.
- **Example** (Delete a material):
  - **Topic**: `Material/Delete`
  - **Payload**:
    ```json
    {
      "id": 123
    }
    ```

## Response
- **Topic**: `<entity>/<Operation>/Response`
- **Payload**: JSON object containing the ID of the entity operated on or a detailed error message.
- **Successful Example** (Create a new material Response):
  - **Topic**: `Material/Create/Response`
  - **Payload**:
    ```json
    {
      "id": 123
    }
    ```
- **Failed Example** (Create a new material Response):
  - **Topic**: `Material/Create/Response`
  - **Payload**:
    ```json
    {
    "error": "Missing keys: type. "
    }
    ```

# API Documentation

## Overview
This document provides comprehensive API documentation for managing equipment, materials, parameters, and recipes within the IIOT Recipe Database. The API interfaces with a PostgreSQL database using HTTP methods for CRUD operations.

## Equipment Management

### Create Equipment
- **Endpoint**: `POST /equipment`
- **Body**:
  ```json
  {
    "name": "string",
    "description": "string",
    "type": "string"
  }
  ```
- **Success**: `200 OK` with `{"id": integer}`
- **Error**: `400 Bad Request` with `{"error": "string"}`

### Read All Equipment
- **Endpoint**: `GET /equipment`
- **Success**: `200 OK` with array of equipment objects

### Read Equipment by ID
- **Endpoint**: `GET /equipment/:id`
- **Parameters**: `id` (integer)
- **Success**: `200 OK` with equipment object

### Update Equipment
- **Endpoint**: `PATCH /equipment/:id`
- **Parameters**: `id` (integer)
- **Body**:
  ```json
  {
    "name": "string",
    "description": "string",
    "type": "string",
    "uom": "string",
    "number_format": "string"
  }
  ```
- **Success**: `200 OK` with `{"id": integer}`

### Delete Equipment
- **Endpoint**: `DELETE /equipment/:id`
- **Parameters**: `id` (integer)
- **Success**: `200 OK` with `{"id": integer}`

## Material Management

### Create Material
- **Endpoint**: `POST /material`
- **Body**:
  ```json
  {
    "name": "string",
    "description": "string",
    "type": "string",
    "uom": "string",
    "number_format": "string"
  }
  ```
- **Success**: `200 OK` with `{"id": integer}`

### Read All Materials
- **Endpoint**: `GET /material`
- **Success**: `200 OK` with array of material objects

### Read Material by ID
- **Endpoint**: `GET /material/:id`
- **Parameters**: `id` (integer)
- **Success**: `200 OK` with material object

### Update Material
- **Endpoint**: `PATCH /material/:id`
- **Parameters**: `id` (integer)
- **Body**:
  ```json
  {
    "name": "string",
    "description": "string",
    "type": "string",
    "uom": "string",
    "number_format": "string"
  }
  ```
- **Success**: `200 OK` with `{"id": integer}`

### Delete Material
- **Endpoint**: `DELETE /material/:id`
- **Parameters**: `id` (integer)
- **Success**: `200 OK` with `{"id": integer}`

## Parameter Management

### Create Parameter
- **Endpoint**: `POST /parameter`
- **Body**:
  ```json
  {
    "name": "string",
    "description": "string",
    "uom": "string",
    "number_format": "string"
  }
  ```
- **Success**: `200 OK` with `{"id": integer}`

### Read All Parameters
- **Endpoint**: `GET /parameter`
- **Success**: `200 OK` with array of parameter objects

### Read Parameter by ID
- **Endpoint**: `GET /parameter/:id`
- **Parameters**: `id` (integer)
- **Success**: `200 OK` with parameter object

### Update Parameter
- **Endpoint**: `PATCH /parameter/:id`
- **Parameters**: `id` (integer)
- **Body**:
  ```json
  {
    "name": "string",
    "description": "string",
    "uom": "string",
    "number_format": "string"
  }
  ```
- **Success**: `200 OK` with `{"id": integer}`

### Delete Parameter
- **Endpoint**: `DELETE /parameter/:id`
- **Success**: `200 OK` with `{"id": integer}`

## Recipe Management

### Create Recipe
- **Endpoint**: `POST /recipe`
- **Body**:
  ```json
  {
    "outputMaterial_id": "integer",
    "equipmentType": "string",
    "material": [{"id": "integer", "quantity": "float"}],
    "parameters": [{"id": "integer", "value": "float"}]
  }
  ```
- **Success**: `200 OK` with `{"id": integer}`

### Read All Recipes
- **Endpoint**: `GET /recipe`
- **Parameters**: `id` (integer)
- **Success**: `200 OK` with `[{"recipe_id": integer,"material_id": integer,"material_name": string,"equipment_type": string}]`

### Read One Recipe
- **Endpoint**: `GET /recipe/:id`
- **Parameters**: `id` (integer)
- **Success**: `200 OK` with detailed recipe object

### Delete One Recipe
- **Endpoint**: `DELETE /recipe/:id`
- **Parameters**: `id` (integer)
- **Success**: `200 OK` with `{"message": "Recipe deleted successfully"}`

### Update Recipe
- **Endpoint**: `PATCH /recipe/:id`
- **Parameters**: `id` (integer)
- **Body**:
  ```json
  {
    "name": "string",
    "material_id": "string",
    "equipment_type": "string"
  }
  ```
- **Success**: `200 OK` with `{"id": integer}`

### Add a Material to a Recipe
- **Endpoint**: `POST /recipe/:id/material`
- **Parameters**: `id` (integer)
- **Body**:
  ```json
  {
    "material_id": "integer",
    "material_quantity": "float"
  }
  ```
- **Success**: `200 OK` with `{"message": "Material added successfully"}`

### Update a Material in a Recipe
- **Endpoint**: `PATCH /recipe/:id/material/:material_id`
- **Parameters**: `id` (integer), `material_id` (integer)
- **Body**:
  ```json
  {
    "material_quantity": "float"
  }
  ```
- **Success**: `200 OK` with `{"recipe_id": integer,"material_id": integer}`

### Delete a Material from a Recipe
- **Endpoint**: `DELETE /recipe/:id/parameter/:material_id`
- **Parameters**: `id` (integer), `material_id` (integer)
- **Success**: `200 OK` with `{"recipe_id": integer,"material_id": integer}`

### Add a Parameter to a Recipe
- **Endpoint**: `POST /recipe/:id/parameter`
- **Parameters**: `id` (integer)
- **Body**:
  ```json
  {
    "parameter_id": "integer",
    "parameter_value": "float"
  }
  ```
- **Success**: `200 OK` with `{"message": "Parameter added successfully"}`

### Update a Parameter in a Recipe
- **Endpoint**: `PATCH /recipe/:id/parameter/:parameter_id `
- **Parameters**: `id` (integer), `parameter_id` (integer)
- **Body**:
  ```json
  {
    "parameter_value": "float"
  }
  ```
- **Success**: `200 OK` with `{"recipe_id": integer,"parameter_id": integer}`

### Delete a Parameter from a Recipe
- **Endpoint**: `DELETE /recipe/:id/parameter/:parameter_id `
- **Parameters**: `id` (integer), `parameter_id` (integer)
- **Success**: `200 OK` with `{"recipe_id": integer,"parameter_id": integer}`

## Error Handling
All error responses return a JSON object with an error description and the corresponding HTTP status code.
