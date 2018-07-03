use std::sync::mpsc;
use std::thread;

pub struct Queuer {
    pub tx: mpsc::Sender<String>,
}

pub fn setup() -> Queuer {
    let (tx, rx) = mpsc::channel();

    let q = Queuer { tx: tx };

    thread::spawn(move || {
        for received in rx {
            println!("{}", received)
        }
    });

    return q;
}
