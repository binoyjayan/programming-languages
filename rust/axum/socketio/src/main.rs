use axum::routing::get;
use serde_json::Value;
use socketioxide::{
    extract::{AckSender, Bin, Data, SocketRef},
    SocketIo,
};
use tracing::info;

fn on_connect(socket: SocketRef, Data(data): Data<Value>) {
    info!("Socket.IO connected: {:?} {:?}", socket.ns(), socket.id);
    socket.emit("auth", data).ok();

    socket.on(
        "message",
        |socket: SocketRef, Data::<Value>(data), Bin(bin)| {
            info!("Received event: {:?} {:?}", data, bin);
            socket.emit("response", "Hey").ok();
        },
    );

    socket.on(
        "message-with-ack",
        |Data::<Value>(data), ack: AckSender, Bin(bin)| {
            info!("Received event [with-ack]: {:?} {:?}", data, bin);
            ack.bin(bin).send(data).ok();
        },
    );
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    tracing_subscriber::fmt().without_time().init();

    let (layer, io) = SocketIo::new_layer();

    io.ns("/", on_connect);
    io.ns("/custom", on_connect);

    let app = axum::Router::new()
        .route("/", get(|| async { "Hello, World!" }))
        .layer(layer);

    info!("Starting server");

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await.unwrap();
    axum::serve(listener, app).await.unwrap();

    Ok(())
}

// npm i -g socket.io-cli

//
// $ socketio ws://localhost:3000
// Connected to ws://localhost:3000
// auth [{}]
// # message Hello
// message-back ["Hello"]
// # message-with-ack Heyyy

// Logs
// INFO socketio_test: Starting server
// INFO socketio_test: Socket.IO connected: "/" RF0S0WyUDGObCRKS
// INFO socketio_test: Received event: String("Hello") []
// INFO socketio_test: Received event [with-ack]: String("Heyyy") []
