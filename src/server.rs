use iron::*;
use std::env;

struct Server {
    q: ::queue::Queuer,
}

fn hello_world(_: &mut Request) -> IronResult<Response> {
    return Ok(Response::with((status::Ok, "Hello World")));
}

pub fn setup(q: ::queue::Queuer) {
    let chain = Chain::new(hello_world);
    match Iron::new(chain).http(env::var("BIND").unwrap()) {
        Ok(_) => println!("fine"),
        Err(error) => panic!("failed to bind HTTP listener: {:?}", error),
    }
}
