# BlogApp

A simple blog application built with Ruby on Rails. This app allows users to create, read, update, and delete blog posts.

## Features
- List all blog posts
- View a single post
- Create a new post
- Edit an existing post
- Delete a post

## Getting Started

### Prerequisites
- Ruby (version 3.0 or higher recommended)
- Rails (version 7 or higher recommended)
- PostgreSQL (for development and production)

### Setup
1. Clone the repository:
   ```sh
   git clone <your-repo-url>
   cd blog_app
   ```
2. Install dependencies:
   ```sh
   bundle install
   ```
3. Set up the database:
   
   Edit `config/database.yml` to configure your PostgreSQL credentials. Example:
   ```yaml
   default: &default
     adapter: postgresql
     encoding: unicode
     pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
     username: your_postgres_user
     password: your_postgres_password
     host: localhost
   development:
     <<: *default
     database: blog_app_development
   test:
     <<: *default
     database: blog_app_test
   production:
     <<: *default
     database: blog_app_production
     username: <%= ENV["POSTGRES_USER"] %>
     password: <%= ENV["POSTGRES_PASSWORD"] %>
     host: <%= ENV["POSTGRES_HOST"] %>
   ```
   
   Then run:
   ```sh
   rails db:create db:migrate
   ```
4. Start the Rails server:
   ```sh
   rails server
   ```
5. Visit `http://localhost:3000/posts` to use the blog.

## Usage
- Create, edit, and delete posts from the web interface.

## API Endpoints

You can access JSON responses from the Posts controller by appending `.json` to the URL:

- `GET /posts.json` – List all posts in JSON format
- `GET /posts/:id.json` – Show a single post in JSON format
- `POST /posts.json` – Create a new post (send JSON body)
- `PATCH /posts/:id.json` – Update a post (send JSON body)
- `DELETE /posts/:id.json` – Delete a post

Example:

```sh
curl http://localhost:3000/posts.json
```

## Project Structure
- `app/models/post.rb` - The Post model
- `app/controllers/posts_controller.rb` - Controller for blog posts
- `app/views/posts/` - Views for posts CRUD

## License
This project is open source and available under the [MIT License](LICENSE).
