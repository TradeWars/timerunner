extern crate dotenv;
extern crate iron;
extern crate time;

use dotenv::dotenv;
mod queue;
mod server;

fn main() {
    dotenv().ok();

    let q = queue::setup();
    server::setup(q);
}
