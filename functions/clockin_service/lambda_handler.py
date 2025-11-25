import os
import json
import time
import boto3
import random
import logging
import requests
from datetime import datetime
from pydantic import BaseModel
from typing import Any

logger = logging.getLogger(__name__)
logger.setLevel(os.getenv("LOGGING_LEVEL", "INFO"))

SECRET_ARN = os.environ.get("SECRET_ARN")
OPERATION_DELAY = os.environ.get("OPERATION_DELAY")


class AutomationError(Exception):
    """Base class for all custom automation errors."""

    pass


class AuthTokenError(AutomationError):
    """Raised when login succeeds but the token is mssing, or token fails."""

    pass


class ConfigurationError(AutomationError):
    """Raised if critical environment variable are missing, or retrieval fails."""

    pass


class APIRequestError(AutomationError):
    """Raised for general HTTP request failures."""

    def __init__(
        self,
        url: str,
        status_code: int,
        response_text: str,
        message: str = "API request failed",
    ):
        self.url = url
        self.status_code = status_code
        self.response_text = response_text
        self.message = (
            f"{message}: {url} returned {status_code} - {response_text[:100]}..."
        )
        super().__init__(self.message)


class AppConfig(BaseModel):
    """Secure configuration data retrieved from AWS Secrets Manager."""

    API_LOGIN_URL: str
    API_CLOCKIN_URL: str
    USERNAME: str
    PASSWORD: str
    SUCURSAL: str


class EventDetail(BaseModel):
    """Schema for the EventBridge 'detail' object."""

    operation: str  # Must be "clock_in" or "clock_out"


class EventPayload(BaseModel):
    """Schema for incoming EventBridge event."""

    detail: EventDetail


secretsmanager_client = boto3.client("secretsmanager")


def get_secrets(secret_arn: str):
    logger.info("Retrieving secret from ARN: %s", secret_arn)
    try:
        response = secretsmanager_client.get_secret_value(SecretId=secret_arn)
        config_data = json.loads(response["SecretString"])
        return AppConfig(**config_data)

    except Exception as e:
        raise ConfigurationError(f"Failed to retrieve or parse secret: {e}") from e


def random_delay(max_seconds: int) -> None:
    delay = random.randint(0, max_seconds)
    logger.info("Applying random delay of %s seconds", delay)
    time.sleep(delay)


def login_request(config: AppConfig):
    """Login process to get the authentication token."""
    try:
        payload = {
            "username": config.USERNAME,
            "password": config.PASSWORD,
            "company": False,
            "identifier": False,
            "zendesk_params": {},
        }

        response = requests.post(config.API_LOGIN_URL, json=payload, timeout=15)
        response.raise_for_status()

        login_data = response.json()
        auth_token = login_data.get("token")

        if auth_token:
            return auth_token
        else:
            msg = f"Login response received (200 OK), but token key not found. Response: {login_data}"
            raise AuthTokenError(msg)

    except requests.exceptions.HTTPError as e:
        raise APIRequestError(
            url=config.API_LOGIN_URL,
            status_code=e.response.status_code,
            response_text=e.response.text,
            message="Login API returned an HTTP error",
        ) from e


def clock_action(config: AppConfig, auth_token: str, operation: str):
    """Performs the clock-in/out operation."""
    if operation == "clock_in":
        direction = "E"
    elif operation == "clock_out":
        direction = "X"
    else:
        msg = f"Invalid operation specified: {operation}"
        logger.error(msg)
        raise AutomationError(msg)

    try:
        headers = {
            "Authorization": f"Token {auth_token}",
            "Content-Type": "application/json",
        }
        payload = {
            "coordenadas": {"lat": 0, "lng": 0},
            "direction": direction,
            "TS": datetime.now().isoformat(),
            "manufacturer": "",
            "model": "",
            "photo": "",
            "sucursal": config.SUCURSAL,
            "uuid": "",
            "dispositivo": "Portal del trabajador",
            "sourceMark": "desktop",
        }

        response = requests.post(config.API_CLOCKIN_URL, json=payload, headers=headers, timeout=15)
        response.raise_for_status()

        logger.info(f"Response: {response.text}")

    except requests.exceptions.HTTPError as e:
        raise APIRequestError(
            url=config.API_CLOCKIN_URL,
            status_code=e.response.status_code,
            response_text=e.response.text,
            message=f"The {operation} operation API returned an HTTP error",
        ) from e
    except requests.exceptions.RequestException as e:
        msg = (
            f"{operation.capitalize()} failed due to connectivity or timeout error: {e}"
        )
        raise AutomationError(msg)


def lambda_handler(
    event: dict[str, Any],
    context: Any,
) -> dict[str, Any]:
    """Main entry point for the Lambda function."""
    try:
        secret_arn = SECRET_ARN
        if not secret_arn:
            raise ConfigurationError(
                "FATAL: Environment variable SECRET_ARN is missing."
            )

        app_config = get_secrets(secret_arn)

    except ConfigurationError as e:
        logger.error("FATAL CONFIGURATION/SECRETS ERROR: %s", str(e))
        return {"statusCode": 500, "body": f"Configuration error: {e}"}

    operation = "unknown"
    try:
        validate_event = EventPayload(**event)
        operation = validate_event.detail.operation

        logger.info("Starting scheduled operation: %s", operation)

        random_delay(OPERATION_DELAY)

        logger.info("Resuming %s after a delay of %s seconds", operation, OPERATION_DELAY)
        auth_token = login_request(app_config)
        clock_action(app_config, auth_token, operation)

        msg = f"Successfully completed operation: {operation}"
        logger.info(msg)
        return {"statusCode": 200, "body": msg}

    except (
        AuthTokenError,
        APIRequestError,
        AutomationError,
        ValueError,
        TypeError,
    ) as e:
        logger.error("FATAL EXECUTION ERROR for operation %s: %s", operation, e)
        return {
            "statusCode": 500,
            "body": f"Failed to perform {operation}. Error: {type(e).__name__} - {str(e)}",
        }
