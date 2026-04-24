/*
 * Cheapino - layer-gated display blanking.
 *
 * Keeps the OLED blanked at boot. Switches on display power when the
 * configured layer (default EXTRA = 7) becomes active. Scheduled re-blank
 * after the layer goes inactive, delay = CHEAPINO_DISPLAY_OFF_DELAY_MS.
 */

#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/drivers/display.h>
#include <zephyr/init.h>
#include <zephyr/logging/log.h>

#include <zmk/event_manager.h>
#include <zmk/events/layer_state_changed.h>

LOG_MODULE_REGISTER(cheapino_display_on_layer, CONFIG_ZMK_LOG_LEVEL);

static const struct device *display_dev;
static struct k_work_delayable blank_work;

#define WAKE_LAYER  CONFIG_CHEAPINO_DISPLAY_ON_LAYER_NUM
#define BLANK_DELAY K_MSEC(CONFIG_CHEAPINO_DISPLAY_OFF_DELAY_MS)

static void blank_display_handler(struct k_work *work) {
    ARG_UNUSED(work);
    if (display_dev && device_is_ready(display_dev)) {
        display_blanking_on(display_dev);
    }
}

static int layer_state_listener(const zmk_event_t *eh) {
    const struct zmk_layer_state_changed *ev = as_zmk_layer_state_changed(eh);
    if (!ev || ev->layer != WAKE_LAYER) {
        return ZMK_EV_EVENT_BUBBLE;
    }

    if (!display_dev || !device_is_ready(display_dev)) {
        return ZMK_EV_EVENT_BUBBLE;
    }

    if (ev->state) {
        k_work_cancel_delayable(&blank_work);
        display_blanking_off(display_dev);
    } else {
        k_work_schedule(&blank_work, BLANK_DELAY);
    }
    return ZMK_EV_EVENT_BUBBLE;
}

ZMK_LISTENER(cheapino_display_on_layer, layer_state_listener);
ZMK_SUBSCRIPTION(cheapino_display_on_layer, zmk_layer_state_changed);

static int cheapino_display_on_layer_init(void) {
    display_dev = DEVICE_DT_GET(DT_CHOSEN(zephyr_display));
    k_work_init_delayable(&blank_work, blank_display_handler);

    if (display_dev && device_is_ready(display_dev)) {
        display_blanking_on(display_dev);
    }
    return 0;
}

SYS_INIT(cheapino_display_on_layer_init, APPLICATION, CONFIG_APPLICATION_INIT_PRIORITY);
