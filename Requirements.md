# USU Engineering Ambassadors Arcade Machine - Requirements & Development Plan

## Project Overview
A self-contained arcade machine system that runs EmulationStation-DE in Docker, supporting multiple game types (GBA ROMs, Godot executables) with custom controller input mapping and auto-boot functionality.

## User Profiles

### Primary User: Event Attendees
- Non-technical users at recruiting/demo events
- Expects plug-and-play experience
- Uses only arcade controls (no keyboard/mouse access)
- Interacts with launcher and games

### Secondary User: System Administrators
- USU Engineering Ambassadors with basic technical knowledge
- Deploys and maintains arcade machine
- Updates games via GitHub pulls
- Requires keyboard access for configuration/troubleshooting

## System Architecture

### Host System (Ubuntu)
- Auto-login on boot (no user authentication)
- Systemd service launches Docker container at startup
- X11 display server for GUI forwarding
- Docker installed

### Docker Container
- EmulationStation-DE (game launcher frontend)
- mGBA emulator (for GBA games)
- Godot runtime (for executable games)
- XInput-to-keyboard input mapper
- Game files mounted via volumes

## Core Requirements

### 1. Portability
- Entire system runs in Docker
- Container works on any Docker-capable system
- All dependencies bundled in container image

### 2. Fast Setup & Offline Operation
- Initial build downloads and caches all dependencies
- Games pulled from GitHub on first run or update
- Subsequent boots work without internet
- Fast startup time (<30 seconds to launcher)

### 3. Input Handling (Inside Docker)
- Map XInput devices to keyboard inputs
- **2 Joysticks**: Left → WASD, Right → Arrow keys
- **11 Buttons**: G, Y, J, H, F1, ESC, 1, 2, 3, 4, F12
- **F12**: Force quit current game, return to launcher
- **Hidden button** (not on arcade controls): Exit Docker container

### 4. Game Management
- JSON/config file defines available games
- Games organized by:
  - Type (GBA ROMs, Godot executables, future types)
  - Recency (newest first within each type)
- Pulls game files from GitHub repositories
- Stores game metadata and artwork
- Manual config updates for new games

### 5. Game Launcher (EmulationStation-DE)
- Controller-navigable interface
- Displays games sorted by type and recency
- Shows game artwork/metadata
- Launches appropriate emulator/runtime per game type
- Fullscreen operation
- Custom theme for arcade aesthetic

### 6. Emulator/Runtime Support
- **mGBA**: For GBA ROM files
- **Godot Runtime**: For Godot executable games
- Extensible architecture for adding new emulators

### 7. Force Quit Mechanism
- **F12** (mapped arcade button): Kill game process, return to ES-DE
- **Unmapped key** (requires keyboard): Exit entire Docker container

## Development Phases

### Phase 1: Docker Foundation
- Expand Dockerfile to include EmulationStation-DE
- Add Godot runtime support
- Configure volume mounts for games/configs
- Test basic Docker run with display forwarding

### Phase 2: Input Mapping
- Integrate XInput-to-keyboard mapper (xboxdrv or similar)
- Configure controller button mappings
- Test input in ES-DE and emulators
- Implement force-quit hotkeys

### Phase 3: Game Management System
- Design JSON game configuration schema
- Create script to pull games from GitHub
- Configure ES-DE systems.xml for game types
- Add sample games for testing

### Phase 4: EmulationStation-DE Configuration
- Configure game collections (GBA, Godot, etc.)
- Set up game sorting (type, then recency)
- Apply/customize arcade theme
- Configure metadata scraping

### Phase 5: Host System Auto-Boot
- Create systemd service for Docker launch
- Configure Ubuntu auto-login
- Set up X11 display permissions
- Test full boot-to-game workflow

### Phase 6: Polish & Documentation
- Optimize container size and startup time
- Add game artwork and metadata
- Document game addition process
- Create deployment guide for administrators

## Technical Specifications (High-Level)

### Container Components
- Base: Ubuntu 24.04
- Frontend: EmulationStation-DE
- Emulators: mGBA (existing), others as needed
- Input: xboxdrv or antimicrox for controller mapping
- Display: X11 forwarding from host

### File Structure
```
/host-system/arcade-data/
├── games/
│   ├── gba/
│   └── godot/
├── config/
│   ├── games.json
│   └── es-settings/
└── artwork/
```

### Game Configuration Schema (games.json)
```json
{
  "games": [
    {
      "name": "Game Title",
      "type": "gba|godot|other",
      "path": "relative/path/to/file",
      "github_repo": "org/repo",
      "added_date": "2026-01-15",
      "description": "..."
    }
  ]
}
```

### Docker Run Command (Simplified)
```bash
docker run --rm \
  --device /dev/input \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /host-system/arcade-data:/data \
  usu-arcade:latest
```

## Success Criteria
- ✓ Boots automatically to launcher without user intervention
- ✓ Responds to all arcade controls correctly
- ✓ Launches and plays games from all supported types
- ✓ F12 returns to launcher from any game
- ✓ Container can be exited with keyboard for maintenance
- ✓ Works offline after initial setup
- ✓ Easy to add new games via config file update
