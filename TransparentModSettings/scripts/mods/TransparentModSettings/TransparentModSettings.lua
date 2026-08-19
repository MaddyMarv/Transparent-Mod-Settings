local mod = get_mod("TransparentModSettings")
if not mod then return end

local math_floor = math.floor
local DEFAULT_RECT_ALPHA = 255
local DEFAULT_TEXTURE_ALPHA = 204
local DEFAULT_ICON_ALPHA = 80
local DEFAULT_GAME_WORLD_BLUR = 1.1

local function get_alpha_values()
    local is_enabled = mod:is_enabled()
    local bg_opacity_pct = is_enabled and (mod:get("background_opacity") or 50) or 100
    local icon_opacity_pct = is_enabled and (mod:get("background_icon_opacity") or 50) or 100
    local blur_pct = is_enabled and (mod:get("game_world_blur") or 0) or 100

    local bg_factor = bg_opacity_pct / 100
    local icon_factor = icon_opacity_pct / 100
    local blur_factor = blur_pct / 100

    local rect_alpha = math_floor(DEFAULT_RECT_ALPHA * bg_factor + 0.5)
    local texture_alpha = math_floor(DEFAULT_TEXTURE_ALPHA * bg_factor + 0.5)
    local icon_alpha = math_floor(DEFAULT_ICON_ALPHA * icon_factor + 0.5)

    return rect_alpha, texture_alpha, icon_alpha, blur_factor
end

local function update_widget_pass_alphas(widget, rect_alpha, texture_alpha, icon_alpha)
    if not widget then return end

    if widget.style then
        if widget.style.style_id_1 and widget.style.style_id_1.color then
            widget.style.style_id_1.color[1] = icon_alpha or rect_alpha or 255
        end
        if widget.style.style_id_2 and widget.style.style_id_2.color then
            widget.style.style_id_2.color[1] = texture_alpha or 204
        end
    end

    if widget.passes then
        for i = 1, #widget.passes do
            local pass = widget.passes[i]
            local pass_style = pass.style or (widget.style and widget.style[pass.style_id])
            if pass_style and pass_style.color then
                if pass.pass_type == "slug_icon" then
                    pass_style.color[1] = icon_alpha or DEFAULT_ICON_ALPHA
                elseif pass.pass_type == "rect" then
                    pass_style.color[1] = rect_alpha or DEFAULT_RECT_ALPHA
                else
                    pass_style.color[1] = texture_alpha or DEFAULT_TEXTURE_ALPHA
                end
            end
        end
    end

    widget.dirty = true
end

local function apply_blur(blur_multiplier)
    local target_blur = DEFAULT_GAME_WORLD_BLUR * blur_multiplier
    local ui_manager = rawget(_G, "Managers") and Managers.ui
    local view_handler = ui_manager and ui_manager._view_handler

    if view_handler then
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

local function apply_transparency(view)
    if not view or not view._widgets_by_name then
        return
    end

    local rect_alpha, texture_alpha, icon_alpha, blur_factor = get_alpha_values()

    update_widget_pass_alphas(view._widgets_by_name.background, rect_alpha, texture_alpha, nil)
    update_widget_pass_alphas(view._widgets_by_name.background_icon, nil, nil, icon_alpha)

    apply_blur(blur_factor)
end

local function get_active_options_view()
    local ui_manager = rawget(_G, "Managers") and Managers.ui
    if ui_manager and ui_manager.view_instance then
        return ui_manager:view_instance("dmf_options_view")
    end
    return nil
end

local function setup_dmf_options_view_hooks()
    local target_class = rawget(_G, "CLASS") and CLASS.DMFOptionsView or rawget(_G, "DMFOptionsView")
    if not target_class then
        return
    end

    mod:hook_safe(target_class, "on_enter", function(self)
        apply_transparency(self)
    end)

    mod:hook_safe(target_class, "_draw_widgets", function(self)
        apply_transparency(self)
    end)
end

-- Hook when all mods are loaded (after DMF initializes dmf_options_view)
function mod.on_all_mods_loaded()
    setup_dmf_options_view_hooks()

    local _, _, _, blur_factor = get_alpha_values()
    apply_blur(blur_factor)
end

-- Also register require hook in case dmf_options_view is loaded or re-required
mod:hook_require("dmf/scripts/mods/dmf/modules/ui/options/dmf_options_view", function(instance)
    setup_dmf_options_view_hooks()
end)

function mod.on_setting_changed(setting_id)
    local view = get_active_options_view()
    if view then
        apply_transparency(view)
    else
        local _, _, _, blur_factor = get_alpha_values()
        apply_blur(blur_factor)
    end
end

function mod.on_enabled()
    local view = get_active_options_view()
    if view then
        apply_transparency(view)
    else
        local _, _, _, blur_factor = get_alpha_values()
        apply_blur(blur_factor)
    end
end

function mod.on_disabled()
    local view = get_active_options_view()
    if view then
        apply_transparency(view)
    else
        apply_blur(1.0)
    end
end
