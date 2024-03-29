use crate::{web, Error, Result};
use axum::{routing::post, Json, Router};
use serde::Deserialize;
use serde_json::json;
use serde_json::Value;
use tower_cookies::{Cookie, Cookies};

#[derive(Debug, Deserialize)]
struct LoginPayload {
    username: String,
    password: String,
}

pub fn routes() -> Router {
    Router::new().route("/api/login", post(api_login))
}

async fn api_login(cookies: Cookies, payload: Json<LoginPayload>) -> Result<Json<Value>> {
    println!("-->> {:<12} - api_login", "HANDLER");
    if payload.username != "admin" || payload.password != "admin" {
        return Err(Error::LoginFail);
    }

    cookies.add(Cookie::new(web::AUTH_TOKEN, "user-1.exp.signature"));
    let body = Json(json!({"status": "success"}));
    Ok(body)
}
