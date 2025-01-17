//! A simple example of how to run the ESP IDF SNTP service so that it updates the current time
//! in the MCU by periodically consulting an NTP internet server

use esp_idf_svc::sntp;
use esp_idf_svc::sys::EspError;

const SSID: &str = env!("SSID");
const PASSWORD: &str = env!("PASS");

use chrono::{TimeZone, Utc};
use log::info;

fn main() -> Result<(), EspError> {
    esp_idf_svc::sys::link_patches();
    esp_idf_svc::log::EspLogger::initialize_default();

    // Keep it around or else the wifi will stop
    let _wifi = wifi_create()?;

    // Keep it around or else the SNTP service will stop
    let _sntp = sntp::EspSntp::new_default()?;
    info!("SNTP initialized");

    loop {
        if let Ok(current_time) = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH) {
            let datetime = Utc.timestamp_opt(current_time.as_secs() as i64, 0).single();
            if let Some(datetime) = datetime {
                info!("Current time: {}", datetime.format("%H:%M"));
            } else {
                info!("Failed to format time");
            }
        } else {
            info!("Failed to get current time");
        }

        std::thread::sleep(std::time::Duration::from_secs(60));
    }
}

fn wifi_create() -> Result<esp_idf_svc::wifi::EspWifi<'static>, EspError> {
    use esp_idf_svc::eventloop::*;
    use esp_idf_svc::hal::prelude::Peripherals;
    use esp_idf_svc::nvs::*;
    use esp_idf_svc::wifi::*;

    let sys_loop = EspSystemEventLoop::take()?;
    let nvs = EspDefaultNvsPartition::take()?;

    let peripherals = Peripherals::take()?;

    let mut esp_wifi = EspWifi::new(peripherals.modem, sys_loop.clone(), Some(nvs.clone()))?;
    let mut wifi = BlockingWifi::wrap(&mut esp_wifi, sys_loop.clone())?;

    wifi.set_configuration(&Configuration::Client(ClientConfiguration {
        ssid: SSID.try_into().unwrap(),
        password: PASSWORD.try_into().unwrap(),
        ..Default::default()
    }))?;

    wifi.start()?;
    info!("Wifi started");

    wifi.connect()?;
    info!("Wifi connected");

    wifi.wait_netif_up()?;
    info!("Wifi netif up");

    Ok(esp_wifi)
}
