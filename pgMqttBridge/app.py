import os
import sys
import asyncio
from aiohttp import web
import aiopg
import paho.mqtt.client as mqtt
from dotenv import load_dotenv
from loguru import logger
import json

# Load environment variables
load_dotenv()

# Set the minimum log level based on the LOG_LEVEL environment variable
log_level = os.getenv('LOG_LEVEL', 'INFO')
logger.remove()
logger.add(sys.stderr, level=log_level)

# MQTT Settings
MQTT_BROKER = os.getenv('MQTT_BROKER')
MQTT_PORT = int(os.getenv('MQTT_PORT'))
MQTT_TOPIC = os.getenv('MQTT_TOPIC')
DB_DSN = (f"dbname={os.getenv('DB_NAME')} user={os.getenv('DB_USER')} "
          f"password={os.getenv('DB_PASSWORD')} host={os.getenv('DB_HOST')}")

# Initialize MQTT client
mqtt_client = mqtt.Client(protocol=mqtt.MQTTv5, callback_api_version=mqtt.CallbackAPIVersion.VERSION2)


def on_connect(client, userdata, flags, reason_code, properties):
    logger.info(f"Connected to MQTT Broker with result code {reason_code}")


def setup_mqtt_client():
    mqtt_client.username_pw_set(os.getenv('MQTT_USER'), os.getenv('MQTT_PASSWORD'))
    mqtt_client.on_connect = on_connect
    mqtt_client.connect_async(MQTT_BROKER, MQTT_PORT, 60)
    mqtt_client.loop_start()


async def listen_pg_and_publish():
    conn = None  # This will hold the database connection
    try:
        while True:
            try:
                if conn is None or conn.closed:
                    # Establish a new database connection
                    conn = await aiopg.connect(dsn=DB_DSN)
                    async with conn.cursor() as cur:
                        await cur.execute("LISTEN audit_notifications;")
                        logger.info("Connected to PostgreSQL and listening for notifications.")

                # Wait for notifications with a timeout
                notify = await asyncio.wait_for(conn.notifies.get(), timeout=30)
                while notify:
                    logger.debug(f"Got NOTIFY: {notify.payload}")
                    parsed_notification = parse_notification(notify.payload)
                    mqtt_client.publish(MQTT_TOPIC, json.dumps(parsed_notification))
                    notify = await conn.notifies.get() if not conn.notifies.empty() else None
            except asyncio.TimeoutError:
                # Timeout occurred, no notifications within the timeout period
                logger.debug("No new notifications within the last 30 seconds.")
                # Here you can also check if the MQTT connection is still alive
                if mqtt_client.is_connected() == False:
                    logger.warning("MQTT connection lost. Attempting to reconnect...")
                    setup_mqtt_client()
            except Exception as e:
                logger.error(f"An error occurred: {e}")
                await asyncio.sleep(10)  # Backoff before retrying connection
    finally:
        if conn:
            await conn.close()


def parse_notification(notification_str):
    parts = notification_str.split(':')
    if len(parts) == 3:
        return {
            'table': parts[0],
            'operation': parts[1],
            'ID': int(parts[2])
        }
    else:
        return {}


async def health_handler(request):
    return web.Response(text="Service is alive")


async def start_background_tasks(app):
    app['pg_listener'] = asyncio.create_task(listen_pg_and_publish())


async def cleanup_background_tasks(app):
    if 'pg_listener' in app:
        app['pg_listener'].cancel()
        await app['pg_listener']


async def init_app():
    app = web.Application()
    app.add_routes([web.get('/health', health_handler)])
    app.on_startup.append(start_background_tasks)
    app.on_cleanup.append(cleanup_background_tasks)
    return app


if __name__ == "__main__":
    logger.info("Setting up MQTT client...")
    setup_mqtt_client()
    logger.info("Starting web server...")
    web.run_app(init_app(), host='0.0.0.0', port=8080)
