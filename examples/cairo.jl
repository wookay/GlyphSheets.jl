# Pkg.clone("https://github.com/wookay/GlyphSheets.jl.git")
using GlyphSheets
import GlyphSheets.DSL: Move, Line, Cubic, Conic

library = create_library()
typeface = create_typeface(library, "Butler_Regular.otf")

glyph = create_glyph(typeface, 'B', 5pt)
outlines = outline_decompose(glyph)

close_typeface(typeface)
close_library(library)


using Cairo
using Colors
using ColorTypes

c = CairoRGBSurface(300, 300)
cr = CairoContext(c)

save(cr)
set_source_rgb(cr, 0.8, 0.8, 0.8)
rectangle(cr, 0, 0, 300, 300)
fill(cr)
restore(cr)

translate(cr, 0, glyph.slot.metrics.height+20)
scale(cr, 1, -1)

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

fill_paths(cr, outlines)
stroke_paths(cr, outlines)

write_to_png(c, "cairo.png")
