extern crate bodyparser;
extern crate dotenv;
extern crate iron;
extern crate persistent;
extern crate time;

use dotenv::dotenv;
use iron::prelude::*;
// use iron::Plugin;
use iron::*;
// use persistent::Read;
use std::env;
use std::sync::mpsc;
use std::sync::Mutex;
use std::thread;

// const MAX_BODY_LENGTH: usize = 1024 * 1024 * 10;

fn main() {
    dotenv().ok();

    let (tx, rx) = mpsc::channel();
    let sender = Mutex::new(tx);

    thread::spawn(move || {
        for received in rx {
            println!("{}", received)
        }
    });

    let chain = Chain::new(move |req: &mut Request| -> IronResult<Response> {
        println!("received request {}", req.url);

        // let body = req.get::<bodyparser::Raw>();
        // match body {
        //     Ok(Some(body)) => println!("Read body:\n{}", body),
        //     Ok(None) => println!("No body"),
        //     Err(err) => println!("Error: {:?}", err),
        // }

        let tx = sender.lock().unwrap().clone(); //Or whatever
        tx.send("request").unwrap();

        return Ok(Response::with((status::Ok, "Hello World")));
    });
    // chain.link_before(Read::<bodyparser::MaxBodyLength>::one(MAX_BODY_LENGTH));

    match Iron::new(chain).http(env::var("BIND").unwrap()) {
        Ok(_) => println!("fine"),
        Err(error) => panic!("failed to bind HTTP listener: {:?}", error),
    }
}
