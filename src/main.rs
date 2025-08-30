use esp_idf_svc::hal::gpio::{Level, PinDriver};
use esp_idf_svc::hal::prelude::Peripherals;
use esp_idf_svc::sntp;
use esp_idf_svc::sys::EspError;
use log::info;

use esp_idf_svc::{eventloop::EspSystemEventLoop, hal::peripheral};

use esp_idf_svc::nvs::*;

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

    loop {
        if let Ok(current_time) = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH)
        {
            let seconds = current_time.as_secs() % 60;
            let digit = (seconds % 10) as u8; // last digit of seconds

            info!("Seconds: {:02} -> digit {}", seconds, digit);

            display_digit(&mut pin_a, &mut pin_b, &mut pin_c, &mut pin_d, digit);
        }

        std::thread::sleep(std::time::Duration::from_secs(1));
    }
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

    a.set_level(if bcd[0] { Level::High } else { Level::Low }).unwrap();
    b.set_level(if bcd[1] { Level::High } else { Level::Low }).unwrap();
    c.set_level(if bcd[2] { Level::High } else { Level::Low }).unwrap();
    d.set_level(if bcd[3] { Level::High } else { Level::Low }).unwrap();
}

fn wifi_create(
    ssid: &str,
    pass: &str,
    modem: impl peripheral::Peripheral<P = esp_idf_svc::hal::modem::Modem> + 'static,
    sysloop: EspSystemEventLoop,
) -> Result<esp_idf_svc::wifi::EspWifi<'static>, EspError> {
    use esp_idf_svc::wifi::*;

    //let mut esp_wifi = EspWifi::new(modem, sysloop.clone(), Some(nvs.clone()))?;
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
