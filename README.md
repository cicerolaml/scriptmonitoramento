# HelloWorld – HTTP Monitoring

## 1. Overview

This PowerShell script provides a simple HTTP availability monitor for the HelloWorld application.

The monitor periodically sends an HTTP request to the configured URL, records the HTTP status code and response message in a log file, and stops monitoring when the response is different from HTTP `200`.

The default monitoring interval is 60 seconds.

The monitoring workflow is:

```text
PowerShell Monitor
       |
       | HTTP Request
       v
http://helloworld.local
       |
       v
HTTP Response
       |
       +---- HTTP 200 ----> Log result
       |                       |
       |                       v
       |                  Wait 60 seconds
       |                       |
       |                       └──> New request
       |
       └---- HTTP != 200 ---> Log failure
                                |
                                v
                         Stop monitoring
```

---

## 2. Requirements

The script requires:

* Windows;
* PowerShell;
* Network connectivity to the monitored application;
* The HelloWorld application to be available through HTTP.

The default URL is:

```text
http://helloworld.local
```

---

## 3. Script

The monitoring script is:

```text
Monitor-HelloWorld.ps1
```

The script creates the monitoring log automatically in the same directory where the script is located.

The log file is:

```text
monitor.log
```

The path is determined dynamically using:

```powershell
$LogPath = Join-Path $PSScriptRoot "monitor.log"
```

---

## 4. Parameters

The script accepts two parameters:

| Parameter         | Description                    | Default                   |
| ----------------- | ------------------------------ | ------------------------- |
| `Url`             | URL to be monitored            | `http://helloworld.local` |
| `IntervalSeconds` | Interval between HTTP requests | `60`                      |

---

## 5. Basic Usage

To monitor the default HelloWorld URL:

```powershell
.\Monitor-HelloWorld.ps1
```

This is equivalent to:

```powershell
.\Monitor-HelloWorld.ps1 -Url "http://helloworld.local" -IntervalSeconds 60
```

---

## 6. Custom URL

A different URL can be specified:

```powershell
.\Monitor-HelloWorld.ps1 -Url "http://helloworld.local"
```

For example, to change the monitoring interval to 30 seconds:

```powershell
.\Monitor-HelloWorld.ps1 `
    -Url "http://helloworld.local" `
    -IntervalSeconds 30
```

---

## 7. Monitoring Process

The script performs an HTTP request using:

```powershell
Invoke-WebRequest
```

A timeout of 10 seconds is configured for each request:

```powershell
Invoke-WebRequest `
    -Uri $Url `
    -UseBasicParsing `
    -TimeoutSec 10
```

The response status code and status description are captured.

For a successful request, an example result is:

```text
HTTP 200 - OK
```

---

## 8. Logging

Each monitoring event is written to:

```text
monitor.log
```

The log contains a timestamp, HTTP status code, and response message.

Example:

```text
2026-08-17 10:00:00 - Monitoramento iniciado para http://helloworld.local (intervalo: 60 s)
2026-08-17 10:00:00 - HTTP 200 - OK
2026-08-17 10:01:00 - HTTP 200 - OK
2026-08-17 10:02:00 - HTTP 200 - OK
```

The timestamp format is:

```text
yyyy-MM-dd HH:mm:ss
```

---

## 9. HTTP Error Handling

The script handles two types of failures.

### HTTP Response Error

If the server responds with an HTTP error status, the script attempts to capture the returned status code and description.

For example:

```text
HTTP 500 - Internal Server Error
```

### Connection Failure

If no HTTP response is received, the script records:

```text
HTTP N/A - Falha de conexao: <error message>
```

This can occur when:

* The application is stopped;
* The IIS website is unavailable;
* The server cannot be reached;
* The DNS/hosts entry cannot be resolved;
* The connection times out.

---

## 10. Monitoring Stop Condition

The monitor expects an HTTP `200` response.

When the response is:

```text
HTTP 200
```

the script waits for the configured interval and performs another check.

If the response is different from `200`, the script records the failure:

```text
Status diferente de 200 detectado. Encerrando monitoramento.
```

The script then waits two seconds and terminates.

Example:

```text
2026-08-17 10:05:00 - HTTP 500 - Internal Server Error
2026-08-17 10:05:00 - Status diferente de 200 detectado. Encerrando monitoramento.
```

---

## 11. Monitoring Flow

The complete execution flow is:

```text
Start
  |
  v
Write monitoring start to log
  |
  v
Send HTTP request
  |
  v
Receive response
  |
  +-----------------------+
  |                       |
  v                       v
HTTP 200              HTTP != 200
  |                       |
  v                       v
Write success         Write failure
to log                to log
  |                       |
  v                       v
Wait configured       Wait 2 seconds
interval                  |
  |                       v
  |                    Stop
  |
  └────> New HTTP request
```

---

## 12. Example

To monitor the HelloWorld application every 60 seconds:

```powershell
.\Monitor-HelloWorld.ps1 `
    -Url "http://helloworld.local" `
    -IntervalSeconds 60
```

The script will continue monitoring while the application returns HTTP `200`.

If the application starts returning another status code or becomes unreachable, the monitoring process will stop.

---

## 13. Validation

The monitored application can be accessed manually through:

```text
http://helloworld.local
```

While the monitoring script is running, the `monitor.log` file can be used to verify the HTTP responses.

Example successful validation:

```text
HTTP 200 - OK
```

Example failure validation:

```text
HTTP 500 - Internal Server Error
```

The monitor should terminate after detecting the non-200 response.

---

## 14. Purpose

This project demonstrates a lightweight application health-check mechanism using PowerShell.

It demonstrates:

* HTTP availability checking;
* Configurable monitoring intervals;
* HTTP status code validation;
* Connection error handling;
* Timestamped logging;
* Automatic detection of application failures;
* Automatic termination when the expected HTTP status is not received.

The script can be used as a simple validation and monitoring component for the HelloWorld application.
