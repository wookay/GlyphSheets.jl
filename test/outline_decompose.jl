using GlyphSheets
using Base.Test

library = create_library()
typeface = create_typeface(library, "Butler_Regular.otf")

glyph = create_glyph(typeface, 'A', 12pt)
outlines = outline_decompose(glyph)

@test Any[GlyphSheets.DSL.Move((175, 226)), GlyphSheets.DSL.Line((296, 558)), GlyphSheets.DSL.Line((427, 226)), GlyphSheets.DSL.Line((175, 226)), GlyphSheets.DSL.Move((673, 13)), GlyphSheets.DSL.Cubic((645, 15), (624, 14), (591, 94)), GlyphSheets.DSL.Cubic((591, 94), (467, 410), (345, 704)), GlyphSheets.DSL.Line((334, 704)), GlyphSheets.DSL.Line((167, 249)), GlyphSheets.DSL.Cubic((80, 18), (55, 14), (17, 13)), GlyphSheets.DSL.Line((17, 0)), GlyphSheets.DSL.Line((240, 0)), GlyphSheets.DSL.Line((240, 13)), GlyphSheets.DSL.Cubic((101, 9), (145, 133), (172, 213)), GlyphSheets.DSL.Line((431, 213)), GlyphSheets.DSL.Line((466, 126)), GlyphSheets.DSL.Cubic((489, 70), (499, 13), (445, 13)), GlyphSheets.DSL.Line((445, 0)), GlyphSheets.DSL.Line((673, 0)), GlyphSheets.DSL.Line((673, 13))] == outlines

glyph = create_glyph(typeface, '가', 12pt)
outlines = outline_decompose(glyph)

@test Any[GlyphSheets.DSL.Move((-1, 704)), GlyphSheets.DSL.Line((-1, 0)), GlyphSheets.DSL.Line((507, 0)), GlyphSheets.DSL.Line((507, 704)), GlyphSheets.DSL.Line((-1, 704)), GlyphSheets.DSL.Move((223, 352)), GlyphSheets.DSL.Line((49, 85)), GlyphSheets.DSL.Line((49, 620)), GlyphSheets.DSL.Line((223, 352)), GlyphSheets.DSL.Move((86, 654)), GlyphSheets.DSL.Line((420, 654)), GlyphSheets.DSL.Line((253, 398)), GlyphSheets.DSL.Line((86, 654)), GlyphSheets.DSL.Move((253, 307)), GlyphSheets.DSL.Line((420, 50)), GlyphSheets.DSL.Line((86, 50)), GlyphSheets.DSL.Line((253, 307)), GlyphSheets.DSL.Move((283, 352)), GlyphSheets.DSL.Line((457, 620)), GlyphSheets.DSL.Line((457, 85)), GlyphSheets.DSL.Line((283, 352))] == outlines

close_typeface(typeface)
close_library(library)
