using GlyphSheets
using Base.Test

library = create_library()
@test_throws ErrorException create_typeface(library, "NOT_FOUND.ttf")
close_library(library)
