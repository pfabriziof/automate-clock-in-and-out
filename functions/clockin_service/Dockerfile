# Dockerfile
FROM --platform=linux/amd64 public.ecr.aws/docker/library/python:3.12-slim AS builder

# Upgrade pip and install Poetry and build essentials
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir poetry==2.1.3

WORKDIR /app/builder

# Copy only what's necessary to install dependencies first
COPY pyproject.toml poetry.lock ./

# Configure and install only main dependencies to a target directory
RUN poetry config virtualenvs.create false && \
    poetry config installer.max-workers 10 && \
    poetry config cache-dir /tmp/poetry-cache && \
    poetry install --only main --no-root && \
    rm -rf /tmp/poetry-cache

# Final minimal Lambda image
FROM --platform=linux/amd64 public.ecr.aws/lambda/python:3.12

WORKDIR ${LAMBDA_TASK_ROOT}

# Copy installed packages from builder stage
# Python packages are installed in /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/lib/python3.12/site-packages/ /var/lang/lib/python3.12/site-packages/
# COPY --from=builder /app/builder/main.py ./

# Copy source code
COPY main.py ${LAMBDA_TASK_ROOT}

CMD [ "main.lambda_handler" ]