FROM --platform=${BUILDPLATFORM} public.ecr.aws/docker/library/python:3.12-slim AS builder

# Upgrade pip and install Poetry and build essentials
RUN pip install --upgrade pip && \
    apt-get update && apt-get install -y --no-install-recommends build-essential && \
    pip install --no-cache-dir poetry==2.1.3 && \
    rm -rf /var/lib/apt/lists/* /root/.cache/pip

WORKDIR /app/builder

# Copy only what’s necessary to install dependencies first
COPY pyproject.toml poetry.lock ./

# Configure and install only main dependencies
RUN poetry config virtualenvs.create false && \
    poetry config installer.max-workers 10 && \
    poetry config cache-dir /tmp/poetry-cache && \
    poetry install --only main --no-root && \
    rm -rf /tmp/poetry-cache

# Copy source code
COPY lambda_handler.py .

# Final minimal Lambda image
FROM --platform=${BUILDPLATFORM} public.ecr.aws/lambda/python:3.12

WORKDIR ${LAMBDA_TASK_ROOT}

# Copy wheels and app entrypoint
COPY --from=builder /app/builder/dist/ ./dist
COPY --from=builder /app/builder/main.py ./

# Install built wheels and clean up
RUN pip install --no-cache-dir ./dist/* -t . && \
    rm -rf dist *.whl *.tar.gz


CMD [ "main.lambda_handler" ]