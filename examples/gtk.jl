# Pkg.clone("https://github.com/wookay/GlyphSheets.jl.git")
using GlyphSheets
import GlyphSheets.DSL: Move, Line, Cubic, Conic

library = create_library()
typeface = create_typeface(library, "Butler_Regular.otf")

glyph = create_glyph(typeface, 'B', 5pt)
outlines = outline_decompose(glyph)

close_typeface(typeface)
close_library(library)


using Gtk, Gtk.ShortNames, Graphics, Cairo
using Colors

win = Window("Gtk", 300, 300)
hbox = Box(:h)
setproperty!(hbox, :homogeneous, true)
push!(win, hbox)
canv = Canvas()
push!(hbox, canv)

function operate(cr, op)
    if op isa Move
        move_to(cr, op.to...)
    elseif op isa Line
        line_to(cr, op.to...)
    elseif op isa Conic
        curve_to(cr, op.control..., op.to..., op.to...)
    elseif op isa Cubic
        curve_to(cr, op.control1..., op.control2..., op.to...)
    end
end

function fill_paths(cr, outlines)
    save(cr)
    operate.(cr, outlines)
    set_source_rgba(cr, 0.9, 1, 0.9, 1)
    fill(cr)
    restore(cr)
end

function stroke_paths(cr, outlines)
    save(cr)
    set_line_width(cr, 3)
    colors = distinguishable_colors(length(outlines))
    last_pos = (0, 0)
    for (color, op) in zip(colors, outlines)
        move_to(cr, last_pos...)
        operate(cr, op)
        set_source_rgba(cr, red(color), green(color), blue(color), alpha(color))
        stroke(cr)
        last_pos = op.to
    end
    restore(cr)
end

@guarded draw(canv) do widget
    cr = getgc(canv)

    translate(cr, 0, glyph.slot.metrics.height+20)
    scale(cr, 1, -1)

    fill_paths(cr, outlines)
    stroke_paths(cr, outlines)
end # guarded

showall(win)

cond = Condition()
signal_connect(win, :destroy) do widget
    notify(cond)
end
wait(cond)
