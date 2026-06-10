# Discord Game Info Bot

A high-performance Discord bot written in **Zig** that provides detailed game information using the RAWG API.

Users can search for any game and instantly receive information such as release date, developer, publisher, genres, platforms, ratings, logos, and screenshots.

---

## Features

### Game Search

Search any game directly from Discord.

```text
/game gta v
```

### Game Information

Displays:

* Game Name
* Release Date
* Developer
* Publisher
* Genres
* Platforms
* Ratings
* Cover Image
* Game Logo
* Screenshots

### Rich Discord Embeds

Beautiful Discord embeds containing:

* Thumbnail
* Cover Image
* Metadata Fields
* Ratings
* Screenshots

### Performance Optimized

* In-memory caching
* Reduced API requests
* Fast response times

### Error Handling

Handles:

* Game not found
* API timeouts
* Invalid requests
* Missing data

---

## Example

### Command

```text
/game cyberpunk 2077
```

### Response

```yaml
Game: Cyberpunk 2077

Release Date: 2020-12-10
Developer: CD PROJEKT RED
Publisher: CD PROJEKT
Genres: RPG, Action
Platforms: PC, PlayStation 5, Xbox Series X/S
Rating: 4.2/5
```

---

## Tech Stack

* Zig
* Discord API
* RAWG API
* SQLite
* HTTP Client
* JSON Parsing

---

## Project Structure

```text
discord-game-bot/

src/
├── main.zig

├── commands/
│   ├── game.zig
│   ├── compare.zig
│   ├── rating.zig
│   └── trending.zig

├── services/
│   ├── rawg.zig
│   ├── igdb.zig
│   ├── steam.zig
│   ├── cache.zig
│   └── discord.zig

├── database/
│   └── sqlite.zig

├── models/
│   └── game.zig

├── utils/
│   ├── logger.zig
│   ├── config.zig
│   └── rate_limiter.zig

├── assets/

├── build.zig
├── .env
└── README.md
```

---

## Installation

### Clone Repository

```bash
git clone https://github.com/nurmd/discord-game-bot.git
cd discord-game-bot
```

### Create Environment File

```env
DISCORD_TOKEN=

DISCORD_CLIENT_ID=

RAWG_API_KEY=

CACHE_TTL=86400

DATABASE_PATH=data.db

LOG_LEVEL=INFO
```

### Build

```bash
zig build
```

### Run

```bash
zig build run
```

---

## Commands

### Game Search

```text
/game <name>
```

Example:

```text
/game gta v
```

### Game Screenshots

```text
/ game-screenshots <name>
```

### Game Rating

```text
/ game-rating <name>
```

### Compare Games

```text
/ compare gta-v cyberpunk-2077
```

### Trending Games

```text
/ trending
```

---

## API Source

Powered by RAWG Video Games Database API.

Provides access to:

* 800,000+ Games
* Ratings
* Screenshots
* Genres
* Platforms
* Developers
* Publishers

---

## Roadmap

### Version 1.0

* [x] Discord Bot Foundation
* [x] Slash Commands
* [x] RAWG Integration
* [x] Rich Embeds
* [x] Caching

### Version 2.0

* [ ] IGDB Integration
* [ ] Steam Integration
* [ ] Trailer Support
* [ ] Game Comparison
* [ ] Trending Games
* [ ] Upcoming Releases

### Version 3.0

* [ ] Achievement Tracking
* [ ] Wishlist System
* [ ] Steam Price Tracking
* [ ] Multi-language Support

---

## Contributing

Pull requests are welcome.

For major changes, please open an issue first to discuss what you would like to change.

---

## License

MIT License

---

## Author

Nur Mohammad

Built with Zig and Discord API.
