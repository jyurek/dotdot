# Custom kitty tab bar: powerline tabs on the left, clock on the right.
# Loaded because kitty.conf sets `tab_bar_style custom`.
from datetime import datetime

from kitty.fast_data_types import get_options, get_os_window_title
from kitty.tab_bar import draw_tab_with_powerline
from kitty.utils import color_as_int


def _rgb(color):
    return color_as_int(color) << 8 | 2


def draw_tab(draw_data, screen, tab, before, max_title_length, index, is_last, extra_data):
    end = draw_tab_with_powerline(
        draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
    )
    if is_last:
        opts = get_options()
        os_title = get_os_window_title(tab.os_window_id) or ""
        right = f" {os_title}  {datetime.now():%a %b %-d  %H:%M} "
        screen.cursor.x = max(screen.cursor.x, screen.columns - len(right))
        screen.cursor.fg = _rgb(opts.inactive_tab_foreground)
        screen.cursor.bg = _rgb(opts.inactive_tab_background)
        screen.draw(right)
    return end
