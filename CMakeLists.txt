# Embed into the ZMK `app` target so the source compiles with ZMK's include
# path (event_manager, layer_state_changed, etc.).
if (CONFIG_CHEAPINO_DISPLAY_ON_LAYER)
    target_sources(app PRIVATE src/display_on_layer.c)
endif()
