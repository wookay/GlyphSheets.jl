using GlyphSheets
using Base.Test

library = create_library()
typeface = create_typeface(library, "Butler_Regular.otf")

glyph = create_glyph(typeface, 'A', 12pt)
outlines = outline_decompose(glyph)

@test outlines isa Vector{GlyphSheets.DSL.PathOperation}
@test Any[GlyphSheets.DSL.Move((134, 173)), GlyphSheets.DSL.Line((227, 452)), GlyphSheets.DSL.Line((327, 173)), GlyphSheets.DSL.Line((134, 173)), GlyphSheets.DSL.Move((516, 9)), GlyphSheets.DSL.Cubic((495, 11), (478, 10), (453, 72)), GlyphSheets.DSL.Cubic((453, 72), (358, 328), (264, 576)), GlyphSheets.DSL.Line((256, 576)), GlyphSheets.DSL.Line((128, 192)), GlyphSheets.DSL.Cubic((61, 42), (42, 39), (13, 38)), GlyphSheets.DSL.Line((13, 28)), GlyphSheets.DSL.Line((184, 28)), GlyphSheets.DSL.Line((184, 38)), GlyphSheets.DSL.Cubic((77, 6), (111, 102), (132, 163)), GlyphSheets.DSL.Line((330, 163)), GlyphSheets.DSL.Line((357, 96)), GlyphSheets.DSL.Cubic((375, 53), (383, 9), (341, 9)), GlyphSheets.DSL.Line((341, 0)), GlyphSheets.DSL.Line((516, 0)), GlyphSheets.DSL.Line((516, 9))] == outlines

close_typeface(typeface)
close_library(library)
