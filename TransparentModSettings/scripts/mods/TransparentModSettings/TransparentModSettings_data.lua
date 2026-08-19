local mod = get_mod("TransparentModSettings")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "general_settings",
                type = "group",
                tab = mod:localize("tab_general"),
                sub_widgets = {
                    {
                        setting_id = "background_opacity",
                        type = "numeric",
                        default_value = 50,
                        range = { 0, 100 },
                        decimals_number = 0,
                        unit_text = "percent",
                    },
                    {
                        setting_id = "background_icon_opacity",
                        type = "numeric",
                        default_value = 50,
                        range = { 0, 100 },
                        decimals_number = 0,
                        unit_text = "percent",
                    },
                    {
                        setting_id = "game_world_blur",
                        type = "numeric",
                        default_value = 0,
                        range = { 0, 100 },
                        decimals_number = 0,
                        unit_text = "percent",
                    },
                },
            },
        },
    },
}
