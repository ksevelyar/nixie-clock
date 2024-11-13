//! Set single PWM pin to 30kHz on Blue Pill

#![deny(unsafe_code)]
#![no_main]
#![no_std]

use cortex_m_rt::entry;
use panic_halt as _;
use stm32f1xx_hal::{
    pac,
    prelude::*,
    timer::{Channel, Tim2NoRemap},
};

#[entry]
fn main() -> ! {
    let dp = pac::Peripherals::take().unwrap();

    let mut flash = dp.FLASH.constrain();
    let rcc = dp.RCC.constrain();

    let clocks = rcc.cfgr.freeze(&mut flash.acr);

    let mut afio = dp.AFIO.constrain();
    let mut gpioa = dp.GPIOA.split();

    // Set up PA0 for PWM output
    let pa0 = gpioa.pa0.into_alternate_push_pull(&mut gpioa.crl);

    // Initialize PWM on TIM2 for 30kHz
    let mut pwm = dp.TIM2.pwm_hz::<Tim2NoRemap, _, _>(
        pa0, // Only using PA0 on Channel 1
        &mut afio.mapr,
        30.kHz(), // Set frequency to 30kHz
        &clocks,
    );

    // Enable the PWM output on Channel 1
    pwm.enable(Channel::C1);

    // Set duty cycle to 50% for demonstration
    let max_duty = pwm.get_max_duty();
    pwm.set_duty(Channel::C1, max_duty / 2);

    loop {
        // PWM signal will continue as set above
    }
}
