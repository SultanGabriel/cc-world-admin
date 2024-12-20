
#### Project Structure

```bash
libs/ # <-- External libraries like Basalt
src/
    common/ # <-- Common utilities and components
        utils/ # <-- Networking, parsing, configuration handling, logging, etc.
        components/ # <-- Shared Basalt UI components like buttons, tables, input fields
        models/ # <-- Data models shared across server and node (e.g., energy data, unit config)
        protocols/ # <-- Shared communication protocols (e.g., request/response definitions)
    server/ # <-- Server-side logic
        main.lua # <-- Entry point for the server
        controllers/ # <-- Controllers for managing energy, units, and configurations
        ui/ # <-- Basalt UI for the server (General, Energy, Units tabs)
        storage/ # <-- Data storage handling (e.g., in-memory or persistent storage)
        config/ # <-- Configuration management (e.g., data retention intervals)
    node/ # <-- Worker node logic
        main.lua # <-- Entry point for the node
        modules/
            energy_monitor/ # <-- Energy monitoring logic
                monitor.lua
                config.lua # <-- Configuration for energy monitoring
            unit_monitor/ # <-- Unit monitoring logic
                monitor.lua
                config.lua # <-- Configuration for unit monitoring
        setup/ # <-- Device setup interface for first-time configuration
        config/ # <-- Configuration management (e.g., server address, node ID)
    tests/ # <-- Test scripts for server and nodes
README.md
```

#### Key Components

##### 1. Server
The server acts as the central control system, providing a robust backend to manage and visualize world data.

###### Responsibilities:
 - Energy Monitoring:
    Collects and aggregates data from energy monitors (input, output, capacity, stored energy).
    Stores data for a configurable number of days.
 - Unit Monitoring:
    Tracks the operational state of connected units.
    Provides manual and automatic control (e.g., turning units on/off based on thresholds).

###### UI:
Built using Basalt with tabs for:
General: Overview of all connected nodes.
Energy: Energy statistics (e.g., graphs, current levels, warnings for over/underflow).
Units: Status and controls for factory units (e.g., toggle buttons, live statuses). Card like design with status, and other information about the node and up to 4 buttons that can be configured. The on/off button is one of them, which is always there by default, in the worker setup the color of the redstone signal is defined by the user, but it is a requirement for some. 

Provides a UI for general server settings.

##### 2. Worker Nodes
Worker nodes handle modular tasks, each designed for a specific purpose.

###### Responsibilities:
 - Registration with Server:
    Nodes register and communicate with the server using a defined protocol.
    Unique identifiers (node IDs) are assigned.
 - Energy Monitor Mode:
    - Tracks and reports:
        Input/output rates.
        Current storage and capacity.
        Redstone outputs based on current storage, 

 - Unit Monitor Mode:
    Interfaces with factory units to monitor and control their operation.
    Supports redstone inputs to detect the unit's state.
    Supports configurable redstone outputs, one of them being on / off and other user choices, this will differ between applications so these have to be definable
    Configurable for both automatic and manual control.


#### Setup Interface:
Both the server and worker node should have a setup mode that starts if there is no configuration on the computer (new install) or when the user whishes to change the configuration. This screen should handle defining worker nodes including it's name (which will end up shown on the control panel of the server, the units page), what mode it is running on and by that what other information is required.

