# Pkg.clone("https://github.com/wookay/GlyphSheets.jl.git")
using GlyphSheets
import GlyphSheets.DSL: Move, Line, Cubic, Conic

library = create_library()
typeface = create_typeface(library, "Butler_Regular.otf")

glyph = create_glyph(typeface, 'B', 10pt)
outlines = outline_decompose(glyph)

close_typeface(typeface)
close_library(library)


using Cairo
using ColorTypes

c = CairoRGBSurface(600, 800)
cr = CairoContext(c)

save(cr)
set_source_rgb(cr,0.8,0.8,0.8)
rectangle(cr,0,0,600,800)
fill(cr)
restore(cr)

translate(cr, 0, 730)
scale(cr, 1, -1)

for op in outlines
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

close_path(cr)
set_line_width(cr, 3)

set_source_rgba(cr, 1, 0.5, 0.5, 0.8)
fill_preserve(cr)
set_source_rgba(cr, 0, 1, 0, 1)
stroke(cr)

write_to_png(c,"cairo.png")
