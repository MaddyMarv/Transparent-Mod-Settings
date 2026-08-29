local mod = get_mod("TransparentModSettings")
if not mod then return end

local math_floor = math.floor
local DEFAULT_RECT_ALPHA = 255
local DEFAULT_TEXTURE_ALPHA = 204
local DEFAULT_ICON_ALPHA = 80
local DEFAULT_GAME_WORLD_BLUR = 1.1

local function is_in_game()
    return rawget(_G, "Managers") and Managers.state and Managers.state.game_mode ~= nil
end

local function get_alpha_values()
    local is_enabled = mod:is_enabled()
    local in_game = is_in_game()
    local bg_opacity_pct = (is_enabled and in_game) and (mod:get("background_opacity") or 50) or 100
    local icon_opacity_pct = (is_enabled and in_game) and (mod:get("background_icon_opacity") or 50) or 100
    local blur_pct = (is_enabled and in_game) and (mod:get("game_world_blur") or 0) or 100

    local bg_factor = bg_opacity_pct / 100
    local icon_factor = icon_opacity_pct / 100
    local blur_factor = blur_pct / 100

    local rect_alpha = math_floor(DEFAULT_RECT_ALPHA * bg_factor + 0.5)
    local texture_alpha = math_floor(DEFAULT_TEXTURE_ALPHA * bg_factor + 0.5)
    local icon_alpha = math_floor(DEFAULT_ICON_ALPHA * icon_factor + 0.5)

    return rect_alpha, texture_alpha, icon_alpha, blur_factor
end

local function apply_transparency(view)
    if not view or not view._widgets_by_name then
        return
    end

    local rect_alpha, texture_alpha, icon_alpha, blur_factor = get_alpha_values()

    local bg = view._widgets_by_name.background
    if bg and bg.style then
        if bg.style.style_id_1 and bg.style.style_id_1.color then
            bg.style.style_id_1.color[1] = rect_alpha
        end
        if bg.style.style_id_2 and bg.style.style_id_2.color then
            bg.style.style_id_2.color[1] = texture_alpha
        end
    end
    if bg and bg.passes then
        for _, pass in ipairs(bg.passes) do
            local pass_style = pass.style or (bg.style and bg.style[pass.style_id])
            if pass_style and pass_style.color then
                if pass.pass_type == "rect" then
                    pass_style.color[1] = rect_alpha
                else
                    pass_style.color[1] = texture_alpha
                end
            end
        end
    end

    local icon = view._widgets_by_name.background_icon
    if icon and icon.style and icon.style.style_id_1 and icon.style.style_id_1.color then
        icon.style.style_id_1.color[1] = icon_alpha
    end
    if icon and icon.passes then
        for _, pass in ipairs(icon.passes) do
            local pass_style = pass.style or (icon.style and icon.style[pass.style_id])
            if pass_style and pass_style.color then
                pass_style.color[1] = icon_alpha
            end
        end
    end

    local ui_manager = rawget(_G, "Managers") and Managers.ui
    local view_handler = ui_manager and ui_manager._view_handler
    if view_handler then
        local target_blur = DEFAULT_GAME_WORLD_BLUR * blur_factor
        if view_handler._views and view_handler._views.dmf_options_view then
            view_handler._views.dmf_options_view.game_world_blur = target_blur
        end
        if view_handler._active_views_data and view_handler._active_views_data.dmf_options_view then
            local active_data = view_handler._active_views_data.dmf_options_view
            active_data.game_world_blur = target_blur
            if target_blur <= 0 then
                view_handler:_set_game_world_blur(false)
            else
                view_handler:_set_game_world_blur(true, target_blur)
            end
        end
    end
end

function mod.update(dt)
    local ui_manager = rawget(_G, "Managers") and Managers.ui
    if ui_manager and ui_manager.view_active and ui_manager:view_active("dmf_options_view") then
        local view = ui_manager:view_instance("dmf_options_view")
        if view then
            apply_transparency(view)
        end
    end
end

local loaded_cursors = {}

function mod.on_all_mods_loaded()
    local SimpleAssets = get_mod("SimpleAssets")
    if SimpleAssets then
        local function load_and_cache(c_id)
            local cursor_path = "mods/TransparentModSettings/" .. c_id .. "/cursor.png"
            SimpleAssets.load_mouse_cursor(cursor_path, 0, 0):next(function(result)
                if result and result.resource_name then
                    loaded_cursors[c_id] = result.resource_name
                    
                    if mod:get("custom_cursor") == c_id then
                        if rawget(_G, "Window") and Window.set_cursor then
                            Window.set_cursor(result.resource_name)
                        end
                    end
                end
            end):catch(function(err)
            end)
        end

        load_and_cache("cursor_1")
        load_and_cache("cursor_2")
        load_and_cache("cursor_3")
    else
        mod:echo("Needs SimpleAssets in order to work")
    end
end

function mod.on_setting_changed(setting_id)
    if setting_id == "custom_cursor" then
        local cursor_setting = mod:get("custom_cursor")
        if cursor_setting == "default" then
            if rawget(_G, "Window") and Window.set_cursor then
                Window.set_cursor("content/ui/textures/cursors/mouse_cursor_idle")
            end
        else
            local resource_name = loaded_cursors[cursor_setting]
            if resource_name then
                if rawget(_G, "Window") and Window.set_cursor then
                    Window.set_cursor(resource_name)
                end
            else
                mod:echo("Cursor file not found or invalid format.")
            end
        end
    end

    local ui_manager = rawget(_G, "Managers") and Managers.ui
    if ui_manager and ui_manager.view_active and ui_manager:view_active("dmf_options_view") then
        local view = ui_manager:view_instance("dmf_options_view")
        if view then
            apply_transparency(view)
        end
    end
end

function mod.on_enabled()
    local ui_manager = rawget(_G, "Managers") and Managers.ui
    if ui_manager and ui_manager.view_active and ui_manager:view_active("dmf_options_view") then
        local view = ui_manager:view_instance("dmf_options_view")
        if view then
            apply_transparency(view)
        end
    end
end

function mod.on_disabled()
    local ui_manager = rawget(_G, "Managers") and Managers.ui
    if ui_manager and ui_manager.view_active and ui_manager:view_active("dmf_options_view") then
        local view = ui_manager:view_instance("dmf_options_view")
        if view then
            apply_transparency(view)
        end
    end
end
