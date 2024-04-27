# Use an official Python runtime as a parent image
FROM python:3.12.3-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Create a user and group
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Ensure the user owns the application files
COPY --chown=appuser:appgroup . .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Use an unprivileged user to run the application
USER appuser

# General Environment Settings | DEBUG, INFO, WARNING, ERROR, or CRITICAL
ENV LOG_LEVEL=INFO

# Run app.py when the container launches
CMD ["python", "app.py"]
