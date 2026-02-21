use esp_idf_svc::hal::delay::{Ets, FreeRtos};
use esp_idf_svc::hal::gpio::{Level, PinDriver};
use esp_idf_svc::hal::prelude::Peripherals;
use esp_idf_svc::sntp;
use esp_idf_svc::sys::EspError;
use log::info;

use esp_idf_svc::nvs::*;
use esp_idf_svc::{eventloop::EspSystemEventLoop, hal::peripheral};

use std::time::{SystemTime, UNIX_EPOCH};

const SSID: &str = env!("SSID");
const PASSWORD: &str = env!("PASS");

fn main() -> Result<(), EspError> {
    esp_idf_svc::sys::link_patches();
    esp_idf_svc::log::EspLogger::initialize_default();

    let peripherals = Peripherals::take()?;
    let sysloop = EspSystemEventLoop::take()?;
    let _nvs = EspDefaultNvsPartition::take()?;

    let _wifi = wifi_create(SSID, PASSWORD, peripherals.modem, sysloop)?;
    // TODO: light led on error
    // let mut builtin_led = PinDriver::output(peripherals.pins.gpio8)?;
    // builtin_led.set_low()?;

    let _sntp = sntp::EspSntp::new_default()?;
    info!("SNTP initialized");

    let mut pin_a = PinDriver::output(peripherals.pins.gpio0)?;
    let mut pin_b = PinDriver::output(peripherals.pins.gpio1)?;
    let mut pin_c = PinDriver::output(peripherals.pins.gpio2)?;
    let mut pin_d = PinDriver::output(peripherals.pins.gpio3)?;

    let mut lamp0 = PinDriver::output(peripherals.pins.gpio4)?;
    let mut lamp1 = PinDriver::output(peripherals.pins.gpio5)?;
    let mut lamp2 = PinDriver::output(peripherals.pins.gpio6)?;
    let mut lamp3 = PinDriver::output(peripherals.pins.gpio7)?;

    set_all_lamps(Level::Low, &mut lamp0, &mut lamp1, &mut lamp2, &mut lamp3)?;
    display_digit(&mut pin_a, &mut pin_b, &mut pin_c, &mut pin_d, 0)?;

    let mut digits = [0u8; 4];
    let mut last_update = 0u64;

    loop {
        maybe_update_state(&mut last_update, &mut digits);

        for (i, &digit) in digits.iter().enumerate() {
            set_all_lamps(Level::Low, &mut lamp0, &mut lamp1, &mut lamp2, &mut lamp3)?;
            Ets::delay_us(500);

            display_digit(&mut pin_a, &mut pin_b, &mut pin_c, &mut pin_d, digit)?;
            select_lamp(i, &mut lamp0, &mut lamp1, &mut lamp2, &mut lamp3)?;
            Ets::delay_us(1500);

            set_all_lamps(Level::Low, &mut lamp0, &mut lamp1, &mut lamp2, &mut lamp3)?;
        }

        FreeRtos::delay_ms(1);
    }
}

fn maybe_update_state(last_update: &mut u64, digits: &mut [u8; 4]) {
    let now = SystemTime::now().duration_since(UNIX_EPOCH).unwrap();
    let seconds = now.as_secs();

    if seconds != *last_update {
        let timezone_shift = 3 * 60;
        let total_minutes = seconds / 60 + timezone_shift;
        let hours = (total_minutes / 60) % 24;
        let minutes = total_minutes % 60;

        *digits = [
            (hours / 10) as u8,
            (hours % 10) as u8,
            (minutes / 10) as u8,
            (minutes % 10) as u8,
        ];

        *last_update = seconds;
    }
}

fn set_all_lamps(
    level: Level,
    lamp0: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio4, esp_idf_svc::hal::gpio::Output>,
    lamp1: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio5, esp_idf_svc::hal::gpio::Output>,
    lamp2: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio6, esp_idf_svc::hal::gpio::Output>,
    lamp3: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio7, esp_idf_svc::hal::gpio::Output>,
) -> Result<(), EspError> {
    lamp0.set_level(level)?;
    lamp1.set_level(level)?;
    lamp2.set_level(level)?;
    lamp3.set_level(level)?;

    Ok(())
}

fn select_lamp(
    idx: usize,
    lamp0: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio4, esp_idf_svc::hal::gpio::Output>,
    lamp1: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio5, esp_idf_svc::hal::gpio::Output>,
    lamp2: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio6, esp_idf_svc::hal::gpio::Output>,
    lamp3: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio7, esp_idf_svc::hal::gpio::Output>,
) -> Result<(), EspError> {
    lamp3.set_level(if idx == 0 { Level::High } else { Level::Low })?;
    lamp2.set_level(if idx == 1 { Level::High } else { Level::Low })?;
    lamp1.set_level(if idx == 2 { Level::High } else { Level::Low })?;
    lamp0.set_level(if idx == 3 { Level::High } else { Level::Low })?;

    Ok(())
}

fn display_digit(
    a: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio0, esp_idf_svc::hal::gpio::Output>,
    b: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio1, esp_idf_svc::hal::gpio::Output>,
    c: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio2, esp_idf_svc::hal::gpio::Output>,
    d: &mut PinDriver<'_, esp_idf_svc::hal::gpio::Gpio3, esp_idf_svc::hal::gpio::Output>,
    digit: u8,
) -> Result<(), EspError> {
    let bcd = [
        digit & 0b0001 != 0,
        digit & 0b0010 != 0,
        digit & 0b0100 != 0,
        digit & 0b1000 != 0,
    ];

    a.set_level(if bcd[0] { Level::High } else { Level::Low })?;
    b.set_level(if bcd[1] { Level::High } else { Level::Low })?;
    c.set_level(if bcd[2] { Level::High } else { Level::Low })?;
    d.set_level(if bcd[3] { Level::High } else { Level::Low })?;

    Ok(())
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
