#![no_std]
#![no_main]

use esp_backtrace as _;
pub use esp_hal::entry;
use esp_hal::{delay::Delay, gpio::Io, i2c::I2c, prelude::*};
use esp_println::logger::init_logger_from_env;
use rda5807m::{Address, Rda5708m};

#[entry]
fn main() -> ! {
    // Initialize peripherals and logger
    let peripherals = esp_hal::init(esp_hal::Config::default());
    init_logger_from_env();

    // Initialize delay and GPIO
    let mut delay = Delay::new();
    let io = Io::new(peripherals.GPIO, peripherals.IO_MUX);

    // Set up I2C communication
    let mut i2c = I2c::new(
        peripherals.I2C0,
        io.pins.gpio4, // SDA
        io.pins.gpio5, // SCL
        100u32.kHz(),
    );

    log::info!("Initializing radio...");

    // Initialize RDA5807M
    let mut rda5807m = Rda5708m::new(i2c, Address::default());

    // Start RDA5807M (which will also enable RDS)
    match rda5807m.start() {
        Ok(_) => log::info!("Start RDA5807M success!"),
        Err(e) => log::error!("Start RDA5807M error: {:?}", e),
    }

    // Seek up in a loop
    loop {
        // Perform seek up operation
        //match rda5807m.seek_up(true) {
        match rda5807m.seek_up(true) {
            Ok(_) => {
                // Wait a bit before checking the status
                delay.delay(500.millis());

                // Loop to check for STC (seek complete) status
                loop {
                    let status = rda5807m.get_status().unwrap_or(Default::default());
                    let freq = rda5807m.get_frequency().unwrap_or(Default::default());
                    let rssi = rda5807m.get_rssi().unwrap_or(Default::default());

                    // If seek is complete, break out of the inner loop

                    if status.stc {
                        if status.rdsr {
                            log::info!("Current status: {:?}", status);

                            match rda5807m.get_rds_time() {
                                Ok((hour, minute, offset)) => {
                                    log::info!(
                                        "Adjusted RDS Time: {:02}:{:02}, offset {}",
                                        hour,
                                        minute,
                                        offset
                                    );
                                }
                                Err(e) => {
                                    log::error!("Failed to get RDS time: {:?}", e);
                                }
                            }

                            // Get the station name

                            // Log the current frequency and RSSI
                            log::info!("Current frequency: {} Hz", freq);
                            log::info!("Current RSSI: {}", rssi);
                        }

                        break;
                    }

                    // Add a delay before checking again
                    delay.delay(40.millis());
                }
            }
            Err(e) => {
                log::error!("Seek up error: {:?}", e);
            }
        }

        // Add a delay before performing another seek
        delay.delay(1.secs()); // Adjust delay as needed
    }
}
