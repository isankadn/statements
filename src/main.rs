mod api;
mod db;
mod models;
mod services;

use dotenv::dotenv;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

#[tokio::main]
async fn main() {
    dotenv().ok();

    // Initialize logging
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env().unwrap_or_else(|_| "info".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    // Set up database connection and run migrations
    let pool = db::establish_connection();
    db::run_migrations(&mut pool.get().expect("Failed to get db connection"));

    tracing::info!("Database connected and migrations applied successfully");

    // TODO: Set up Axum app and routes
    // TODO: Start the server

    tracing::info!("Server started successfully");
}
