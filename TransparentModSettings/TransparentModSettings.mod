return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`TransparentModSettings` encountered an error loading the Darktide Mod Framework.")

        new_mod("TransparentModSettings", {
            mod_script       = "TransparentModSettings/scripts/mods/TransparentModSettings/TransparentModSettings",
            mod_data         = "TransparentModSettings/scripts/mods/TransparentModSettings/TransparentModSettings_data",
            mod_localization = "TransparentModSettings/scripts/mods/TransparentModSettings/TransparentModSettings_localization",
        })
    end,
    packages = {},
}
