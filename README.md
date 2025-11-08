# Personal Website


This repository contains a personal website built with Erlang/OTP. It provides a lightweight platform for serving a personal page, including sections such as **About**, **Projects**, **Consultations**, and a **Blog**.

## Technologies Used

- **Erlang/OTP** — for building a robust, concurrent backend.
- **Cowboy** — lightweight HTTP server.
- **ErlyDTL** — templating engine for rendering HTML pages.
- **Mnesia** — database for persistent storage of blog posts.
- **ETS** — in-memory caching for fast page access.
- **OrthoCSS** ([GitHub](https://github.com/byBenPuls/orthocss)) — for clean, semantic, and maintainable CSS styling.

## Features

- Dynamic blog with post creation, editing, and deletion.
- Persistent and fast-access storage of page and blog data.
- JSON-based API endpoints for managing blog content.
- API token-based authentication for protected actions with security-conscious implementation.
- Modular architecture separating data storage, page rendering, and HTTP handling.


## Why Use This

This project is ideal for anyone who wants a **fast, modular, and maintainable personal website** entirely in Erlang.
It demonstrates a clean separation of concerns, modern HTML/CSS practices through OrthoCSS, and the ability to manage dynamic content without heavy frameworks.
Perfect for personal websites, small blogs, or simple content platforms.
