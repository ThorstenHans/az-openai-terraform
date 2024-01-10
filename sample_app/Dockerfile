ARG PYTHON_VERSION=3.11.7
FROM python:${PYTHON_VERSION}-slim as base

# Labels
LABEL org.opencontainers.image.authors = "Thorsten Hans <thorsten.hans@gmail.com>"
LABEL org.opencontainers.image.source = "https://github.com/ThorstenHans/az-openai-terraform"
LABEL org.opencontainers.image.license  = "MIT"

# Prevents Python from writing pyc files.
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    bob

COPY requirements.txt .
RUN python -m pip install -r requirements.txt

# Switch to the non-privileged user to run the application.
USER bob

# Copy the source code into the container.
COPY . . 

# Expose the port that the application listens on.
EXPOSE 8000

# Run the application.
CMD gunicorn 'app:app' --timeout 120 --bind=0.0.0.0:8000
