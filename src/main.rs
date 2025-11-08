use esp_idf_svc::hal::gpio::{Level, PinDriver};
use esp_idf_svc::hal::prelude::Peripherals;
use esp_idf_svc::sntp;
use esp_idf_svc::sys::EspError;
use log::info;

use esp_idf_svc::nvs::*;
use esp_idf_svc::{eventloop::EspSystemEventLoop, hal::peripheral};

use std::time::{Duration, SystemTime, UNIX_EPOCH};

const SSID: &str = env!("SSID");
const PASSWORD: &str = env!("PASS");

fn main() -> Result<(), EspError> {
    esp_idf_svc::sys::link_patches();
    esp_idf_svc::log::EspLogger::initialize_default();

    let peripherals = Peripherals::take()?;
    let sysloop = EspSystemEventLoop::take()?;
    let _nvs = EspDefaultNvsPartition::take()?;

    let _wifi = wifi_create(SSID, PASSWORD, peripherals.modem, sysloop)?;
    let mut builtin_led = PinDriver::output(peripherals.pins.gpio8)?;
    builtin_led.set_low()?;

    let _sntp = sntp::EspSntp::new_default()?;
    info!("SNTP initialized");

    let mut pin_a = PinDriver::output(peripherals.pins.gpio0)?;
    let mut pin_b = PinDriver::output(peripherals.pins.gpio1)?;
    let mut pin_c = PinDriver::output(peripherals.pins.gpio2)?;
    let mut pin_d = PinDriver::output(peripherals.pins.gpio3)?;

    let mut lamp4 = PinDriver::output(peripherals.pins.gpio4)?;
    let mut lamp5 = PinDriver::output(peripherals.pins.gpio5)?;
    let mut lamp6 = PinDriver::output(peripherals.pins.gpio6)?;
    let mut lamp7 = PinDriver::output(peripherals.pins.gpio7)?;

    let mut last_digits = [0u8; 4];
    let mut last_update = 0u64;

    loop {
        let now = SystemTime::now().duration_since(UNIX_EPOCH).unwrap();
        let seconds = now.as_secs();

        if seconds != last_update {
            let total_minutes = seconds / 60;
            let hours = (total_minutes / 60) % 24;
            let minutes = total_minutes % 60;

            last_digits = [
                (hours / 10) as u8,
                (hours % 10) as u8,
                (minutes / 10) as u8,
                (minutes % 10) as u8,
            ];

            last_update = seconds;
        }

        for (i, &digit) in last_digits.iter().enumerate() {
            select_lamp(i, &mut lamp4, &mut lamp5, &mut lamp6, &mut lamp7);
            display_digit(&mut pin_a, &mut pin_b, &mut pin_c, &mut pin_d, digit);
            std::thread::sleep(Duration::from_millis(2));
        }
    }
}

fn select_lamp(
    idx: usize,
    lamp4: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio4, esp_idf_svc::hal::gpio::Output>,
    lamp5: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio5, esp_idf_svc::hal::gpio::Output>,
    lamp6: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio6, esp_idf_svc::hal::gpio::Output>,
    lamp7: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio7, esp_idf_svc::hal::gpio::Output>,
) {
    lamp4
        .set_level(if idx == 0 { Level::High } else { Level::Low })
        .unwrap();
    lamp5
        .set_level(if idx == 1 { Level::High } else { Level::Low })
        .unwrap();
    lamp6
        .set_level(if idx == 2 { Level::High } else { Level::Low })
        .unwrap();
    lamp7
        .set_level(if idx == 3 { Level::High } else { Level::Low })
        .unwrap();
}

fn display_digit(
    a: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio0, esp_idf_svc::hal::gpio::Output>,
    b: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio1, esp_idf_svc::hal::gpio::Output>,
    c: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio2, esp_idf_svc::hal::gpio::Output>,
    d: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio3, esp_idf_svc::hal::gpio::Output>,
    digit: u8,
) {
    let bcd = [
        digit & 0b0001 != 0,
        digit & 0b0010 != 0,
        digit & 0b0100 != 0,
        digit & 0b1000 != 0,
    ];

    a.set_level(if bcd[0] { Level::High } else { Level::Low })
        .unwrap();
    b.set_level(if bcd[1] { Level::High } else { Level::Low })
        .unwrap();
    c.set_level(if bcd[2] { Level::High } else { Level::Low })
        .unwrap();
    d.set_level(if bcd[3] { Level::High } else { Level::Low })
        .unwrap();
}

fn wifi_create(
    ssid: &str,
    pass: &str,
    modem: impl peripheral::Peripheral<P = esp_idf_svc::hal::modem::Modem> + 'static,
    sysloop: EspSystemEventLoop,
) -> Result<esp_idf_svc::wifi::EspWifi<'static>, EspError> {
    use esp_idf_svc::wifi::*;

    let mut esp_wifi = EspWifi::new(modem, sysloop.clone(), None)?;
    let mut wifi = BlockingWifi::wrap(&mut esp_wifi, sysloop.clone())?;

    wifi.set_configuration(&Configuration::Client(ClientConfiguration {
        ssid: ssid.try_into().unwrap(),
        password: pass.try_into().unwrap(),
        ..Default::default()
    }))?;

    wifi.start()?;
    info!("Wifi started");

    wifi.connect()?;
    info!("Wifi connected");

    wifi.wait_netif_up()?;
    let ip_info = wifi.wifi().sta_netif().get_ip_info()?;
    info!("Wifi DHCP info: {:?}", ip_info);

    Ok(esp_wifi)
}
