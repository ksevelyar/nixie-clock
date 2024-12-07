#![no_std]
#![no_main]

use esp_backtrace as _;
use esp_hal::{delay::Delay, gpio::Io, i2c::I2c, prelude::*};
use esp_println::logger::init_logger_from_env;
pub use esp_hal::entry;

#[entry]
fn main() -> ! {
    let peripherals = esp_hal::init(esp_hal::Config::default());

    init_logger_from_env();

    let delay = Delay::new();
    let io = Io::new(peripherals.GPIO, peripherals.IO_MUX);

    let mut i2c = I2c::new(
        peripherals.I2C0,
        io.pins.gpio4,    // SDA
        io.pins.gpio5,    // SCL
        100u32.kHz(),
    );

    log::info!("Starting I2C scan...");

    for addr in 0x08..=0x77 {
        let mut buffer = [0; 1];
        let res = i2c.read(addr as u8, &mut buffer); 
        match res {
            Ok(_) => log::info!("Found device at 0x{:02X}", addr),
            Err(_) => {}
        }
    }

    log::info!("I2C scan complete.");

    loop {
        delay.delay(1.secs());
    }
}
