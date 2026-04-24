if (CONFIG_CHEAPINO_DISPLAY_ON_LAYER)
    zephyr_library()
    zephyr_library_sources(src/display_on_layer.c)
endif()
